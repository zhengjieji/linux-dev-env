#!/usr/bin/env python3
"""
Extract BPF helper function definitions from Linux kernel source.

Data source: include/uapi/linux/bpf.h
"""

import argparse
import csv
import re
import sys
from pathlib import Path
from dataclasses import dataclass


@dataclass
class HelperFunc:
    id: int
    name: str
    signature: str = ""
    return_type: str = ""
    parameters: str = ""
    description: str = ""
    return_desc: str = ""


def parse_bpf_h(bpf_h_path: Path) -> list[HelperFunc]:
    """Parse include/uapi/linux/bpf.h to extract helper definitions."""
    
    content = bpf_h_path.read_text()
    lines = content.split('\n')
    
    # Step 1: Extract helper names and IDs from __BPF_FUNC_MAPPER
    helpers = {}
    
    # Find the mapper macro section
    in_mapper = False
    mapper_lines = []
    
    for line in lines:
        if '__BPF_FUNC_MAPPER(FN)' in line or '___BPF_FUNC_MAPPER(FN' in line:
            in_mapper = True
            mapper_lines.append(line)
            continue
        
        if in_mapper:
            mapper_lines.append(line)
            # End of macro (line without backslash or empty)
            if not line.rstrip().endswith('\\'):
                break
    
    mapper_content = '\n'.join(mapper_lines)
    
    # Try newer format: FN(name, id, ...)
    fn_with_id = re.findall(r'FN\((\w+),\s*(\d+)', mapper_content)
    if fn_with_id:
        for name, func_id in fn_with_id:
            if name != 'unspec':
                helpers[name] = HelperFunc(id=int(func_id), name=f"bpf_{name}")
    else:
        # Older format: FN(name)
        fn_simple = re.findall(r'FN\((\w+)\)', mapper_content)
        for i, name in enumerate(fn_simple, 1):
            if name != 'unspec':
                helpers[name] = HelperFunc(id=i, name=f"bpf_{name}")
    
    if not helpers:
        print("Warning: Could not find __BPF_FUNC_MAPPER in bpf.h", file=sys.stderr)
        return []
    
    print(f"Found {len(helpers)} helper names in mapper macro")
    
    # Step 2: Extract documentation blocks (line-by-line parsing)
    i = 0
    doc_count = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Look for start of doc comment: /*
        if line.strip() == '/*':
            # Collect the entire comment block
            doc_lines = []
            i += 1
            
            while i < len(lines) and '*/' not in lines[i]:
                doc_lines.append(lines[i])
                i += 1
            
            # Parse the doc block
            doc_text = '\n'.join(doc_lines)
            
            # Check if this looks like a helper doc (contains bpf_ function)
            sig_match = re.search(r'(\w[\w\s\*]+?)\s*(bpf_\w+)\s*\(([^)]*)\)', doc_text)
            
            if sig_match:
                return_type = sig_match.group(1).strip().lstrip('* \t')
                func_name = sig_match.group(2)
                parameters = sig_match.group(3).strip()
                
                short_name = func_name.replace('bpf_', '')
                
                if short_name in helpers:
                    helper = helpers[short_name]
                    helper.signature = f"{return_type} {func_name}({parameters})"
                    helper.return_type = return_type
                    helper.parameters = parameters
                    
                    # Extract description
                    desc_match = re.search(r'Description\s*\n(.*?)(?=Return|$)', doc_text, re.DOTALL | re.IGNORECASE)
                    if desc_match:
                        desc = desc_match.group(1)
                        desc = re.sub(r'^\s*\*\s?', '', desc, flags=re.MULTILINE)
                        desc = ' '.join(desc.split())[:500]
                        helper.description = desc
                    
                    # Extract return description
                    ret_match = re.search(r'Return\s*\n(.*?)$', doc_text, re.DOTALL | re.IGNORECASE)
                    if ret_match:
                        ret = ret_match.group(1)
                        ret = re.sub(r'^\s*\*\s?', '', ret, flags=re.MULTILINE)
                        ret = ' '.join(ret.split())[:300]
                        helper.return_desc = ret
                    
                    doc_count += 1
        
        i += 1
    
    print(f"Parsed {doc_count} documentation blocks")
    
    return sorted(helpers.values(), key=lambda h: h.id)


def write_csv(helpers: list[HelperFunc], output_path: Path):
    """Write helpers to CSV file."""
    
    with open(output_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'name', 'return_type', 'parameters', 'signature', 'description', 'return_desc'])
        
        for h in helpers:
            writer.writerow([
                h.id,
                h.name,
                h.return_type,
                h.parameters,
                h.signature,
                h.description,
                h.return_desc
            ])


def main():
    parser = argparse.ArgumentParser(description='Extract BPF helper definitions from Linux source')
    parser.add_argument('--linux-dir', required=True, help='Path to Linux source directory')
    parser.add_argument('--output', '-o', default='output/helpers.csv', help='Output CSV file path')
    
    args = parser.parse_args()
    
    linux_dir = Path(args.linux_dir)
    bpf_h = linux_dir / 'include' / 'uapi' / 'linux' / 'bpf.h'
    
    if not bpf_h.exists():
        print(f"Error: {bpf_h} not found", file=sys.stderr)
        sys.exit(1)
    
    print(f"Parsing {bpf_h}...")
    helpers = parse_bpf_h(bpf_h)
    
    print(f"Total: {len(helpers)} helpers")
    
    # Count how many have signatures
    with_sig = sum(1 for h in helpers if h.signature)
    print(f"  - {with_sig} with documentation")
    print(f"  - {len(helpers) - with_sig} without documentation")
    
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    write_csv(helpers, output_path)
    print(f"Written to {output_path}")


if __name__ == '__main__':
    main()