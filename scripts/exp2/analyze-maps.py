#!/usr/bin/env python3
"""Analyze Stage A map dump snapshots and produce oracle-ready specialization spec."""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import hashlib
import json
from pathlib import Path
from typing import Any


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Analyze Exp2 Stage A map dump invariants")
    p.add_argument(
        "--samples-dir",
        required=True,
        help="Directory containing sample-*/<map>.json and/or sample-*/<map>.hash.json",
    )
    p.add_argument("--map-ids", required=True, help="JSON from discover.sh (selected_map_ids + metadata)")
    p.add_argument("--output-spec", required=True, help="Output specialization spec JSON path")
    p.add_argument("--summary", required=True, help="Output CSV summary path")
    p.add_argument(
        "--final-dumps-dir",
        default="",
        help="Optional dir with retained single full dumps for invariant hash-only maps",
    )
    p.add_argument(
        "--max-inline-dump-bytes",
        type=int,
        default=4 * 1024 * 1024,
        help="Inline retained dump into spec only when file size <= this limit (default: 4MiB)",
    )
    return p.parse_args()


def canonicalize(obj: Any) -> Any:
    if isinstance(obj, dict):
        return {k: canonicalize(obj[k]) for k in sorted(obj)}
    if isinstance(obj, list):
        if all(isinstance(x, dict) for x in obj):
            c = [canonicalize(x) for x in obj]
            if all(("key" in x or "value" in x) for x in c):
                c.sort(key=lambda x: json.dumps(x, sort_keys=True, separators=(",", ":")))
            return c
        return [canonicalize(x) for x in obj]
    return obj


