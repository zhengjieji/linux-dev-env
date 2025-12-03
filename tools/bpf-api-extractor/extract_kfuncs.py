#!/usr/bin/env python3
"""
Extract BPF kfunc definitions from Linux kernel.

Data sources:
1. vmlinux BTF - for function signatures (via bpftool)
2. Linux source - for flags, kfunc sets, and program types
"""

import argparse
import csv
import json
import re
import subprocess
import sys
from pathlib import Path
from dataclasses import dataclass, field
from collections import defaultdict


# Kfuncs to ignore (test-only, from Go script)
IGNORE_KFUNCS = {
    "bpf_fentry_test1",
    "bpf_modify_return_test",
    "bpf_modify_return_test2",
    "bpf_modify_return_test_tp",
    "bpf_kfunc_call_memb_release",
    "bpf_kfunc_call_test_release",
    # Invalid entries (macro placeholders, etc.)
    "name",
    "func",
    "kfunc",
}

# Patterns to filter out test modules
IGNORE_PATH_PATTERNS = [
    "tools/testing/",
    "selftests/",
    "test_kmods/",
    "bpf_testmod",
]

# Patterns to filter out test kfuncs by name
IGNORE_NAME_PATTERNS = [
    r"^bpf_testmod_",
    r"_test\d*$",
    r"^bpf_kfunc_call_test",
]


@dataclass
class Kfunc:
    name: str
    signature: str = ""
    return_type: str = ""
    parameters: str = ""
    flags: list[str] = field(default_factory=list)
    kfunc_set: str = ""
    program_types: list[str] = field(default_factory=list)
    source_file: str = ""


def should_ignore_kfunc(name: str, source_file: str = "") -> bool:
    """Check if a kfunc should be ignored."""
    
    if not name:
        return True
    
    # Must be a valid C identifier (at least 2 chars, starts with letter/underscore)
    if len(name) < 2:
        return True
    
    if not (name[0].isalpha() or name[0] == '_'):
        return True
    
    if name in IGNORE_KFUNCS:
        return True
    
    # Check name patterns
    for pattern in IGNORE_NAME_PATTERNS:
        if re.search(pattern, name):
            return True
    
    # Check source file patterns
    if source_file:
        for pattern in IGNORE_PATH_PATTERNS:
            if pattern in source_file:
                return True
    
    return False


def extract_kfuncs_from_btf(vmlinux_path: Path) -> dict[str, Kfunc]:
    """Extract kfunc signatures from vmlinux BTF using bpftool."""
    
    kfuncs = {}
    
    print("Running bpftool btf dump (this may take a moment)...")
    
    try:
        result = subprocess.run(
            ['bpftool', 'btf', 'dump', 'file', str(vmlinux_path), '-j'],
            capture_output=True,
            text=True,
            timeout=120
        )
        
        if result.returncode != 0:
            print(f"bpftool failed: {result.stderr}", file=sys.stderr)
            return {}
        
        print("Parsing BTF JSON...")
        btf_data = json.loads(result.stdout)
        
        # Build type lookup
        types_by_id = {t['id']: t for t in btf_data.get('types', [])}
        
        # Find DECL_TAGs with bpf_kfunc
        # bpftool JSON format: {'kind': 'DECL_TAG', 'name': 'bpf_kfunc', 'type_id': xxx}
        kfunc_func_ids = set()
        
        for t in btf_data.get('types', []):
            if t.get('kind') == 'DECL_TAG' and t.get('name') == 'bpf_kfunc':
                type_id = t.get('type_id')
                if type_id:
                    kfunc_func_ids.add(type_id)
        
        print(f"Found {len(kfunc_func_ids)} kfunc tags in BTF")
        
        # Get function info for tagged functions
        for t in btf_data.get('types', []):
            if t.get('kind') != 'FUNC':
                continue
            if t['id'] not in kfunc_func_ids:
                continue
            
            name = t.get('name', '')
            if should_ignore_kfunc(name):
                continue
            
            proto_id = t.get('type_id')
            
            if proto_id and proto_id in types_by_id:
                proto = types_by_id[proto_id]
                sig = build_signature(name, proto, types_by_id)
                ret_type, params = parse_signature_parts(proto, types_by_id)
                
                kfuncs[name] = Kfunc(
                    name=name,
                    signature=sig,
                    return_type=ret_type,
                    parameters=params
                )
        
        return kfuncs
    
    except subprocess.TimeoutExpired:
        print("bpftool timed out", file=sys.stderr)
        return {}
    except FileNotFoundError:
        print("bpftool not found, skipping BTF extraction", file=sys.stderr)
        return {}
    except json.JSONDecodeError as e:
        print(f"Failed to parse BTF JSON: {e}", file=sys.stderr)
        return {}


