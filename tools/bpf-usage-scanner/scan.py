#!/usr/bin/env python3
"""
Scan BPF projects for helper and kfunc usage.

Reads helper/kfunc lists from bpf-api-extractor output,
then scans each project under projects/ directory.
"""

import os
import re
import csv
import sys
import argparse
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional
from collections import defaultdict

# Try to import tqdm for progress bars, fallback to simple implementation
try:
    from tqdm import tqdm
    HAS_TQDM = True
except ImportError:
    HAS_TQDM = False


class SimpleProgressBar:
    """Simple progress bar fallback when tqdm is not available."""
    
    def __init__(self, iterable=None, total=None, desc="", unit="it", leave=True):
        self.iterable = iterable
        self.total = total or (len(iterable) if iterable is not None else 0)
        self.desc = desc
        self.unit = unit
        self.leave = leave
        self.n = 0
        self.bar_width = 40
    
    def __iter__(self):
        for item in self.iterable:
            yield item
            self.n += 1
            self._print_bar()
        if self.leave:
            print(file=sys.stderr)
    
    def _print_bar(self):
        if self.total == 0:
            return
        percent = self.n / self.total
        filled = int(self.bar_width * percent)
        bar = '█' * filled + '░' * (self.bar_width - filled)
        print(f'\r  {self.desc}: |{bar}| {self.n}/{self.total} {self.unit}', 
              end='', file=sys.stderr)
    
    def update(self, n=1):
        self.n += n
        self._print_bar()


def progress_bar(iterable=None, total=None, desc="", unit="files", leave=True):
    """Create a progress bar using tqdm if available, else fallback."""
    if HAS_TQDM:
        return tqdm(iterable, total=total, desc=f"  {desc}", unit=unit, 
                    leave=leave, file=sys.stderr, ncols=80,
                    bar_format='{desc}: |{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}]')
    else:
        return SimpleProgressBar(iterable, total, desc, unit, leave)


@dataclass
class FunctionUsage:
    name: str
    count: int = 0
    files: set = field(default_factory=set)
    locations: list = field(default_factory=list)  # ["file:line", ...]


def load_function_names(csv_path: Path) -> dict[str, str]:
    """
    Load function names from CSV file.
    Returns dict mapping all possible names (including aliases) to canonical name.
    
    For example, bpf_map_lookup_elem -> {
        'bpf_map_lookup_elem': 'bpf_map_lookup_elem',
        'map_lookup_elem': 'bpf_map_lookup_elem'  # alias without bpf_ prefix
    }
    """
    name_map = {}
    if not csv_path.exists():
        print(f"Warning: {csv_path} not found", file=sys.stderr)
        return name_map
    
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get('name', '').strip()
            if name:
                # Add canonical name
                name_map[name] = name
                # Add alias without bpf_ prefix (common pattern in projects like cilium)
                if name.startswith('bpf_'):
                    alias = name[4:]  # remove 'bpf_' prefix
                    name_map[alias] = name
    
    return name_map


def remove_comments(content: str) -> str:
    """Remove C-style comments from content."""
    # Remove single-line comments
    content = re.sub(r'//.*$', '', content, flags=re.MULTILINE)
    # Remove multi-line comments
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    return content


def remove_strings(content: str) -> str:
    """Remove string literals from content."""
    # Remove double-quoted strings (handle escaped quotes)
    content = re.sub(r'"(?:[^"\\]|\\.)*"', '""', content)
    return content


def build_combined_pattern(func_name_map: dict[str, str]) -> tuple[re.Pattern, dict[str, str]]:
    """
    Build a single compiled regex pattern that matches all function names.
    Returns (compiled_pattern, name_map).
    """
    # Sort by length descending to match longer names first (e.g., map_lookup_elem before map_lookup)
    sorted_names = sorted(func_name_map.keys(), key=len, reverse=True)
    
    # Build alternation pattern: (name1|name2|name3)
    escaped_names = [re.escape(name) for name in sorted_names]
    combined = '|'.join(escaped_names)
    
    # Pattern: word boundary + (name1|name2|...) + optional whitespace + (
    pattern = re.compile(rf'(?<![a-zA-Z0-9_])({combined})\s*\(')
    
    return pattern, func_name_map


def scan_file(file_path: Path, combined_pattern: re.Pattern, func_name_map: dict[str, str]) -> dict[str, list[tuple[str, int]]]:
    """
    Scan a single file for function calls.
    Returns dict: canonical_func_name -> [(file, line_number), ...]
    
    Uses a pre-compiled combined regex for efficiency.
    """
    results = defaultdict(list)
    
    try:
        content = file_path.read_text(errors='ignore')
    except Exception as e:
        print(f"Warning: Cannot read {file_path}: {e}", file=sys.stderr)
        return results
    
    # Process line by line to track line numbers
    lines = content.split('\n')
    
    # Track multi-line comment state
    in_multiline_comment = False
    
    for line_num, line in enumerate(lines, start=1):
        # Handle multi-line comments
        if in_multiline_comment:
            if '*/' in line:
                line = line[line.index('*/') + 2:]
                in_multiline_comment = False
            else:
                continue
        
        # Check for start of multi-line comment
        while '/*' in line:
            before = line[:line.index('/*')]
            after = line[line.index('/*') + 2:]
            if '*/' in after:
                line = before + after[after.index('*/') + 2:]
            else:
                line = before
                in_multiline_comment = True
                break
        
        # Remove single-line comments
        if '//' in line:
            line = line[:line.index('//')]
        
        # Remove strings
        line = remove_strings(line)
        
        # Find all matches in this line using the combined pattern
        for match in combined_pattern.finditer(line):
            matched_name = match.group(1)
            canonical_name = func_name_map.get(matched_name)
            if canonical_name:
                results[canonical_name].append((str(file_path), line_num))
    
    return results