def stable_hash(obj: Any) -> str:
    payload = json.dumps(canonicalize(obj), sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def file_sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fp:
        while True:
            chunk = fp.read(1024 * 1024)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()


def key_repr_for_hash(key_obj: Any) -> str:
    return json.dumps(canonicalize(key_obj), sort_keys=True, separators=(",", ":"))


def key_hash(key_obj: Any) -> str:
    return hashlib.sha256(key_repr_for_hash(key_obj).encode("utf-8")).hexdigest()


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def load_json(path: Path) -> Any:
    return json.loads(path.read_text())


def sample_timestamp(sample_dir: Path) -> str:
    ts = sample_dir / "timestamp.txt"
    if ts.exists():
        return ts.read_text().strip()
    return ""


def analyze_one_map(
    map_name: str,
    map_id: int,
    map_info: Any,
    sample_dirs: list[Path],
    sampling_mode: str,
    policy_reason: str,
    final_dump_file: Path | None,
    max_inline_dump_bytes: int,
) -> tuple[dict[str, Any], dict[str, Any], dict[str, Any] | None, dict[str, Any] | None]:
    sample_total = len(sample_dirs)
    map_hashes: list[str] = []
    present_samples: list[str] = []
    missing_samples: list[str] = []
    first_map_value: Any | None = None
    entry_track: dict[str, dict[str, Any]] = {}
    hash_only_samples = 0
    hash_method = ""
    final_dump_used = False
    final_dump_hash_match = False
    final_dump_path = ""
    final_dump_bytes = 0
    map_value_inlined = False
    map_value: Any | None = None
    analysis_status = "analyzed"

    for sdir in sample_dirs:
        dump_file = sdir / f"{map_name}.json"
        hash_file = sdir / f"{map_name}.hash.json"

        if dump_file.exists():
            data = load_json(dump_file)
            present_samples.append(sdir.name)
            if first_map_value is None:
                first_map_value = data
            map_hashes.append(stable_hash(data))

            if isinstance(data, list):
                for ent in data:
                    if not isinstance(ent, dict):
                        continue
                    if "key" not in ent or "value" not in ent:
                        continue
                    key_obj = ent["key"]
                    value_obj = ent["value"]
                    k_repr = key_repr_for_hash(key_obj)
                    v_hash = stable_hash(value_obj)
                    rec = entry_track.setdefault(
                        k_repr,
                        {
                            "key": key_obj,
                            "key_hash": key_hash(key_obj),
                            "sample_names": set(),
                            "value_hashes": set(),
                            "first_value": value_obj,
                        },
                    )
                    rec["sample_names"].add(sdir.name)
                    rec["value_hashes"].add(v_hash)
            continue

        if hash_file.exists():
            raw = load_json(hash_file)
            sample_hash = str(raw.get("hash", "")).strip()
            if not sample_hash:
                missing_samples.append(sdir.name)
                continue
            present_samples.append(sdir.name)
            map_hashes.append(sample_hash)
            hash_only_samples += 1
            if not hash_method:
                hash_method = str(raw.get("method", ""))
            continue

        if sampling_mode == "hash_only":
            analysis_status = "partial"
        missing_samples.append(sdir.name)

    unique_map_hashes = sorted(set(map_hashes))
    map_invariant = len(missing_samples) == 0 and len(unique_map_hashes) == 1
    map_hash_value = unique_map_hashes[0] if len(unique_map_hashes) == 1 else ""

    map_value = first_map_value if map_invariant else None
    if map_invariant and map_value is None and final_dump_file and final_dump_file.exists():
        final_dump_used = True
        final_dump_path = str(final_dump_file)
        final_dump_bytes = final_dump_file.stat().st_size
        if map_hash_value:
            if hash_method == "raw_json_sha256":
                final_dump_hash_match = file_sha256(final_dump_file) == map_hash_value
            else:
                final_data = load_json(final_dump_file)
                final_dump_hash_match = stable_hash(final_data) == map_hash_value
        if final_dump_bytes <= max_inline_dump_bytes:
            map_value = load_json(final_dump_file)
            map_value_inlined = True

    keys_present_in_all_samples = 0
    invariant_entries: list[dict[str, Any]] = []
    for k_repr in sorted(entry_track):
        rec = entry_track[k_repr]
        in_all = len(rec["sample_names"]) == sample_total
        if in_all:
            keys_present_in_all_samples += 1
        if in_all and len(rec["value_hashes"]) == 1:
            invariant_entries.append(
                {
                    "key": rec["key"],
                    "key_hash": rec["key_hash"],
                    "value": rec["first_value"],
                    "value_hash": sorted(rec["value_hashes"])[0],
                }
            )

    map_row = {
        "map_name": map_name,
        "map_id": map_id,
        "samples_total": sample_total,
        "samples_present": len(present_samples),
        "samples_missing": len(missing_samples),
        "unique_map_hashes": len(unique_map_hashes),
        "map_invariant": int(map_invariant),
        "map_hash": map_hash_value,
        "entry_keys_union": len(entry_track),
        "entry_keys_present_in_all_samples": keys_present_in_all_samples,
        "invariant_entries": len(invariant_entries),
        "sampling_mode": sampling_mode,
        "hash_only_samples": hash_only_samples,
        "hash_method": hash_method,
        "final_dump_used": int(final_dump_used),
        "final_dump_hash_match": int(final_dump_hash_match),
        "final_dump_bytes": final_dump_bytes,
        "map_value_inlined": int(map_value_inlined),
        "analysis_status": analysis_status,
        "policy_reason": policy_reason,
    }

    map_spec = {
        "name": map_name,
        "map_id": map_id,
        "map_info": map_info,
        "sampling_mode": sampling_mode,
        "policy_reason": policy_reason,
        "samples_total": sample_total,
        "samples_present": len(present_samples),
        "samples_missing": len(missing_samples),
        "present_sample_names": present_samples,
        "missing_sample_names": missing_samples,
        "map_hashes": unique_map_hashes,
        "map_invariant": map_invariant,
        "map_hash": map_hash_value,
        "map_value": map_value,
        "hash_only_samples": hash_only_samples,
        "hash_method": hash_method,
        "final_dump_file": final_dump_path,
        "final_dump_bytes": final_dump_bytes,
        "final_dump_used": final_dump_used,
        "final_dump_hash_match": final_dump_hash_match,
        "map_value_inlined": map_value_inlined,
        "analysis_status": analysis_status,
        "entry_analysis": {
            "entry_keys_union": len(entry_track),
            "entry_keys_present_in_all_samples": keys_present_in_all_samples,
            "invariant_entry_count": len(invariant_entries),
            "invariant_entries": invariant_entries,
        },
    }

    map_level_candidate = {
        "map_name": map_name,
        "map_id": map_id,
        "map_hash": map_hash_value,
        "map_info": map_info,
        "sampling_mode": sampling_mode,
        "value": map_value,
        "value_file": final_dump_path,
        "value_inlined": map_value_inlined,
    }
    entry_level_candidate = {
        "map_name": map_name,
        "map_id": map_id,
        "map_info": map_info,
        "entries": invariant_entries,
        "entry_count": len(invariant_entries),
    }

    return map_row, map_spec, map_level_candidate, entry_level_candidate


def main() -> None:
    args = parse_args()
    samples_dir = Path(args.samples_dir)
    map_ids_file = Path(args.map_ids)
    out_spec = Path(args.output_spec)
    out_summary = Path(args.summary)
    final_dumps_dir = Path(args.final_dumps_dir) if args.final_dumps_dir else None
    max_inline_dump_bytes = int(args.max_inline_dump_bytes)

    map_ids_obj = load_json(map_ids_file)
    selected_map_ids: dict[str, int] = map_ids_obj.get("selected_map_ids", {})
    selected_maps_meta = {
        str(item.get("name")): item
        for item in map_ids_obj.get("selected_maps", [])
        if isinstance(item, dict) and item.get("name") is not None
    }
    if not selected_map_ids:
        raise SystemExit("selected_map_ids is empty")

    sample_dirs = sorted([p for p in samples_dir.iterdir() if p.is_dir() and p.name.startswith("sample-")])
    if not sample_dirs:
        raise SystemExit(f"no sample directories under {samples_dir}")

    map_rows: list[dict[str, Any]] = []
    map_specs: list[dict[str, Any]] = []
    map_level_candidates: list[dict[str, Any]] = []
    entry_level_candidates: list[dict[str, Any]] = []

    for map_name, map_id in sorted(selected_map_ids.items()):
        meta = selected_maps_meta.get(map_name, {})
        map_info = meta.get("map_info") if isinstance(meta, dict) else None
        sampling_mode = "dump"
        policy_reason = ""
        if isinstance(meta, dict):
            sampling_mode = str(meta.get("sampling_mode", "dump"))
            policy_reason = str(meta.get("policy_reason", ""))
        final_dump_file = None
        if final_dumps_dir:
            candidate = final_dumps_dir / f"{map_name}.json"
            if candidate.exists():
                final_dump_file = candidate

        row, spec, map_candidate, entry_candidate = analyze_one_map(
            map_name=map_name,
            map_id=map_id,
            map_info=map_info,
            sample_dirs=sample_dirs,
            sampling_mode=sampling_mode,
            policy_reason=policy_reason,
            final_dump_file=final_dump_file,
            max_inline_dump_bytes=max_inline_dump_bytes,
        )
        map_rows.append(row)
        map_specs.append(spec)
        if (
            map_candidate is not None
            and spec["map_invariant"]
            and (map_candidate.get("value") is not None or map_candidate.get("value_file"))
        ):
            map_level_candidates.append(map_candidate)
        if entry_candidate is not None and entry_candidate["entry_count"] > 0:
            entry_level_candidates.append(entry_candidate)

    out_summary.parent.mkdir(parents=True, exist_ok=True)
    with out_summary.open("w", newline="") as fp:
        writer = csv.DictWriter(
            fp,
            fieldnames=[
                "map_name",
                "map_id",
                "samples_total",
                "samples_present",
                "samples_missing",
                "unique_map_hashes",
                "map_invariant",
                "map_hash",
                "entry_keys_union",
                "entry_keys_present_in_all_samples",
                "invariant_entries",
                "sampling_mode",
                "hash_only_samples",
                "hash_method",
                "final_dump_used",
                "final_dump_hash_match",
                "final_dump_bytes",
                "map_value_inlined",
                "analysis_status",
                "policy_reason",
            ],
        )
        writer.writeheader()
        writer.writerows(map_rows)

    spec = {
        "format_version": 3,
        "generated_at_utc": utc_now(),
        "sample_count": len(sample_dirs),
        "samples": [
            {"name": s.name, "timestamp_utc": sample_timestamp(s)}
            for s in sample_dirs
        ],
        "selection": {
            "mode": map_ids_obj.get("selection_mode", "named"),
            "balancer_program": map_ids_obj.get("balancer_program"),
            "requested_missing": map_ids_obj.get("missing", []),
            "duplicate_map_name_ids": map_ids_obj.get("duplicates", {}),
            "dump_policy": map_ids_obj.get("dump_policy", {}),
        },
        "selected_map_ids": selected_map_ids,
        "maps": map_specs,
        "map_summary": map_rows,
        "oracle_candidates": {
            "map_level_invariants": map_level_candidates,
            "entry_level_invariants": entry_level_candidates,
            "map_level_invariant_count": len(map_level_candidates),
            "entry_level_invariant_map_count": len(entry_level_candidates),
        },
    }
    out_spec.parent.mkdir(parents=True, exist_ok=True)
    out_spec.write_text(json.dumps(spec, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