def build_signature(name: str, proto: dict, types: dict) -> str:
    """Build C function signature from BTF FUNC_PROTO."""
    
    ret_type_id = proto.get('ret_type_id') or proto.get('ret_type') or 0
    ret_type = type_to_c(ret_type_id, types)
    
    params = []
    for p in proto.get('params', []):
        param_type_id = p.get('type_id') or p.get('type') or 0
        param_type = type_to_c(param_type_id, types)
        param_name = p.get('name', '')
        if param_name:
            params.append(f"{param_type} {param_name}".strip())
        else:
            params.append(param_type)
    
    params_str = ', '.join(params) if params else 'void'
    
    if ret_type.endswith('*'):
        return f"{ret_type}{name}({params_str})"
    else:
        return f"{ret_type} {name}({params_str})"


def parse_signature_parts(proto: dict, types: dict) -> tuple[str, str]:
    """Extract return type and parameters from BTF FUNC_PROTO."""
    
    ret_type_id = proto.get('ret_type_id') or proto.get('ret_type') or 0
    ret_type = type_to_c(ret_type_id, types)
    
    params = []
    for p in proto.get('params', []):
        param_type_id = p.get('type_id') or p.get('type') or 0
        param_type = type_to_c(param_type_id, types)
        param_name = p.get('name', '')
        if param_name:
            params.append(f"{param_type} {param_name}".strip())
        else:
            params.append(param_type)
    
    return ret_type.strip(), ', '.join(params)


def type_to_c(type_id: int, types: dict, depth: int = 0) -> str:
    """Convert BTF type to C type string."""
    
    if depth > 20:
        return "..."
    
    if type_id == 0:
        return "void"
    
    t = types.get(type_id)
    if not t:
        return "unknown"
    
    kind = t.get('kind', '')
    
    if kind == 'INT':
        return t.get('name', 'int')
    elif kind == 'PTR':
        target_id = t.get('type_id') or t.get('type') or 0
        target = type_to_c(target_id, types, depth + 1)
        return f"{target} *"
    elif kind == 'CONST':
        target_id = t.get('type_id') or t.get('type') or 0
        target = type_to_c(target_id, types, depth + 1)
        return f"const {target}"
    elif kind == 'VOLATILE':
        target_id = t.get('type_id') or t.get('type') or 0
        target = type_to_c(target_id, types, depth + 1)
        return f"volatile {target}"
    elif kind == 'RESTRICT':
        target_id = t.get('type_id') or t.get('type') or 0
        target = type_to_c(target_id, types, depth + 1)
        return f"restrict {target}"
    elif kind == 'TYPEDEF':
        return t.get('name', 'typedef')
    elif kind == 'STRUCT':
        return f"struct {t.get('name', '')}"
    elif kind == 'UNION':
        return f"union {t.get('name', '')}"
    elif kind == 'ENUM':
        return t.get('name', 'enum')
    elif kind == 'ARRAY':
        elem_id = t.get('type_id') or t.get('type') or 0
        elem_type = type_to_c(elem_id, types, depth + 1)
        nelems = t.get('nr_elems', 0)
        return f"{elem_type}[{nelems}]"
    elif kind == 'FUNC_PROTO':
        return "func_ptr"
    elif kind == 'VOID':
        return "void"
    else:
        return t.get('name', 'unknown')


