#!/usr/bin/env python3

import argparse
import csv
import math
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


RUN_KIND_TITLE = {
    "direct-nginx": "Direct Nginx",
    "vanilla-katran": "Vanilla Katran",
}


def read_csv_rows(path: Path):
    with path.open("r", newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def parse_float(value: str, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def parse_int(value: str, default: int = 0) -> int:
    try:
        return int(float(value))
    except (TypeError, ValueError):
        return default


def read_run_config(run_dir: Path):
    cfg = {}
    cfg_path = run_dir / "metadata" / "run-config.env"
    if not cfg_path.exists():
        return cfg
    for line in cfg_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        cfg[key.strip()] = value.strip()
    return cfg


def aggregate_by_key(rows, key_field, metric_fields):
    stats = {}
    for row in rows:
        key = parse_int(row.get(key_field))
        stats.setdefault(key, {"n": 0})
        stats[key]["n"] += 1

        for out_name, src_name in metric_fields.items():
            val = parse_float(row.get(src_name))
            sum_key = f"{out_name}_sum"
            sq_key = f"{out_name}_sq"
            stats[key][sum_key] = stats[key].get(sum_key, 0.0) + val
            stats[key][sq_key] = stats[key].get(sq_key, 0.0) + val * val

    points = []
    for key, stat in stats.items():
        n = max(stat["n"], 1)
        point = {"key": key, "n": n}
        for out_name in metric_fields:
            mean = stat[f"{out_name}_sum"] / n
            var = (stat[f"{out_name}_sq"] / n) - (mean * mean)
            if var < 0:
                var = 0
            point[f"{out_name}_mean"] = mean
            point[f"{out_name}_std"] = math.sqrt(var)
        points.append(point)

    points.sort(key=lambda x: x["key"])
    return points


def load_wrk_points(run_dir: Path):
    wrk_summary = run_dir / "wrk-summary.csv"
    wrk_agg = run_dir / "wrk-summary-agg.csv"

    if wrk_summary.exists():
        rows = read_csv_rows(wrk_summary)
        if not rows:
            return None
        has_vm_util = "vm1_cpu_util_pct" in rows[0] and "vm2_cpu_util_pct" in rows[0]
        metric_fields = {"rps": "requests_per_sec", "p99": "p99_ms"}
        if has_vm_util:
            metric_fields["vm1_cpu"] = "vm1_cpu_util_pct"
            metric_fields["vm2_cpu"] = "vm2_cpu_util_pct"
        points = aggregate_by_key(rows, key_field="connections", metric_fields=metric_fields)
        if not points:
            return None

        out = {
            "connections": [p["key"] for p in points],
            "rps_mean": [p["rps_mean"] for p in points],
            "rps_std": [p["rps_std"] for p in points],
            "p99_mean": [p["p99_mean"] for p in points],
            "p99_std": [p["p99_std"] for p in points],
            "has_vm_util": has_vm_util,
        }
        if has_vm_util:
            out["vm1_cpu_mean"] = [p["vm1_cpu_mean"] for p in points]
            out["vm1_cpu_std"] = [p["vm1_cpu_std"] for p in points]
            out["vm2_cpu_mean"] = [p["vm2_cpu_mean"] for p in points]
            out["vm2_cpu_std"] = [p["vm2_cpu_std"] for p in points]
        else:
            out["vm1_cpu_mean"] = []
            out["vm1_cpu_std"] = []
            out["vm2_cpu_mean"] = []
            out["vm2_cpu_std"] = []
        return out

    if not wrk_agg.exists():
        return None

    rows = read_csv_rows(wrk_agg)
    if not rows:
        return None

    points = []
    for row in rows:
        conn = parse_int(row.get("connections"))
        rps = parse_float(row.get("rps_mean"))
        p99 = parse_float(row.get("p99_ms_mean"))
        vm1 = parse_float(row.get("vm1_cpu_util_pct_mean"))
        vm2 = parse_float(row.get("vm2_cpu_util_pct_mean"))
        points.append((conn, rps, p99, vm1, vm2))
    points.sort(key=lambda x: x[0])

    has_vm_util = "vm1_cpu_util_pct_mean" in rows[0] and "vm2_cpu_util_pct_mean" in rows[0]
    return {
        "connections": [p[0] for p in points],
        "rps_mean": [p[1] for p in points],
        "rps_std": [0.0 for _ in points],
        "p99_mean": [p[2] for p in points],
        "p99_std": [0.0 for _ in points],
        "has_vm_util": has_vm_util,
        "vm1_cpu_mean": [p[3] for p in points],
        "vm1_cpu_std": [0.0 for _ in points],
        "vm2_cpu_mean": [p[4] for p in points],
        "vm2_cpu_std": [0.0 for _ in points],
    }


def plot_single_run(run_dir: Path, plots_dir: Path):
    data = load_wrk_points(run_dir)
    if not data:
        return []

    cfg = read_run_config(run_dir)
    run_kind = cfg.get("run_kind", "unknown")
    run_title = RUN_KIND_TITLE.get(run_kind, run_kind)

    conns = data["connections"]
    rps_vals = data["rps_mean"]
    rps_std = data["rps_std"]
    p99_vals = data["p99_mean"]
    p99_std = data["p99_std"]

    if data["has_vm_util"]:
        fig, ((ax_rps, ax_p99), (ax_vm1, ax_vm2)) = plt.subplots(2, 2, figsize=(12, 8.0))
    else:
        fig, (ax_rps, ax_p99) = plt.subplots(1, 2, figsize=(12, 4.5))
        ax_vm1 = None
        ax_vm2 = None

    ax_rps.errorbar(conns, rps_vals, yerr=rps_std, marker="o", linewidth=2, capsize=3)
    ax_rps.set_title("wrk Throughput")
    ax_rps.set_xlabel("Connections")
    ax_rps.set_ylabel("Requests/sec")
    ax_rps.grid(True, linestyle="--", alpha=0.4)

    ax_p99.errorbar(conns, p99_vals, yerr=p99_std, marker="o", linewidth=2, color="tab:orange", capsize=3)
    ax_p99.set_title("wrk p99 Latency")
    ax_p99.set_xlabel("Connections")
    ax_p99.set_ylabel("p99 latency (ms)")
    ax_p99.grid(True, linestyle="--", alpha=0.4)

    if data["has_vm_util"] and ax_vm1 is not None and ax_vm2 is not None:
        ax_vm1.errorbar(
            conns,
            data["vm1_cpu_mean"],
            yerr=data["vm1_cpu_std"],
            marker="o",
            linewidth=2,
            color="tab:green",
            capsize=3,
        )
        ax_vm1.set_title("vm1 CPU Utilization")
        ax_vm1.set_xlabel("Connections")
        ax_vm1.set_ylabel("CPU util (%)")
        ax_vm1.set_ylim(0, 100)
        ax_vm1.grid(True, linestyle="--", alpha=0.4)

        ax_vm2.errorbar(
            conns,
            data["vm2_cpu_mean"],
            yerr=data["vm2_cpu_std"],
            marker="o",
            linewidth=2,
            color="tab:red",
            capsize=3,
        )
        ax_vm2.set_title("vm2 CPU Utilization")
        ax_vm2.set_xlabel("Connections")
        ax_vm2.set_ylabel("CPU util (%)")
        ax_vm2.set_ylim(0, 100)
        ax_vm2.grid(True, linestyle="--", alpha=0.4)

    fig.suptitle(f"Experiment 1 ({run_title})")
    fig.tight_layout()

    out = plots_dir / "wrk-overview.png"
    fig.savefig(out, dpi=180)
    plt.close(fig)
    return [out]


def plot_compare(direct_dir: Path, katran_dir: Path, out_dir: Path):
    direct = load_wrk_points(direct_dir)
    katran = load_wrk_points(katran_dir)
    if not direct or not katran:
        return []

    plots_dir = out_dir / "plots"
    plots_dir.mkdir(parents=True, exist_ok=True)

    fig, (ax_rps, ax_p99) = plt.subplots(1, 2, figsize=(12, 4.8))

    ax_rps.errorbar(
        direct["connections"],
        direct["rps_mean"],
        yerr=direct["rps_std"],
        marker="o",
        linewidth=2,
        capsize=3,
        label="Direct Nginx",
    )
    ax_rps.errorbar(
        katran["connections"],
        katran["rps_mean"],
        yerr=katran["rps_std"],
        marker="o",
        linewidth=2,
        capsize=3,
        label="Vanilla Katran",
    )
    ax_rps.set_title("Throughput Comparison")
    ax_rps.set_xlabel("Connections")
    ax_rps.set_ylabel("Requests/sec")
    ax_rps.grid(True, linestyle="--", alpha=0.4)
    ax_rps.legend()

    ax_p99.errorbar(
        direct["connections"],
        direct["p99_mean"],
        yerr=direct["p99_std"],
        marker="o",
        linewidth=2,
        capsize=3,
        label="Direct Nginx",
    )
    ax_p99.errorbar(
        katran["connections"],
        katran["p99_mean"],
        yerr=katran["p99_std"],
        marker="o",
        linewidth=2,
        capsize=3,
        label="Vanilla Katran",
    )
    ax_p99.set_title("p99 Latency Comparison")
    ax_p99.set_xlabel("Connections")
    ax_p99.set_ylabel("p99 latency (ms)")
    ax_p99.grid(True, linestyle="--", alpha=0.4)
    ax_p99.legend()

    fig.suptitle("Experiment 1 Step 2: Direct vs Vanilla Katran")
    fig.tight_layout()

    out = plots_dir / "wrk-direct-vs-katran.png"
    fig.savefig(out, dpi=180)
    plt.close(fig)

    summary_out = out_dir / "comparison-summary.csv"
    with summary_out.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow([
            "path",
            "connections",
            "rps_mean",
            "rps_std",
            "p99_ms_mean",
            "p99_ms_std",
        ])
        for idx, conn in enumerate(direct["connections"]):
            w.writerow([
                "direct-nginx",
                conn,
                f"{direct['rps_mean'][idx]:.6f}",
                f"{direct['rps_std'][idx]:.6f}",
                f"{direct['p99_mean'][idx]:.6f}",
                f"{direct['p99_std'][idx]:.6f}",
            ])
        for idx, conn in enumerate(katran["connections"]):
            w.writerow([
                "vanilla-katran",
                conn,
                f"{katran['rps_mean'][idx]:.6f}",
                f"{katran['rps_std'][idx]:.6f}",
                f"{katran['p99_mean'][idx]:.6f}",
                f"{katran['p99_std'][idx]:.6f}",
            ])

    return [out, summary_out]


def main():
    parser = argparse.ArgumentParser(description="Generate Exp1 wrk plots")
    parser.add_argument("--run-dir", help="Path to a single run dir (results/exp1/<run-id>-<kind>)")
    parser.add_argument("--compare-direct-dir", help="Direct run directory for comparison")
    parser.add_argument("--compare-katran-dir", help="Vanilla Katran run directory for comparison")
    parser.add_argument("--compare-out-dir", help="Output directory for comparison artifacts")
    args = parser.parse_args()

    generated = []

    if args.run_dir:
        run_dir = Path(args.run_dir).resolve()
        if not run_dir.exists():
            raise SystemExit(f"run directory does not exist: {run_dir}")
        plots_dir = run_dir / "plots"
        plots_dir.mkdir(parents=True, exist_ok=True)
        generated.extend(plot_single_run(run_dir, plots_dir))

    if args.compare_direct_dir or args.compare_katran_dir or args.compare_out_dir:
        if not (args.compare_direct_dir and args.compare_katran_dir and args.compare_out_dir):
            raise SystemExit("comparison mode requires --compare-direct-dir, --compare-katran-dir, and --compare-out-dir")
        direct_dir = Path(args.compare_direct_dir).resolve()
        katran_dir = Path(args.compare_katran_dir).resolve()
        out_dir = Path(args.compare_out_dir).resolve()
        if not direct_dir.exists():
            raise SystemExit(f"direct run directory does not exist: {direct_dir}")
        if not katran_dir.exists():
            raise SystemExit(f"katran run directory does not exist: {katran_dir}")
        out_dir.mkdir(parents=True, exist_ok=True)
        generated.extend(plot_compare(direct_dir, katran_dir, out_dir))

    if not generated:
        raise SystemExit("no plot generated (provide --run-dir and/or compare args)")

    print(f"generated {len(generated)} plot file(s)")
    for p in generated:
        print(Path(p).resolve())


if __name__ == "__main__":
    main()