def scan_file_fast(file_path: Path, func_name_map: dict[str, str]) -> dict[str, list[tuple[str, int]]]:
    """
    Fast scan a single file for function calls.
    Uses string pre-filtering instead of a large combined regex.
    Returns dict: canonical_func_name -> [(file, line_number), ...]
    """
    results = defaultdict(list)
    
    try:
        content = file_path.read_text(errors='ignore')
    except Exception as e:
        return results
    
    # Quick check: if none of the function names appear in the file, skip it
    # Use a set of short prefixes for quick filtering
    if not any(name in content for name in func_name_map.keys()):
        return results
    
    # Process line by line to track line numbers
    lines = content.split('\n')
    
    # Track multi-line comment state
    in_multiline_comment = False
    
    for line_num, line in enumerate(lines, start=1):
        # Handle multi-line comments
        if in_multiline_comment:
            if '*/' in line:
                line = line[line.index('*/') + 2:]
                in_multiline_comment = False
            else:
                continue
        
        # Check for start of multi-line comment
        while '/*' in line:
            before = line[:line.index('/*')]
            after = line[line.index('/*') + 2:]
            if '*/' in after:
                line = before + after[after.index('*/') + 2:]
            else:
                line = before
                in_multiline_comment = True
                break
        
        # Remove single-line comments
        if '//' in line:
            line = line[:line.index('//')]
        
        # Remove strings
        line = remove_strings(line)
        
        # Quick check if line might contain any function call
        if '(' not in line:
            continue
        
        # Search for function calls - check each name individually
        for search_name, canonical_name in func_name_map.items():
            # Quick string check first
            if search_name not in line:
                continue
            
            # Verify with regex for word boundary
            pattern = rf'(?<![a-zA-Z0-9_]){re.escape(search_name)}\s*\('
            if re.search(pattern, line):
                results[canonical_name].append((str(file_path), line_num))
    
    return results


def scan_project(project_path: Path, helper_name_map: dict[str, str], kfunc_name_map: dict[str, str],
                 file_extensions: list[str]) -> tuple[dict[str, FunctionUsage], dict[str, FunctionUsage]]:
    """
    Scan a project for helper and kfunc usage.
    Returns (helper_usage, kfunc_usage) dicts.
    """
    helper_usage = {}
    kfunc_usage = {}
    
    # Get canonical names (unique values from the maps)
    helper_canonical = set(helper_name_map.values())
    kfunc_canonical = set(kfunc_name_map.values())
    
    # Initialize usage tracking with canonical names
    for name in helper_canonical:
        helper_usage[name] = FunctionUsage(name=name)
    for name in kfunc_canonical:
        kfunc_usage[name] = FunctionUsage(name=name)
    
    # Combine maps for scanning
    all_funcs_map = {**helper_name_map, **kfunc_name_map}
    
    # Collect all files first for progress bar
    print(f"  Collecting files...", end='', file=sys.stderr, flush=True)
    all_files = []
    for ext in file_extensions:
        for file_path in project_path.rglob(f'*{ext}'):
            # Skip hidden directories and common non-source dirs
            parts = file_path.parts
            if any(p.startswith('.') or p in ('build', 'node_modules', '__pycache__', 'vendor') for p in parts):
                continue
            all_files.append(file_path)
    print(f" found {len(all_files)} files", file=sys.stderr)
    
    if not all_files:
        return {}, {}
    
    # Scan files with progress bar
    for file_path in progress_bar(all_files, desc="Scanning", unit="files"):
        results = scan_file_fast(file_path, all_funcs_map)
        
        # Make path relative to project
        rel_path = file_path.relative_to(project_path)
        
        for canonical_name, locations in results.items():
            if canonical_name in helper_canonical:
                usage = helper_usage[canonical_name]
            else:
                usage = kfunc_usage[canonical_name]
            
            usage.count += len(locations)
            usage.files.add(str(rel_path))
            for _, line_num in locations:
                usage.locations.append(f"{rel_path}:{line_num}")
    
    # Filter out unused functions
    helper_usage = {k: v for k, v in helper_usage.items() if v.count > 0}
    kfunc_usage = {k: v for k, v in kfunc_usage.items() if v.count > 0}
    
    return helper_usage, kfunc_usage


