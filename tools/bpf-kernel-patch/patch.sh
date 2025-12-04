#!/bin/bash
#
# patch.sh - BPF Kernel Patch tool
#
# Tracks kernel file modifications across experiments, allowing easy
# apply/revert of changes without losing work or creating conflicts.
#

set -e

# Default paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXPERIMENTS_DIR="${EXPERIMENTS_DIR:-$PROJECT_ROOT/experiments}"
LINUX_DIR="${LINUX:-$PROJECT_ROOT/linux}"

STATE_FILE="$EXPERIMENTS_DIR/state.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#######################################
# Utility functions
#######################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

die() {
    log_error "$1"
    exit 1
}

# Check if jq is available
check_jq() {
    if ! command -v jq &> /dev/null; then
        die "jq is required but not installed. Install with: sudo apt-get install jq"
    fi
}

# Initialize experiments directory and state file
init_experiments_dir() {
    mkdir -p "$EXPERIMENTS_DIR"
    if [[ ! -f "$STATE_FILE" ]]; then
        echo '{"active": null, "applied": false}' > "$STATE_FILE"
    fi
}

# Get current active experiment
get_active() {
    jq -r '.active // empty' "$STATE_FILE"
}

# Check if changes are currently applied
is_applied() {
    [[ "$(jq -r '.applied' "$STATE_FILE")" == "true" ]]
}

# Get experiment directory
get_exp_dir() {
    local name="$1"
    echo "$EXPERIMENTS_DIR/$name"
}

# Get manifest file path
get_manifest() {
    local name="$1"
    echo "$(get_exp_dir "$name")/manifest.json"
}

# Calculate file hash
file_hash() {
    sha256sum "$1" 2>/dev/null | cut -d' ' -f1
}

# Check if experiment exists
exp_exists() {
    local name="$1"
    [[ -d "$(get_exp_dir "$name")" ]]
}

#######################################
# Command: new
#######################################

cmd_new() {
    local name="$1"

    if [[ -z "$name" ]]; then
        die "Usage: make new NAME=<name>"
    fi

    if exp_exists "$name"; then
        die "Experiment '$name' already exists"
    fi

    # Check if there's an active experiment with applied changes
    local active
    active=$(get_active)
    if [[ -n "$active" ]] && is_applied; then
        die "Experiment '$active' has applied changes. Run 'make revert' first."
    fi

    local exp_dir
    exp_dir=$(get_exp_dir "$name")

    mkdir -p "$exp_dir/backups"
    mkdir -p "$exp_dir/patches"

    # Create manifest
    cat > "$(get_manifest "$name")" << EOF
{
  "name": "$name",
  "created": "$(date -Iseconds)",
  "linux_dir": "$LINUX_DIR",
  "files": []
}
EOF

    # Set as active
    jq --arg name "$name" '.active = $name | .applied = false' "$STATE_FILE" > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"

    log_success "Created experiment '$name' and set as active"
}

#######################################
# Command: list
#######################################