def find_relevant_files(linux_dir: Path) -> list[Path]:
    """Use grep to quickly find files containing kfunc-related patterns."""
    
    print("Finding relevant source files with grep...")
    
    patterns = ['BTF_KFUNCS_START', '__bpf_kfunc', 'register_btf_kfunc_id_set']
    relevant_files = set()
    
    for pattern in patterns:
        try:
            result = subprocess.run(
                ['grep', '-r', '-l', '--include=*.c', pattern, str(linux_dir)],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            for line in result.stdout.strip().split('\n'):
                if line and line.endswith('.c'):
                    # Skip test files
                    skip = False
                    for ignore_pattern in IGNORE_PATH_PATTERNS:
                        if ignore_pattern in line:
                            skip = True
                            break
                    if not skip:
                        relevant_files.add(Path(line))
        
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
    
    print(f"Found {len(relevant_files)} relevant files (excluding test files)")
    return list(relevant_files)


def extract_kfunc_metadata_from_source(linux_dir: Path, kfuncs: dict[str, Kfunc]) -> dict[str, Kfunc]:
    """Extract kfunc metadata (flags, sets, program types) from kernel source."""
    
    c_files = find_relevant_files(linux_dir)
    
    if not c_files:
        print("Warning: No relevant files found, falling back to key directories", file=sys.stderr)
        for subdir in ['kernel/bpf', 'net/core', 'net/bpf']:
            path = linux_dir / subdir
            if path.exists():
                c_files.extend(path.glob('*.c'))
    
    kfunc_sets = defaultdict(lambda: {'prog_types': [], 'kfuncs': []})
    
    print(f"Parsing {len(c_files)} source files...")
    
    for c_file in c_files:
        try:
            content = c_file.read_text(errors='ignore')
        except Exception:
            continue
        
        try:
            rel_path = str(c_file.relative_to(linux_dir))
        except ValueError:
            rel_path = str(c_file)
        
        # Skip test files that might have slipped through
        skip = False
        for pattern in IGNORE_PATH_PATTERNS:
            if pattern in rel_path:
                skip = True
                break
        if skip:
            continue
        
        # Find __bpf_kfunc definitions
        for m in re.finditer(r'__bpf_kfunc\s+[\w\s\*]+\s+(\w+)\s*\(', content):
            func_name = m.group(1)
            if should_ignore_kfunc(func_name, rel_path):
                continue
            if func_name in kfuncs:
                kfuncs[func_name].source_file = rel_path
            else:
                kfuncs[func_name] = Kfunc(name=func_name, source_file=rel_path)
        
        # Parse BTF_KFUNCS_START blocks
        current_set = None
        
        for line in content.split('\n'):
            # Check for kfunc set start
            m = re.search(r'BTF_KFUNCS_START\((\w+)\)', line)
            if m:
                current_set = m.group(1)
                continue
            
            if 'BTF_KFUNCS_END' in line:
                current_set = None
                continue
            
            # Check for BTF_ID_FLAGS (with flags)
            m = re.search(r'BTF_ID_FLAGS\(func,\s*(\w+)(?:,\s*([^)]+))?\)', line)
            if m and current_set:
                func_name = m.group(1)
                if should_ignore_kfunc(func_name, rel_path):
                    continue
                
                flags_str = m.group(2) if m.group(2) else ""
                flags = [f.strip() for f in flags_str.split('|') if f.strip()] if flags_str else []
                
                kfunc_sets[current_set]['kfuncs'].append(func_name)
                
                if func_name in kfuncs:
                    kfuncs[func_name].flags = flags
                    kfuncs[func_name].kfunc_set = current_set
                else:
                    kfuncs[func_name] = Kfunc(name=func_name, flags=flags, kfunc_set=current_set)
                continue
            
            # Check for BTF_ID (simple, no flags)
            m = re.search(r'BTF_ID\(func,\s*(\w+)\)', line)
            if m and current_set:
                func_name = m.group(1)
                if should_ignore_kfunc(func_name, rel_path):
                    continue
                
                kfunc_sets[current_set]['kfuncs'].append(func_name)
                
                if func_name in kfuncs:
                    if not kfuncs[func_name].kfunc_set:
                        kfuncs[func_name].kfunc_set = current_set
                else:
                    kfuncs[func_name] = Kfunc(name=func_name, kfunc_set=current_set)
        
        # Find register_btf_kfunc_id_set calls
        for m in re.finditer(r'register_btf_kfunc_id_set\s*\(\s*(BPF_PROG_TYPE_\w+)\s*,\s*&(\w+)', content):
            prog_type = m.group(1)
            set_name = m.group(2)
            kfunc_sets[set_name]['prog_types'].append(prog_type)
    
    # Apply program types to kfuncs based on their sets
    for set_name, set_info in kfunc_sets.items():
        for func_name in set_info['kfuncs']:
            if func_name in kfuncs:
                kfuncs[func_name].program_types.extend(set_info['prog_types'])
    
    # Deduplicate and clean up
    for kfunc in kfuncs.values():
        kfunc.program_types = sorted(set(kfunc.program_types))
    
    # Final filter - remove any remaining invalid entries
    valid_kfuncs = {
        name: kfunc for name, kfunc in kfuncs.items()
        if name and not should_ignore_kfunc(name, kfunc.source_file)
    }
    
    return valid_kfuncs


def write_csv(kfuncs: list[Kfunc], output_path: Path):
    """Write kfuncs to CSV file."""
    
    with open(output_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow([
            'name', 'signature', 'return_type', 'parameters', 
            'flags', 'kfunc_set', 'program_types', 'source_file'
        ])
        
        for k in sorted(kfuncs, key=lambda x: x.name):
            writer.writerow([
                k.name,
                k.signature,
                k.return_type,
                k.parameters,
                '|'.join(k.flags),
                k.kfunc_set,
                ','.join(k.program_types),
                k.source_file
            ])


def main():
    parser = argparse.ArgumentParser(description='Extract BPF kfunc definitions from Linux kernel')
    parser.add_argument('--linux-dir', required=True, help='Path to Linux source directory')
    parser.add_argument('--vmlinux', help='Path to vmlinux with BTF (optional, for signatures)')
    parser.add_argument('--output', '-o', default='output/kfuncs.csv', help='Output CSV file path')
    
    args = parser.parse_args()
    
    linux_dir = Path(args.linux_dir).resolve()
    
    if not linux_dir.exists():
        print(f"Error: {linux_dir} not found", file=sys.stderr)
        sys.exit(1)
    
    kfuncs = {}
    
    # Step 1: Extract signatures from BTF (if vmlinux provided)
    if args.vmlinux:
        vmlinux_path = Path(args.vmlinux)
        if vmlinux_path.exists():
            print(f"Parsing BTF from {vmlinux_path}...")
            kfuncs = extract_kfuncs_from_btf(vmlinux_path)
            print(f"Found {len(kfuncs)} kfuncs in BTF")
        else:
            print(f"Warning: {vmlinux_path} not found, skipping BTF extraction", file=sys.stderr)
    
    # Step 2: Extract metadata from source
    print(f"Extracting metadata from {linux_dir}...")
    kfuncs = extract_kfunc_metadata_from_source(linux_dir, kfuncs)
    
    print(f"Total kfuncs: {len(kfuncs)}")
    
    # Statistics
    with_sig = sum(1 for k in kfuncs.values() if k.signature)
    with_flags = sum(1 for k in kfuncs.values() if k.flags)
    with_prog_types = sum(1 for k in kfuncs.values() if k.program_types)
    
    print(f"  - {with_sig} with signatures")
    print(f"  - {with_flags} with flags")
    print(f"  - {with_prog_types} with program types")
    
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    write_csv(list(kfuncs.values()), output_path)
    print(f"Written to {output_path}")


if __name__ == '__main__':
    main()