def write_usage_csv(usage: dict[str, FunctionUsage], output_path: Path):
    """Write usage data to CSV."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    fieldnames = ['name', 'count', 'files', 'locations']
    
    # Sort by count descending
    sorted_usage = sorted(usage.values(), key=lambda x: x.count, reverse=True)
    
    with open(output_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        
        for item in sorted_usage:
            writer.writerow({
                'name': item.name,
                'count': item.count,
                'files': ','.join(sorted(item.files)),
                'locations': ','.join(item.locations),
            })


def write_summary_csv(summary_data: list[dict], output_path: Path):
    """Write summary CSV across all projects."""
    fieldnames = ['project', 'helper_count', 'kfunc_count', 
                  'unique_helpers', 'unique_kfuncs',
                  'top_helpers', 'top_kfuncs']
    
    with open(output_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(summary_data)


def get_top_funcs(usage: dict[str, FunctionUsage], n: int = 5) -> str:
    """Get top N functions by usage count."""
    sorted_items = sorted(usage.values(), key=lambda x: x.count, reverse=True)[:n]
    return ';'.join(f"{item.name}({item.count})" for item in sorted_items)


def main():
    parser = argparse.ArgumentParser(description='Scan BPF projects for helper/kfunc usage')
    parser.add_argument('--projects', '-p', type=Path, required=True,
                        help='Path to projects directory')
    parser.add_argument('--helpers-csv', type=Path, required=True,
                        help='Path to helpers.csv from bpf-api-extractor')
    parser.add_argument('--kfuncs-csv', type=Path, required=True,
                        help='Path to kfuncs.csv from bpf-api-extractor')
    parser.add_argument('--output', '-o', type=Path, required=True,
                        help='Output directory')
    parser.add_argument('--extensions', '-e', type=str, default='.c,.h,.bpf.c',
                        help='Comma-separated file extensions to scan (default: .c,.h,.bpf.c)')
    
    args = parser.parse_args()
    
    # Validate paths
    if not args.projects.exists():
        print(f"Error: Projects directory not found: {args.projects}", file=sys.stderr)
        sys.exit(1)
    
    # Load function names
    print(f"Loading helper names from {args.helpers_csv}...", file=sys.stderr)
    helper_name_map = load_function_names(args.helpers_csv)
    helper_canonical = set(helper_name_map.values())
    print(f"  Loaded {len(helper_canonical)} helpers ({len(helper_name_map)} patterns including aliases)", file=sys.stderr)
    
    print(f"Loading kfunc names from {args.kfuncs_csv}...", file=sys.stderr)
    kfunc_name_map = load_function_names(args.kfuncs_csv)
    kfunc_canonical = set(kfunc_name_map.values())
    print(f"  Loaded {len(kfunc_canonical)} kfuncs ({len(kfunc_name_map)} patterns including aliases)", file=sys.stderr)
    
    if not helper_name_map and not kfunc_name_map:
        print("Error: No functions loaded. Check input CSV files.", file=sys.stderr)
        sys.exit(1)
    
    # Parse extensions
    extensions = [ext.strip() for ext in args.extensions.split(',')]
    
    # Find all projects
    projects = [p for p in args.projects.iterdir() if p.is_dir() and not p.name.startswith('.')]
    
    if not projects:
        print(f"Warning: No projects found in {args.projects}", file=sys.stderr)
        sys.exit(0)
    
    print(f"Found {len(projects)} projects to scan", file=sys.stderr)
    
    summary_data = []
    
    # Scan each project
    for project_path in sorted(projects):
        project_name = project_path.name
        print(f"\nScanning project: {project_name}...", file=sys.stderr)
        
        helper_usage, kfunc_usage = scan_project(
            project_path, helper_name_map, kfunc_name_map, extensions
        )
        
        # Write project output
        project_output = args.output / project_name
        
        if helper_usage:
            write_usage_csv(helper_usage, project_output / 'helpers.csv')
            print(f"  Found {len(helper_usage)} unique helpers ({sum(u.count for u in helper_usage.values())} calls)", 
                  file=sys.stderr)
        
        if kfunc_usage:
            write_usage_csv(kfunc_usage, project_output / 'kfuncs.csv')
            print(f"  Found {len(kfunc_usage)} unique kfuncs ({sum(u.count for u in kfunc_usage.values())} calls)", 
                  file=sys.stderr)
        
        if not helper_usage and not kfunc_usage:
            print(f"  No BPF function usage found", file=sys.stderr)
        
        # Add to summary
        summary_data.append({
            'project': project_name,
            'helper_count': sum(u.count for u in helper_usage.values()),
            'kfunc_count': sum(u.count for u in kfunc_usage.values()),
            'unique_helpers': len(helper_usage),
            'unique_kfuncs': len(kfunc_usage),
            'top_helpers': get_top_funcs(helper_usage),
            'top_kfuncs': get_top_funcs(kfunc_usage),
        })
    
    # Write summary
    write_summary_csv(summary_data, args.output / 'summary.csv')
    print(f"\nSummary written to {args.output / 'summary.csv'}", file=sys.stderr)
    
    print("\nDone!", file=sys.stderr)


if __name__ == '__main__':
    main()