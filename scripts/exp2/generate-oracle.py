#!/usr/bin/env python3
"""Generate Exp2 oracle hardcoded lookup data from Stage A specialization spec.

Implemented hardcode strategy (current):
  - vip_map: exact-key hardcoded lookup
  - ch_rings: active VIP ring segments hardcoded
  - reals: sparse non-zero entries + zero default (array semantics)
  - ctl_array: full array hardcoded
  - server_id_map: sparse non-zero entries + zero default (array semantics),
    or passthrough fallback when all server-id paths are compile-time disabled
  - vip_miss_stats: key-0 hardcoded
  - vip_to_down_reals_map: empty-map fast path macro

Plus compile-time policy macros derived from invariant data:
  - all-vips-no-quic
  - all-vips-no-udp-stable-routing
  - all-vips-no-udp-flow-migration
  - disable-tcp-server-id-routing
  - vip-miss-never-matches-active
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
from pathlib import Path
from typing import Any, Iterator

# Keep in sync with balancer_consts.h
F_QUIC_VIP = 1 << 2
F_UDP_STABLE_ROUTING_VIP = 1 << 8
F_UDP_FLOW_MIGRATION = 1 << 9


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Generate Exp2 oracle hardcoded data")
    p.add_argument("--spec", required=True, help="Path to specialization-spec.json from Stage A")
    p.add_argument("--output-header", required=True, help="Generated C header path")
    p.add_argument("--meta-output", default="", help="Optional JSON metadata output path")
    p.add_argument("--ring-size", type=int, default=65537, help="Katran RING_SIZE")
    p.add_argument("--vip-map-name", default="vip_map")
    p.add_argument("--ch-rings-name", default="ch_rings")
    p.add_argument("--reals-name", default="reals")
    p.add_argument("--ctl-array-name", default="ctl_array")
    p.add_argument("--server-id-map-name", default="server_id_map")
    p.add_argument("--vip-miss-stats-name", default="vip_miss_stats")
    p.add_argument("--vip-to-down-name", default="vip_to_down_rea")
    p.add_argument("--lru-mapping-name", default="lru_mapping")
    p.add_argument("--fallback-cache-name", default="fallback_cache")
    p.add_argument("--lru-miss-stats-name", default="lru_miss_stats")
    p.add_argument("--quic-stats-name", default="quic_stats_map")
    p.add_argument("--server-id-stats-name", default="server_id_stats")
    p.add_argument(
        "--max-server-id-nonzero",
        type=int,
        default=200000,
        help="Safety cap for generated sparse server_id_map switch cases",
    )
    return p.parse_args()


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def fail(msg: str) -> None:
    raise SystemExit(msg)


def read_json(path: Path) -> Any:
    return json.loads(path.read_text())


def as_int(v: Any, name: str) -> int:
    if not isinstance(v, int):
        fail(f"expected int for {name}, got {type(v).__name__}")
    return v


def parse_hex_byte(value: Any) -> int:
    if isinstance(value, int):
        if 0 <= value <= 255:
            return value
        fail(f"byte out of range: {value}")
    if not isinstance(value, str):
        fail(f"unsupported byte type: {type(value).__name__}")
    s = value.strip().lower()
    if s.startswith("0x"):
        return int(s, 16)
    return int(s)


def parse_u32_le_from_hex_bytes(data: Any) -> int:
    if not isinstance(data, list) or len(data) < 4:
        fail(f"cannot parse u32 from bytes: {data!r}")
    b0 = parse_hex_byte(data[0])
    b1 = parse_hex_byte(data[1])
    b2 = parse_hex_byte(data[2])
    b3 = parse_hex_byte(data[3])
    return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)


def parse_u64_le_from_hex_bytes(data: Any) -> int:
    if not isinstance(data, list) or len(data) < 8:
        fail(f"cannot parse u64 from bytes: {data!r}")
    value = 0
    for i in range(8):
        value |= parse_hex_byte(data[i]) << (8 * i)
    return value


def is_zero_hex_bytes(data: Any) -> bool:
    if not isinstance(data, list):
        return False
    for b in data:
        if parse_hex_byte(b) != 0:
            return False
    return True


def entry_key_u32(entry: dict[str, Any]) -> int:
    formatted = entry.get("formatted")
    if isinstance(formatted, dict):
        key = formatted.get("key")
        if isinstance(key, int):
            return key
    return parse_u32_le_from_hex_bytes(entry.get("key"))


def entry_value_u32(entry: dict[str, Any]) -> int:
    formatted = entry.get("formatted")
    if isinstance(formatted, dict):
        value = formatted.get("value")
        if isinstance(value, int):
            return value
    return parse_u32_le_from_hex_bytes(entry.get("value"))


def iter_json_array(path: Path, chunk_size: int = 4 * 1024 * 1024) -> Iterator[Any]:
    """Streaming parser for a top-level JSON array."""
    decoder = json.JSONDecoder()
    with path.open("r", encoding="utf-8") as fp:
        buf = ""
        pos = 0
        eof = False

        def fill() -> None:
            nonlocal buf, eof
            if eof:
                return
            chunk = fp.read(chunk_size)
            if chunk:
                buf += chunk
            else:
                eof = True

        fill()
        while True:
            while pos < len(buf) and buf[pos].isspace():
                pos += 1
            if pos < len(buf):
                break
            if eof:
                fail(f"invalid JSON array file (empty): {path}")
            fill()
        if pos >= len(buf) or buf[pos] != "[":
            fail(f"expected '[' at array start: {path}")
        pos += 1

        while True:
            while True:
                while pos < len(buf) and buf[pos].isspace():
                    pos += 1
                if pos < len(buf) and buf[pos] == ",":
                    pos += 1
                    continue
                break

            while pos >= len(buf):
                if eof:
                    fail(f"unexpected EOF while parsing array in {path}")
                fill()

            if buf[pos] == "]":
                return

            while True:
                try:
                    item, end = decoder.raw_decode(buf, pos)
                    break
                except json.JSONDecodeError:
                    if eof:
                        fail(f"invalid JSON syntax near offset {pos} in {path}")
                    fill()

            pos = end
            yield item

            if pos > chunk_size * 2:
                buf = buf[pos:]
                pos = 0


def find_map(spec: dict[str, Any], name: str) -> dict[str, Any]:
    for m in spec.get("maps", []):
        if isinstance(m, dict) and str(m.get("name")) == name:
            return m
    fail(f"map '{name}' not found in spec")


def resolve_map_dump_file(map_spec: dict[str, Any], spec_file: Path) -> Path | None:
    for key in ("value_file", "final_dump_file"):
        raw = str(map_spec.get(key, "")).strip()
        if not raw:
            continue
        p = Path(raw)
        if not p.is_absolute():
            p = (spec_file.parent / p).resolve()
        return p
    return None


def get_small_map_entries(map_spec: dict[str, Any], spec_file: Path) -> list[dict[str, Any]]:
    value = map_spec.get("map_value")
    if isinstance(value, list):
        return [x for x in value if isinstance(x, dict)]
    dump = resolve_map_dump_file(map_spec, spec_file)
    if dump is None:
        fail(f"map '{map_spec.get('name')}' has no inlined value and no dump file")
    data = read_json(dump)
    if not isinstance(data, list):
        fail(f"map dump is not list: {dump}")
    return [x for x in data if isinstance(x, dict)]


def extract_vip_def(obj: dict[str, Any], name: str) -> dict[str, int | list[int]]:
    base = obj.get("", obj)
    if not isinstance(base, dict):
        fail(f"invalid vip def object for {name}")
    vipv6 = base.get("vipv6")
    if not isinstance(vipv6, list) or len(vipv6) != 4:
        fail(f"invalid vipv6 for {name}")
    return {
        "vipv6": [as_int(v, f"{name}.vipv6[{i}]") for i, v in enumerate(vipv6)],
        "port": as_int(obj.get("port", 0), f"{name}.port"),
        "proto": as_int(obj.get("proto", 0), f"{name}.proto"),
    }


def vip_def_key(v: dict[str, int | list[int]]) -> tuple[int, int, int, int, int, int]:
    vv = v["vipv6"]
    assert isinstance(vv, list)
    return (
        as_int(vv[0], "vipv6[0]"),
        as_int(vv[1], "vipv6[1]"),
        as_int(vv[2], "vipv6[2]"),
        as_int(vv[3], "vipv6[3]"),
        as_int(v["port"], "port"),
        as_int(v["proto"], "proto"),
    )


def collect_vip_map(vip_entries: list[dict[str, Any]]) -> tuple[list[dict[str, Any]], list[dict[str, Any]], list[int], list[dict[str, Any]], list[int]]:
    keys: list[dict[str, Any]] = []
    values: list[dict[str, Any]] = []
    active_vips: set[int] = set()
    active_defs: list[dict[str, Any]] = []
    flags: list[int] = []

    for i, ent in enumerate(vip_entries):
        formatted = ent.get("formatted")
        if not isinstance(formatted, dict):
            fail(f"vip_map entry {i} missing formatted")
        kf = formatted.get("key")
        vf = formatted.get("value")
        if not isinstance(kf, dict) or not isinstance(vf, dict):
            fail(f"vip_map entry {i} malformed formatted key/value")
        key_def = extract_vip_def(kf, f"vip_map[{i}].key")
        val = {
            "flags": as_int(vf.get("flags"), f"vip_map[{i}].flags"),
            "vip_num": as_int(vf.get("vip_num"), f"vip_map[{i}].vip_num"),
        }
        keys.append(key_def)
        values.append(val)
        active_defs.append(key_def)
        active_vips.add(val["vip_num"])
        flags.append(val["flags"])

    if not keys:
        fail("vip_map has no entries")

    return keys, values, sorted(active_vips), active_defs, flags


def collect_ch_rings_segments(
    ch_map_spec: dict[str, Any],
    spec_path: Path,
    active_vips: list[int],
    ring_size: int,
) -> tuple[dict[int, list[int]], str]:
    segments: dict[int, list[int]] = {vip: [0] * ring_size for vip in active_vips}
    ranges = {vip: (vip * ring_size, vip * ring_size + ring_size - 1) for vip in active_vips}
    done = {vip: 0 for vip in active_vips}

    map_value = ch_map_spec.get("map_value")
    if isinstance(map_value, list):
        source = "inlined"
        iterator: Iterator[Any] = iter(map_value)
    else:
        dump = resolve_map_dump_file(ch_map_spec, spec_path)
        if dump is None:
            fail("ch_rings has no inlined value and no dump file")
        if not dump.exists():
            fail(f"ch_rings dump file not found: {dump}")
        source = str(dump)
        iterator = iter_json_array(dump)

    max_needed_key = max(end for _, end in ranges.values())
    for item in iterator:
        if not isinstance(item, dict):
            continue
        key = entry_key_u32(item)
        if key > max_needed_key and source != "inlined":
            break
        value = entry_value_u32(item)
        for vip, (start, end) in ranges.items():
            if start <= key <= end:
                idx = key - start
                segments[vip][idx] = value
                done[vip] += 1
                break

    for vip in active_vips:
        if done[vip] != ring_size:
            fail(
                f"ch_rings segment incomplete for vip_num={vip}: "
                f"expected {ring_size}, got {done[vip]}"
            )

    return segments, source


def collect_reals_sparse(
    reals_entries: list[dict[str, Any]],
    max_entries: int,
) -> list[tuple[int, dict[str, Any]]]:
    sparse: list[tuple[int, dict[str, Any]]] = []
    for i, ent in enumerate(reals_entries):
        formatted = ent.get("formatted")
        if not isinstance(formatted, dict):
            continue
        key = entry_key_u32(ent)
        value = formatted.get("value")
        if not isinstance(value, dict):
            fail(f"reals entry {i} missing formatted.value")
        base = value.get("", {})
        if not isinstance(base, dict):
            fail(f"reals entry {i} invalid base value")
        dstv6 = base.get("dstv6")
        if not isinstance(dstv6, list) or len(dstv6) != 4:
            fail(f"reals entry {i} invalid dstv6")
        real_def = {
            "dstv6": [as_int(v, f"reals[{i}].dstv6[{j}]") for j, v in enumerate(dstv6)],
            "flags": as_int(value.get("flags", 0), f"reals[{i}].flags"),
        }
        non_zero = real_def["flags"] != 0 or any(int(v) != 0 for v in real_def["dstv6"])
        if non_zero:
            if key < 0 or key >= max_entries:
                fail(f"reals key out of range: {key} (max={max_entries})")
            sparse.append((key, real_def))
    sparse.sort(key=lambda x: x[0])
    return sparse


def collect_ctl_array(entries: list[dict[str, Any]], max_entries: int) -> list[int]:
    arr = [0] * max_entries
    for i, ent in enumerate(entries):
        key = entry_key_u32(ent)
        if key < 0 or key >= max_entries:
            fail(f"ctl_array key out of range: {key} (max={max_entries})")
        value_u64 = parse_u64_le_from_hex_bytes(ent.get("value"))
        arr[key] = value_u64
    return arr


def collect_vip_miss(vip_miss_entries: list[dict[str, Any]]) -> dict[str, Any] | None:
    if not vip_miss_entries:
        return None
    # Expected array[1], key 0.
    ent = vip_miss_entries[0]
    formatted = ent.get("formatted")
    if not isinstance(formatted, dict):
        return None
    value = formatted.get("value")
    if not isinstance(value, dict):
        return None
    return extract_vip_def(value, "vip_miss_stats.value")


def collect_server_id_sparse(
    server_map_spec: dict[str, Any],
    spec_path: Path,
    max_nonzero: int,
) -> tuple[int, list[tuple[int, int]], str]:
    map_info = server_map_spec.get("map_info")
    if not isinstance(map_info, dict):
        fail("server_id_map missing map_info")
    max_entries = as_int(map_info.get("max_entries"), "server_id_map.max_entries")

    value = server_map_spec.get("map_value")
    if isinstance(value, list):
        source = "inlined"
        iterator: Iterator[Any] = iter(value)
    else:
        dump = resolve_map_dump_file(server_map_spec, spec_path)
        if dump is None:
            fail("server_id_map has no inlined value and no dump file")
        if not dump.exists():
            fail(f"server_id_map dump file not found: {dump}")
        source = str(dump)
        iterator = iter_json_array(dump)

    sparse: list[tuple[int, int]] = []
    for item in iterator:
        if not isinstance(item, dict):
            continue
        key = entry_key_u32(item)
        value_u32 = entry_value_u32(item)
        if value_u32 != 0:
            if key < 0 or key >= max_entries:
                fail(f"server_id_map key out of range: {key} (max={max_entries})")
            sparse.append((key, value_u32))
            if len(sparse) > max_nonzero:
                fail(
                    f"server_id_map non-zero entries exceed cap {max_nonzero}; "
                    "increase --max-server-id-nonzero"
                )
    sparse.sort(key=lambda x: x[0])
    return max_entries, sparse, source


def is_percpu_map_all_zero(entries: list[dict[str, Any]]) -> bool:
    for ent in entries:
        if "values" in ent and isinstance(ent["values"], list):
            for cpu_ent in ent["values"]:
                if not isinstance(cpu_ent, dict):
                    return False
                if not is_zero_hex_bytes(cpu_ent.get("value")):
                    return False
        elif "value" in ent:
            if not is_zero_hex_bytes(ent.get("value")):
                return False
        else:
            return False
    return True


def c_u32(v: int) -> str:
    return f"{v}u"


def c_u64(v: int) -> str:
    return f"{v}ULL"


def init_vip_def(v: dict[str, Any]) -> str:
    vv = v["vipv6"]
    assert isinstance(vv, list)
    return (
        "{ .vipv6 = { "
        + ", ".join(c_u32(as_int(x, "vipv6")) for x in vv)
        + f" }}, .port = {c_u32(as_int(v['port'], 'port'))}, .proto = {c_u32(as_int(v['proto'], 'proto'))} }}"
    )


def init_vip_meta(v: dict[str, Any]) -> str:
    return (
        "{ "
        + f".flags = {c_u32(as_int(v['flags'], 'flags'))}, "
        + f".vip_num = {c_u32(as_int(v['vip_num'], 'vip_num'))} "
        + "}"
    )


def init_real_def(v: dict[str, Any]) -> str:
    vv = v["dstv6"]
    assert isinstance(vv, list)
    return (
        "{ .dstv6 = { "
        + ", ".join(c_u32(as_int(x, "dstv6")) for x in vv)
        + f" }}, .flags = {c_u32(as_int(v['flags'], 'flags'))} }}"
    )


def write_values_array(fp, arr: list[int], per_line: int = 16, indent: str = "  ") -> None:
    total = len(arr)
    for i in range(0, total, per_line):
        chunk = arr[i : i + per_line]
        suffix = "," if i + per_line < total else ""
        fp.write(indent + ", ".join(c_u32(x) for x in chunk) + suffix + "\n")


def generate_header(
    output: Path,
    spec_path: Path,
    ring_size: int,
    vip_keys: list[dict[str, Any]],
    vip_values: list[dict[str, Any]],
    active_vips: list[int],
    vip_flags: list[int],
    ch_segments: dict[int, list[int]],
    reals_max_entries: int,
    reals_sparse: list[tuple[int, dict[str, Any]]],
    ctl_values: list[int],
    server_id_max_entries: int,
    server_id_sparse: list[tuple[int, int]],
    server_id_lookup_passthrough: bool,
    vip_miss_value: dict[str, Any] | None,
    vip_to_down_empty: bool,
    lru_mapping_invariant: bool,
    fallback_cache_empty: bool,
    lru_miss_all_zero: bool,
    quic_stats_all_zero: bool,
    server_id_stats_all_zero: bool,
    disable_tcp_server_id_routing: bool,
) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)

    all_vips_no_quic = 1 if all((f & F_QUIC_VIP) == 0 for f in vip_flags) else 0
    all_vips_no_udp_stable = 1 if all((f & F_UDP_STABLE_ROUTING_VIP) == 0 for f in vip_flags) else 0
    all_vips_no_udp_mig = 1 if all((f & F_UDP_FLOW_MIGRATION) == 0 for f in vip_flags) else 0

    active_vip_keys = {vip_def_key(v) for v in vip_keys}
    vip_miss_never_match_active = 0
    if vip_miss_value is not None:
        vip_miss_never_match_active = 1 if vip_def_key(vip_miss_value) not in active_vip_keys else 0

    with output.open("w", encoding="utf-8") as fp:
        fp.write("#ifndef KATRAN_EXP2_ORACLE_GENERATED_H\n")
        fp.write("#define KATRAN_EXP2_ORACLE_GENERATED_H\n\n")
        fp.write("/*\n")
        fp.write(" * Auto-generated by scripts/exp2/generate-oracle.py\n")
        fp.write(f" * source spec: {spec_path}\n")
        fp.write(f" * generated at: {utc_now()}\n")
        fp.write(" */\n\n")

        fp.write(f"#define EXP2_ORACLE_ACTIVE_VIP_COUNT {len(active_vips)}\n")
        fp.write(f"#define EXP2_ORACLE_RING_SIZE {ring_size}\n")
        fp.write(f"#define EXP2_ORACLE_ALL_VIPS_NO_QUIC {all_vips_no_quic}\n")
        fp.write(f"#define EXP2_ORACLE_ALL_VIPS_NO_UDP_STABLE_ROUTING {all_vips_no_udp_stable}\n")
        fp.write(f"#define EXP2_ORACLE_ALL_VIPS_NO_UDP_FLOW_MIGRATION {all_vips_no_udp_mig}\n")
        fp.write(f"#define EXP2_ORACLE_VIP_TO_DOWN_REALS_EMPTY {1 if vip_to_down_empty else 0}\n")
        fp.write(f"#define EXP2_ORACLE_VIP_MISS_NEVER_MATCH_ACTIVE {vip_miss_never_match_active}\n")
        fp.write(
            f"#define EXP2_ORACLE_DISABLE_TCP_SERVER_ID_ROUTING "
            f"{1 if disable_tcp_server_id_routing else 0}\n"
        )
        fp.write(f"#define EXP2_ORACLE_LRU_MAPPING_INVARIANT {1 if lru_mapping_invariant else 0}\n")
        fp.write(f"#define EXP2_ORACLE_FALLBACK_CACHE_EMPTY {1 if fallback_cache_empty else 0}\n")
        fp.write(f"#define EXP2_ORACLE_LRU_MISS_STATS_ALL_ZERO {1 if lru_miss_all_zero else 0}\n")
        fp.write(f"#define EXP2_ORACLE_QUIC_STATS_ALL_ZERO {1 if quic_stats_all_zero else 0}\n")
        fp.write(f"#define EXP2_ORACLE_SERVER_ID_STATS_ALL_ZERO {1 if server_id_stats_all_zero else 0}\n\n")

        # vip_map
        fp.write(f"static const struct vip_definition exp2_oracle_vip_map_keys[{len(vip_keys)}] = {{\n")
        for i, v in enumerate(vip_keys):
            fp.write(f"  [{i}] = {init_vip_def(v)},\n")
        fp.write("};\n")
        fp.write(f"static const struct vip_meta exp2_oracle_vip_map_values[{len(vip_values)}] = {{\n")
        for i, v in enumerate(vip_values):
            fp.write(f"  [{i}] = {init_vip_meta(v)},\n")
        fp.write("};\n\n")

        fp.write("__attribute__((__always_inline__)) static inline bool\n")
        fp.write("exp2_oracle_lookup_vip_map(const struct vip_definition* key, const struct vip_meta** value) {\n")
        fp.write("  if (!key || !value) {\n")
        fp.write("    return false;\n")
        fp.write("  }\n")
        for i, v in enumerate(vip_keys):
            vv = v["vipv6"]
            assert isinstance(vv, list)
            fp.write(
                "  if ("
                + f"key->vipv6[0] == {c_u32(as_int(vv[0], 'vipv6[0]'))} && "
                + f"key->vipv6[1] == {c_u32(as_int(vv[1], 'vipv6[1]'))} && "
                + f"key->vipv6[2] == {c_u32(as_int(vv[2], 'vipv6[2]'))} && "
                + f"key->vipv6[3] == {c_u32(as_int(vv[3], 'vipv6[3]'))} && "
                + f"key->port == {c_u32(as_int(v['port'], 'port'))} && "
                + f"key->proto == {c_u32(as_int(v['proto'], 'proto'))}"
                + ") {\n"
            )
            fp.write(f"    *value = &exp2_oracle_vip_map_values[{i}];\n")
            fp.write("    return true;\n")
            fp.write("  }\n")
        fp.write("  return false;\n")
        fp.write("}\n\n")

        # ch_rings
        fp.write("#ifndef EXP2_ORACLE_DISABLE_CH_RING_HARDCODE\n")
        for vip in active_vips:
            fp.write(f"static const __u32 exp2_oracle_ring_vip_{vip}[EXP2_ORACLE_RING_SIZE] = {{\n")
            write_values_array(fp, ch_segments[vip])
            fp.write("};\n\n")

        fp.write("__attribute__((__always_inline__)) static inline bool\n")
        fp.write("exp2_oracle_lookup_ch_ring(__u32 vip_num, __u32 hash, __u32* real_pos) {\n")
        fp.write("  if (!real_pos) {\n")
        fp.write("    return false;\n")
        fp.write("  }\n")
        fp.write("  __u32 idx = hash % EXP2_ORACLE_RING_SIZE;\n")
        fp.write("  switch (vip_num) {\n")
        for vip in active_vips:
            fp.write(f"  case {c_u32(vip)}:\n")
            fp.write(f"    *real_pos = exp2_oracle_ring_vip_{vip}[idx];\n")
            fp.write("    return true;\n")
        fp.write("  default:\n")
        fp.write("    return false;\n")
        fp.write("  }\n")
        fp.write("}\n")
        fp.write("#else\n")
        fp.write("__attribute__((__always_inline__)) static inline bool\n")
        fp.write("exp2_oracle_lookup_ch_ring(__u32 vip_num, __u32 hash, __u32* real_pos) {\n")
        fp.write("  (void)vip_num;\n")
        fp.write("  (void)hash;\n")
        fp.write("  (void)real_pos;\n")
        fp.write("  return false;\n")
        fp.write("}\n")
        fp.write("#endif\n\n")

        # reals sparse
        fp.write(f"#define EXP2_ORACLE_REALS_MAX_ENTRIES {reals_max_entries}\n")
        fp.write(f"#define EXP2_ORACLE_REALS_NONZERO_COUNT {len(reals_sparse)}\n")
        fp.write("static const struct real_definition exp2_oracle_real_zero = { .dstv6 = { 0u, 0u, 0u, 0u }, .flags = 0u };\n")
        for key, rv in reals_sparse:
            fp.write(f"static const struct real_definition exp2_oracle_real_{key} = {init_real_def(rv)};\n")
        fp.write("\n")
        fp.write("__attribute__((__always_inline__)) static inline bool\n")
        fp.write("exp2_oracle_lookup_reals(__u32 key, const struct real_definition** value) {\n")
        fp.write("  if (!value) {\n")
        fp.write("    return false;\n")
        fp.write("  }\n")
        fp.write("  if (key >= EXP2_ORACLE_REALS_MAX_ENTRIES) {\n")
        fp.write("    return false;\n")
        fp.write("  }\n")
        if reals_sparse:
            fp.write("  switch (key) {\n")
            for key, _ in reals_sparse:
                fp.write(f"  case {c_u32(key)}:\n")
                fp.write(f"    *value = &exp2_oracle_real_{key};\n")
                fp.write("    return true;\n")
            fp.write("  default:\n")
            fp.write("    *value = &exp2_oracle_real_zero;\n")
            fp.write("    return true;\n")
            fp.write("  }\n")
        else:
            fp.write("  *value = &exp2_oracle_real_zero;\n")
            fp.write("  return true;\n")
        fp.write("}\n\n")

        # ctl_array
        fp.write(f"#define EXP2_ORACLE_CTL_ARRAY_MAX_ENTRIES {len(ctl_values)}\n")
        fp.write("static const struct ctl_value exp2_oracle_ctl_array[EXP2_ORACLE_CTL_ARRAY_MAX_ENTRIES] = {\n")
        for i, v in enumerate(ctl_values):
            fp.write(f"  [{i}] = {{ .value = {c_u64(v)} }},\n")
        fp.write("};\n\n")
        fp.write("__attribute__((__always_inline__)) static inline bool\n")
        fp.write("exp2_oracle_lookup_ctl_array(__u32 key, const struct ctl_value** value) {\n")
        fp.write("  if (!value) {\n")
        fp.write("    return false;\n")
        fp.write("  }\n")
        fp.write("  if (key >= EXP2_ORACLE_CTL_ARRAY_MAX_ENTRIES) {\n")
        fp.write("    return false;\n")
        fp.write("  }\n")
        fp.write("  *value = &exp2_oracle_ctl_array[key];\n")
        fp.write("  return true;\n")
        fp.write("}\n\n")

        # server_id_map sparse
        fp.write(f"#define EXP2_ORACLE_SERVER_ID_MAP_MAX_ENTRIES {server_id_max_entries}\n")
        fp.write(f"#define EXP2_ORACLE_SERVER_ID_MAP_NONZERO_COUNT {len(server_id_sparse)}\n")
        fp.write(
            f"#define EXP2_ORACLE_SERVER_ID_MAP_LOOKUP_PASSTHROUGH "
            f"{1 if server_id_lookup_passthrough else 0}\n"
        )
        fp.write("__attribute__((__always_inline__)) static inline bool\n")
        fp.write("exp2_oracle_lookup_server_id_map(__u32 key, __u32* value) {\n")
        if server_id_lookup_passthrough:
            fp.write("  (void)key;\n")
            fp.write("  (void)value;\n")
            fp.write("  return false;\n")
            fp.write("}\n\n")
        else:
            fp.write("  if (!value) {\n")
            fp.write("    return false;\n")
            fp.write("  }\n")
            fp.write("  if (key >= EXP2_ORACLE_SERVER_ID_MAP_MAX_ENTRIES) {\n")
            fp.write("    return false;\n")
            fp.write("  }\n")
            if server_id_sparse:
                fp.write("  switch (key) {\n")
                for key, val in server_id_sparse:
                    fp.write(f"  case {c_u32(key)}:\n")
                    fp.write(f"    *value = {c_u32(val)};\n")
                    fp.write("    return true;\n")
                fp.write("  default:\n")
                fp.write("    *value = 0u;\n")
                fp.write("    return true;\n")
                fp.write("  }\n")
            else:
                fp.write("  *value = 0u;\n")
                fp.write("  return true;\n")
            fp.write("}\n\n")

        # vip_miss_stats
        if vip_miss_value is not None:
            fp.write(f"static const struct vip_definition exp2_oracle_vip_miss_stats_0 = {init_vip_def(vip_miss_value)};\n")
            fp.write("__attribute__((__always_inline__)) static inline bool\n")
            fp.write("exp2_oracle_lookup_vip_miss_stats(__u32 key, const struct vip_definition** value) {\n")
            fp.write("  if (!value) {\n")
            fp.write("    return false;\n")
            fp.write("  }\n")
            fp.write("  if (key != 0u) {\n")
            fp.write("    return false;\n")
            fp.write("  }\n")
            fp.write("  *value = &exp2_oracle_vip_miss_stats_0;\n")
            fp.write("  return true;\n")
            fp.write("}\n")
        else:
            fp.write("__attribute__((__always_inline__)) static inline bool\n")
            fp.write("exp2_oracle_lookup_vip_miss_stats(__u32 key, const struct vip_definition** value) {\n")
            fp.write("  (void)key;\n")
            fp.write("  (void)value;\n")
            fp.write("  return false;\n")
            fp.write("}\n")

        fp.write("\n#endif\n")


def write_meta(meta_path: Path, payload: dict[str, Any]) -> None:
    meta_path.parent.mkdir(parents=True, exist_ok=True)
    meta_path.write_text(json.dumps(payload, indent=2, sort_keys=True))


def main() -> None:
    args = parse_args()
    spec_path = Path(args.spec).resolve()
    output_header = Path(args.output_header).resolve()
    ring_size = int(args.ring_size)
    if ring_size <= 0:
        fail("--ring-size must be positive")

    spec = read_json(spec_path)

    # Required invariant maps
    vip_map_spec = find_map(spec, args.vip_map_name)
    ch_rings_spec = find_map(spec, args.ch_rings_name)
    reals_spec = find_map(spec, args.reals_name)
    ctl_spec = find_map(spec, args.ctl_array_name)
    server_id_spec = find_map(spec, args.server_id_map_name)
    vip_miss_spec = find_map(spec, args.vip_miss_stats_name)
    vip_to_down_spec = find_map(spec, args.vip_to_down_name)

    for name, m in [
        (args.vip_map_name, vip_map_spec),
        (args.ch_rings_name, ch_rings_spec),
        (args.reals_name, reals_spec),
        (args.ctl_array_name, ctl_spec),
        (args.server_id_map_name, server_id_spec),
        (args.vip_miss_stats_name, vip_miss_spec),
        (args.vip_to_down_name, vip_to_down_spec),
    ]:
        if not m.get("map_invariant"):
            fail(f"required invariant map '{name}' is not invariant in spec")

    vip_entries = get_small_map_entries(vip_map_spec, spec_path)
    vip_keys, vip_vals, active_vips, active_defs, vip_flags = collect_vip_map(vip_entries)

    ch_segments, ch_source = collect_ch_rings_segments(ch_rings_spec, spec_path, active_vips, ring_size)

    reals_entries = get_small_map_entries(reals_spec, spec_path)
    reals_info = reals_spec.get("map_info") if isinstance(reals_spec.get("map_info"), dict) else {}
    reals_max_entries = as_int(reals_info.get("max_entries"), "reals.max_entries")
    reals_sparse = collect_reals_sparse(reals_entries, reals_max_entries)

    ctl_entries = get_small_map_entries(ctl_spec, spec_path)
    ctl_info = ctl_spec.get("map_info") if isinstance(ctl_spec.get("map_info"), dict) else {}
    ctl_max_entries = as_int(ctl_info.get("max_entries"), "ctl_array.max_entries")
    ctl_values = collect_ctl_array(ctl_entries, ctl_max_entries)

    vip_miss_entries = get_small_map_entries(vip_miss_spec, spec_path)
    vip_miss_value = collect_vip_miss(vip_miss_entries)

    vip_to_down_entries = get_small_map_entries(vip_to_down_spec, spec_path)
    vip_to_down_empty = len(vip_to_down_entries) == 0

    # Additional invariant maps for strategy macros/reporting
    lru_mapping_spec = find_map(spec, args.lru_mapping_name)
    fallback_cache_spec = find_map(spec, args.fallback_cache_name)
    lru_miss_spec = find_map(spec, args.lru_miss_stats_name)
    quic_stats_spec = find_map(spec, args.quic_stats_name)
    server_id_stats_spec = find_map(spec, args.server_id_stats_name)

    lru_mapping_invariant = bool(lru_mapping_spec.get("map_invariant"))
    fallback_cache_entries = get_small_map_entries(fallback_cache_spec, spec_path)
    fallback_cache_empty = len(fallback_cache_entries) == 0

    lru_miss_entries = get_small_map_entries(lru_miss_spec, spec_path)
    quic_stats_entries = get_small_map_entries(quic_stats_spec, spec_path)
    server_id_stats_entries = get_small_map_entries(server_id_stats_spec, spec_path)

    lru_miss_all_zero = is_percpu_map_all_zero(lru_miss_entries)
    quic_stats_all_zero = is_percpu_map_all_zero(quic_stats_entries)
    server_id_stats_all_zero = is_percpu_map_all_zero(server_id_stats_entries)

    all_vips_no_quic = all((f & F_QUIC_VIP) == 0 for f in vip_flags)
    all_vips_no_udp_stable = all((f & F_UDP_STABLE_ROUTING_VIP) == 0 for f in vip_flags)
    all_vips_no_udp_mig = all((f & F_UDP_FLOW_MIGRATION) == 0 for f in vip_flags)

    # If QUIC + UDP stable routing paths are both disabled for all active VIPs,
    # and server-id stats are invariant zero, treat TCP server-id routing as
    # workload-unreachable in Oracle and avoid scanning 1.9GB server_id dumps.
    disable_tcp_server_id_routing = bool(server_id_stats_all_zero)
    server_id_lookup_passthrough = bool(
        all_vips_no_quic and all_vips_no_udp_stable and disable_tcp_server_id_routing
    )

    if server_id_lookup_passthrough:
        server_map_info = (
            server_id_spec.get("map_info")
            if isinstance(server_id_spec.get("map_info"), dict)
            else {}
        )
        server_id_max_entries = as_int(
            server_map_info.get("max_entries"),
            "server_id_map.max_entries",
        )
        server_id_sparse: list[tuple[int, int]] = []
        server_id_source = "skipped: server-id lookup paths compile-time disabled"
    else:
        server_id_max_entries, server_id_sparse, server_id_source = collect_server_id_sparse(
            server_id_spec,
            spec_path,
            args.max_server_id_nonzero,
        )

    generate_header(
        output=output_header,
        spec_path=spec_path,
        ring_size=ring_size,
        vip_keys=vip_keys,
        vip_values=vip_vals,
        active_vips=active_vips,
        vip_flags=vip_flags,
        ch_segments=ch_segments,
        reals_max_entries=reals_max_entries,
        reals_sparse=reals_sparse,
        ctl_values=ctl_values,
        server_id_max_entries=server_id_max_entries,
        server_id_sparse=server_id_sparse,
        server_id_lookup_passthrough=server_id_lookup_passthrough,
        vip_miss_value=vip_miss_value,
        vip_to_down_empty=vip_to_down_empty,
        lru_mapping_invariant=lru_mapping_invariant,
        fallback_cache_empty=fallback_cache_empty,
        lru_miss_all_zero=lru_miss_all_zero,
        quic_stats_all_zero=quic_stats_all_zero,
        server_id_stats_all_zero=server_id_stats_all_zero,
        disable_tcp_server_id_routing=disable_tcp_server_id_routing,
    )

    if args.meta_output:
        active_vip_keys = {vip_def_key(v) for v in active_defs}
        vip_miss_never_match_active = (
            vip_miss_value is not None and vip_def_key(vip_miss_value) not in active_vip_keys
        )

        write_meta(
            Path(args.meta_output).resolve(),
            {
                "generated_at_utc": utc_now(),
                "spec_file": str(spec_path),
                "header_file": str(output_header),
                "active_vips": active_vips,
                "ring_size": ring_size,
                "sources": {
                    "ch_rings": ch_source,
                    "server_id_map": server_id_source,
                },
                "hardcode_summary": {
                    "vip_map_entries": len(vip_keys),
                    "ch_rings_active_vip_count": len(active_vips),
                    "reals_nonzero_entries": len(reals_sparse),
                    "reals_max_entries": reals_max_entries,
                    "ctl_array_entries": len(ctl_values),
                    "server_id_nonzero_entries": len(server_id_sparse),
                    "server_id_max_entries": server_id_max_entries,
                    "server_id_lookup_passthrough": server_id_lookup_passthrough,
                    "vip_to_down_reals_empty": vip_to_down_empty,
                },
                "derived_policy": {
                    "all_vips_no_quic": all_vips_no_quic,
                    "all_vips_no_udp_stable_routing": all_vips_no_udp_stable,
                    "all_vips_no_udp_flow_migration": all_vips_no_udp_mig,
                    "disable_tcp_server_id_routing": disable_tcp_server_id_routing,
                    "vip_miss_never_match_active": vip_miss_never_match_active,
                    "lru_mapping_invariant": lru_mapping_invariant,
                    "fallback_cache_empty": fallback_cache_empty,
                    "lru_miss_stats_all_zero": lru_miss_all_zero,
                    "quic_stats_all_zero": quic_stats_all_zero,
                    "server_id_stats_all_zero": server_id_stats_all_zero,
                },
            },
        )


if __name__ == "__main__":
    main()
