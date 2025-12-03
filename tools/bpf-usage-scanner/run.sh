#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="${PROJECTS_DIR:-$SCRIPT_DIR/../../projects}"
API_EXTRACTOR_OUTPUT="${API_EXTRACTOR_OUTPUT:-$SCRIPT_DIR/../bpf-api-extractor/output}"
OUTPUT_DIR="$SCRIPT_DIR/output"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Scan BPF projects for helper and kfunc usage.

Options:
    -h, --help      Show this help message

Environment:
    PROJECTS_DIR            Path to projects directory (default: ../../projects)
    API_EXTRACTOR_OUTPUT    Path to bpf-api-extractor output (default: ../bpf-api-extractor/output)

Output:
    output/{project_name}/helpers.csv   Helpers used by each project
    output/{project_name}/kfuncs.csv    Kfuncs used by each project
    output/summary.csv                  Cross-project summary
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            ;;
    esac
done

# Validate paths
[[ -d "$PROJECTS_DIR" ]] || log_error "Projects directory not found: $PROJECTS_DIR"
PROJECTS_DIR="$(realpath "$PROJECTS_DIR")"

HELPERS_CSV="$API_EXTRACTOR_OUTPUT/helpers.csv"
KFUNCS_CSV="$API_EXTRACTOR_OUTPUT/kfuncs.csv"

[[ -f "$HELPERS_CSV" ]] || log_warn "helpers.csv not found: $HELPERS_CSV"
[[ -f "$KFUNCS_CSV" ]] || log_warn "kfuncs.csv not found: $KFUNCS_CSV"

if [[ ! -f "$HELPERS_CSV" && ! -f "$KFUNCS_CSV" ]]; then
    log_error "No input CSV files found. Run bpf-api-extractor first."
fi

mkdir -p "$OUTPUT_DIR"

log_info "=============================================="
log_info "BPF Usage Scanner"
log_info "=============================================="
log_info "Projects dir:    $PROJECTS_DIR"
log_info "Helpers CSV:     $HELPERS_CSV"
log_info "Kfuncs CSV:      $KFUNCS_CSV"
log_info "Output dir:      $OUTPUT_DIR"
echo

python3 "$SCRIPT_DIR/scan.py" \
    --projects "$PROJECTS_DIR" \
    --helpers-csv "$HELPERS_CSV" \
    --kfuncs-csv "$KFUNCS_CSV" \
    --output "$OUTPUT_DIR"

log_info "=============================================="
log_info "Scan complete!"
log_info "=============================================="
echo
log_info "Output:"
log_info "  - $OUTPUT_DIR/summary.csv"
for dir in "$OUTPUT_DIR"/*/; do
    if [[ -d "$dir" ]]; then
        proj_name=$(basename "$dir")
        log_info "  - $OUTPUT_DIR/$proj_name/"
    fi
done