cmd_list() {
    init_experiments_dir

    local active
    active=$(get_active)
    local applied
    is_applied && applied="yes" || applied="no"

    echo "Experiments:"
    echo ""

    local found=false
    for dir in "$EXPERIMENTS_DIR"/*/; do
        [[ -d "$dir" ]] || continue
        local name
        name=$(basename "$dir")
        [[ "$name" == "*" ]] && continue

        found=true
        if [[ "$name" == "$active" ]]; then
            if [[ "$applied" == "yes" ]]; then
                echo -e "  ${GREEN}* $name${NC} (active, applied)"
            else
                echo -e "  ${GREEN}* $name${NC} (active)"
            fi
        else
            echo "    $name"
        fi
    done

    if [[ "$found" == "false" ]]; then
        echo "  (none)"
    fi
    echo ""
}

#######################################
# Command: delete
#######################################

cmd_delete() {
    local name="$1"

    if [[ -z "$name" ]]; then
        die "Usage: exp delete <name>"
    fi

    if ! exp_exists "$name"; then
        die "Experiment '$name' does not exist"
    fi

    local active
    active=$(get_active)

    if [[ "$name" == "$active" ]] && is_applied; then
        die "Cannot delete active experiment with applied changes. Run 'make revert' first."
    fi

    rm -rf "$(get_exp_dir "$name")"

    # Clear active if we deleted it
    if [[ "$name" == "$active" ]]; then
        jq '.active = null | .applied = false' "$STATE_FILE" > "$STATE_FILE.tmp"
        mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi

    log_success "Deleted experiment '$name'"
}

#######################################
# Command: track
#######################################

cmd_track() {
    local mode="$1"  # "replace" or "add"
    shift
    local files=("$@")

    if [[ ${#files[@]} -eq 0 ]]; then
        if [[ "$mode" == "replace" ]]; then
            die "Usage: make track FILE=<path>"
        else
            die "Usage: make track-add FILE=<path>"
        fi
    fi

    local active
    active=$(get_active)
    if [[ -z "$active" ]]; then
        die "No active experiment. Run 'make new NAME=xxx' first."
    fi

    if is_applied; then
        die "Changes are currently applied. Run 'make revert' first."
    fi

    local exp_dir
    exp_dir=$(get_exp_dir "$active")
    local manifest
    manifest=$(get_manifest "$active")

    for file in "${files[@]}"; do
        local kernel_file="$LINUX_DIR/$file"
        local backup_file="$exp_dir/backups/$file"
        local patch_file="$exp_dir/patches/$file"

        # Check if already tracked
        if jq -e --arg f "$file" '.files[] | select(.path == $f)' "$manifest" > /dev/null 2>&1; then
            log_warn "File '$file' is already tracked, skipping"
            continue
        fi

        if [[ "$mode" == "replace" ]]; then
            # File must exist in kernel
            if [[ ! -f "$kernel_file" ]]; then
                log_error "File does not exist: $kernel_file"
                continue
            fi

            # Create backup
            mkdir -p "$(dirname "$backup_file")"
            cp "$kernel_file" "$backup_file"

            # Copy to patches for editing
            mkdir -p "$(dirname "$patch_file")"
            cp "$kernel_file" "$patch_file"

            local hash
            hash=$(file_hash "$kernel_file")

            # Add to manifest
            jq --arg path "$file" --arg hash "$hash" \
                '.files += [{"path": $path, "mode": "replace", "backup_hash": $hash}]' \
                "$manifest" > "$manifest.tmp"
            mv "$manifest.tmp" "$manifest"

            log_success "Tracking '$file' (replace mode)"
            log_info "  Edit: $patch_file"

        else  # add mode
            # File should NOT exist in kernel
            if [[ -f "$kernel_file" ]]; then
                log_error "File already exists in kernel: $kernel_file"
                log_error "Use 'make patch-track' for existing files"
                continue
            fi

            # Create empty patch file
            mkdir -p "$(dirname "$patch_file")"
            touch "$patch_file"

            # Add to manifest
            jq --arg path "$file" \
                '.files += [{"path": $path, "mode": "add"}]' \
                "$manifest" > "$manifest.tmp"
            mv "$manifest.tmp" "$manifest"

            log_success "Tracking '$file' (add mode)"
            log_info "  Edit: $patch_file"
        fi
    done
}

#######################################
# Command: untrack
#######################################

cmd_untrack() {
    local files=("$@")

    if [[ ${#files[@]} -eq 0 ]]; then
        die "Usage: make untrack FILE=<path>"
    fi

    local active
    active=$(get_active)
    if [[ -z "$active" ]]; then
        die "No active experiment"
    fi

    if is_applied; then
        die "Changes are currently applied. Run 'make revert' first."
    fi

    local exp_dir
    exp_dir=$(get_exp_dir "$active")
    local manifest
    manifest=$(get_manifest "$active")

    for file in "${files[@]}"; do
        local backup_file="$exp_dir/backups/$file"
        local patch_file="$exp_dir/patches/$file"

        # Check if tracked
        if ! jq -e --arg f "$file" '.files[] | select(.path == $f)' "$manifest" > /dev/null 2>&1; then
            log_warn "File '$file' is not tracked, skipping"
            continue
        fi

        # Remove files
        rm -f "$backup_file" "$patch_file"

        # Remove empty parent directories
        rmdir -p "$(dirname "$backup_file")" 2>/dev/null || true
        rmdir -p "$(dirname "$patch_file")" 2>/dev/null || true

        # Remove from manifest
        jq --arg path "$file" '.files = [.files[] | select(.path != $path)]' \
            "$manifest" > "$manifest.tmp"
        mv "$manifest.tmp" "$manifest"

        log_success "Untracked '$file'"
    done
}

#######################################
# Command: apply
#######################################

cmd_apply() {
    local active
    active=$(get_active)
    if [[ -z "$active" ]]; then
        die "No active experiment"
    fi

    if is_applied; then
        die "Changes are already applied"
    fi

    local exp_dir
    exp_dir=$(get_exp_dir "$active")
    local manifest
    manifest=$(get_manifest "$active")

    local files
    files=$(jq -r '.files[] | @base64' "$manifest")

    if [[ -z "$files" ]]; then
        die "No files tracked in experiment '$active'"
    fi

    # First pass: verify all files
    log_info "Verifying files..."
    for row in $files; do
        local data
        data=$(echo "$row" | base64 -d)
        local path mode backup_hash
        path=$(echo "$data" | jq -r '.path')
        mode=$(echo "$data" | jq -r '.mode')
        backup_hash=$(echo "$data" | jq -r '.backup_hash // empty')

        local kernel_file="$LINUX_DIR/$path"
        local patch_file="$exp_dir/patches/$path"

        if [[ "$mode" == "replace" ]]; then
            if [[ ! -f "$kernel_file" ]]; then
                die "Kernel file missing: $kernel_file"
            fi

            local current_hash
            current_hash=$(file_hash "$kernel_file")
            if [[ "$current_hash" != "$backup_hash" ]]; then
                die "File '$path' has been modified outside experiment. Hash mismatch."
            fi
        else  # add
            if [[ -f "$kernel_file" ]]; then
                die "File '$path' already exists in kernel (should be new)"
            fi
        fi

        if [[ ! -f "$patch_file" ]]; then
            die "Patch file missing: $patch_file"
        fi
    done

    # Second pass: apply changes
    log_info "Applying changes..."
    for row in $files; do
        local data
        data=$(echo "$row" | base64 -d)
        local path mode
        path=$(echo "$data" | jq -r '.path')
        mode=$(echo "$data" | jq -r '.mode')

        local kernel_file="$LINUX_DIR/$path"
        local patch_file="$exp_dir/patches/$path"

        mkdir -p "$(dirname "$kernel_file")"
        cp "$patch_file" "$kernel_file"

        log_success "Applied: $path ($mode)"
    done

    # Update state
    jq '.applied = true' "$STATE_FILE" > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"

    log_success "All changes applied for experiment '$active'"
    echo ""
    log_info "Next: sudo make vmlinux && make qemu-run"
}

#######################################
# Command: revert
#######################################

cmd_revert() {
    local active
    active=$(get_active)
    if [[ -z "$active" ]]; then
        die "No active experiment"
    fi

    if ! is_applied; then
        log_warn "No changes are currently applied"
        return 0
    fi

    local exp_dir
    exp_dir=$(get_exp_dir "$active")
    local manifest
    manifest=$(get_manifest "$active")

    local files
    files=$(jq -r '.files[] | @base64' "$manifest")

    log_info "Reverting changes..."
    for row in $files; do
        local data
        data=$(echo "$row" | base64 -d)
        local path mode
        path=$(echo "$data" | jq -r '.path')
        mode=$(echo "$data" | jq -r '.mode')

        local kernel_file="$LINUX_DIR/$path"
        local backup_file="$exp_dir/backups/$path"

        if [[ "$mode" == "replace" ]]; then
            if [[ -f "$backup_file" ]]; then
                cp "$backup_file" "$kernel_file"
                log_success "Reverted: $path"
            else
                log_warn "Backup missing for: $path"
            fi
        else  # add
            if [[ -f "$kernel_file" ]]; then
                rm "$kernel_file"
                # Remove empty parent directories
                rmdir -p "$(dirname "$kernel_file")" 2>/dev/null || true
                log_success "Removed: $path"
            fi
        fi
    done

    # Update state
    jq '.applied = false' "$STATE_FILE" > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"

    log_success "All changes reverted for experiment '$active'"
}

#######################################
# Command: status
#######################################

cmd_status() {
    init_experiments_dir

    local active
    active=$(get_active)

    echo ""
    if [[ -z "$active" ]]; then
        echo "Active experiment: (none)"
        echo ""
        return 0
    fi

    local applied_str
    is_applied && applied_str="${GREEN}yes${NC}" || applied_str="no"

    echo -e "Active experiment: ${GREEN}$active${NC}"
    echo -e "Changes applied: $applied_str"
    echo ""

    local manifest
    manifest=$(get_manifest "$active")
    local exp_dir
    exp_dir=$(get_exp_dir "$active")

    local files
    files=$(jq -r '.files[] | @base64' "$manifest" 2>/dev/null)

    if [[ -z "$files" ]]; then
        echo "Tracked files: (none)"
    else
        echo "Tracked files:"
        for row in $files; do
            local data
            data=$(echo "$row" | base64 -d)
            local path mode
            path=$(echo "$data" | jq -r '.path')
            mode=$(echo "$data" | jq -r '.mode')

            local patch_file="$exp_dir/patches/$path"
            local backup_file="$exp_dir/backups/$path"

            local status_indicator=""
            if [[ "$mode" == "replace" ]]; then
                if [[ -f "$patch_file" ]] && [[ -f "$backup_file" ]]; then
                    if diff -q "$patch_file" "$backup_file" > /dev/null 2>&1; then
                        status_indicator=" (unchanged)"
                    else
                        status_indicator=" ${YELLOW}(modified)${NC}"
                    fi
                fi
            fi

            echo -e "  [$mode] $path$status_indicator"
        done
    fi
    echo ""

    if ! is_applied; then
        log_info "Patches directory: $exp_dir/patches/"
    fi
    echo ""
}

#######################################
# Command: diff
#######################################

cmd_diff() {
    local target_file="$1"

    local active
    active=$(get_active)
    if [[ -z "$active" ]]; then
        die "No active experiment"
    fi

    local exp_dir
    exp_dir=$(get_exp_dir "$active")
    local manifest
    manifest=$(get_manifest "$active")

    local files
    if [[ -n "$target_file" ]]; then
        # Check if file is tracked
        if ! jq -e --arg f "$target_file" '.files[] | select(.path == $f)' "$manifest" > /dev/null 2>&1; then
            die "File '$target_file' is not tracked"
        fi
        files=$(jq -r --arg f "$target_file" '.files[] | select(.path == $f) | @base64' "$manifest")
    else
        files=$(jq -r '.files[] | @base64' "$manifest")
    fi

    if [[ -z "$files" ]]; then
        log_info "No files to diff"
        return 0
    fi

    for row in $files; do
        local data
        data=$(echo "$row" | base64 -d)
        local path mode
        path=$(echo "$data" | jq -r '.path')
        mode=$(echo "$data" | jq -r '.mode')

        local patch_file="$exp_dir/patches/$path"
        local backup_file="$exp_dir/backups/$path"

        echo "=== $path ($mode) ==="

        if [[ "$mode" == "add" ]]; then
            echo "(new file)"
            if [[ -s "$patch_file" ]]; then
                echo "Content:"
                head -20 "$patch_file"
                local lines
                lines=$(wc -l < "$patch_file")
                if [[ $lines -gt 20 ]]; then
                    echo "... ($lines lines total)"
                fi
            else
                echo "(empty)"
            fi
        else
            if [[ -f "$backup_file" ]] && [[ -f "$patch_file" ]]; then
                diff -u "$backup_file" "$patch_file" || true
            else
                echo "(files missing)"
            fi
        fi
        echo ""
    done
}

#######################################
# Command: activate
#######################################

cmd_activate() {
    local name="$1"

    if [[ -z "$name" ]]; then
        die "Usage: make activate NAME=<name>"
    fi

    if ! exp_exists "$name"; then
        die "Experiment '$name' does not exist"
    fi

    local active
    active=$(get_active)

    if [[ "$name" == "$active" ]]; then
        log_info "Experiment '$name' is already active"
        return 0
    fi

    if [[ -n "$active" ]] && is_applied; then
        die "Experiment '$active' has applied changes. Run 'make revert' first."
    fi

    jq --arg name "$name" '.active = $name | .applied = false' "$STATE_FILE" > "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"

    log_success "Activated experiment '$name'"
}

#######################################
# Main
#######################################

main() {
    check_jq
    init_experiments_dir

    local cmd="${1:-}"
    shift || true

    case "$cmd" in
        new)
            cmd_new "$@"
            ;;
        list)
            cmd_list
            ;;
        delete)
            cmd_delete "$@"
            ;;
        track)
            cmd_track "replace" "$@"
            ;;
        track-add)
            cmd_track "add" "$@"
            ;;
        untrack)
            cmd_untrack "$@"
            ;;
        apply)
            cmd_apply
            ;;
        revert)
            cmd_revert
            ;;
        status)
            cmd_status
            ;;
        diff)
            cmd_diff "$@"
            ;;
        activate)
            cmd_activate "$@"
            ;;
        *)
            echo "BPF Kernel Patch - Track kernel modifications across experiments"
            echo ""
            echo "Usage: make <command> [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  new NAME=xxx           Create new experiment and set as active"
            echo "  list                   List all experiments"
            echo "  delete NAME=xxx        Delete an experiment"
            echo "  activate NAME=xxx      Set experiment as active"
            echo "  track FILE=xxx         Track existing kernel file for replacement"
            echo "  track-add FILE=xxx     Track new file to be added"
            echo "  untrack FILE=xxx       Stop tracking file"
            echo "  apply                  Apply patches to kernel"
            echo "  revert                 Revert kernel to original state"
            echo "  status                 Show current experiment status"
            echo "  diff [FILE=xxx]        Show diff between backup and patch"
            exit 1
            ;;
    esac
}

main "$@"
