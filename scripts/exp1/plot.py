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
            "x": [p["key"] for p in points],
            "x_label": "Connections",
            "rps_mean": [p["rps_mean"] for p in points],
            "rps_std": [p["rps_std"] for p in points],
            "lat_mean": [p["p99_mean"] for p in points],
            "lat_std": [p["p99_std"] for p in points],
            "lat_label": "p99 latency (ms)",
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
        x = parse_int(row.get("connections"))
        rps = parse_float(row.get("rps_mean"))
        lat = parse_float(row.get("p99_ms_mean"))
        vm1 = parse_float(row.get("vm1_cpu_util_pct_mean"))
        vm2 = parse_float(row.get("vm2_cpu_util_pct_mean"))
        points.append((x, rps, lat, vm1, vm2))
    points.sort(key=lambda p: p[0])

    has_vm_util = "vm1_cpu_util_pct_mean" in rows[0] and "vm2_cpu_util_pct_mean" in rows[0]
    return {
        "x": [p[0] for p in points],
        "x_label": "Connections",
        "rps_mean": [p[1] for p in points],
        "rps_std": [0.0 for _ in points],
        "lat_mean": [p[2] for p in points],
        "lat_std": [0.0 for _ in points],
        "lat_label": "p99 latency (ms)",
        "has_vm_util": has_vm_util,
        "vm1_cpu_mean": [p[3] for p in points],
        "vm1_cpu_std": [0.0 for _ in points],
        "vm2_cpu_mean": [p[4] for p in points],
        "vm2_cpu_std": [0.0 for _ in points],
    }


def load_wrk2_points(run_dir: Path):
    wrk2_summary = run_dir / "wrk2-summary.csv"
    wrk2_agg = run_dir / "wrk2-summary-agg.csv"

    if wrk2_summary.exists():
        rows = read_csv_rows(wrk2_summary)
        if not rows:
            return None
        has_vm_util = "vm1_cpu_util_pct" in rows[0] and "vm2_cpu_util_pct" in rows[0]
        metric_fields = {"rps": "requests_per_sec", "p99": "p99_ms"}
        if has_vm_util:
            metric_fields["vm1_cpu"] = "vm1_cpu_util_pct"
            metric_fields["vm2_cpu"] = "vm2_cpu_util_pct"
        points = aggregate_by_key(rows, key_field="target_rate", metric_fields=metric_fields)
        if not points:
            return None

        out = {
            "x": [p["key"] for p in points],
            "x_label": "Target rate (req/s)",
            "rps_mean": [p["rps_mean"] for p in points],
            "rps_std": [p["rps_std"] for p in points],
            "lat_mean": [p["p99_mean"] for p in points],
            "lat_std": [p["p99_std"] for p in points],
            "lat_label": "p99 latency (ms)",
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

    if not wrk2_agg.exists():
        return None

    rows = read_csv_rows(wrk2_agg)
    if not rows:
        return None

    points = []
    for row in rows:
        x = parse_int(row.get("target_rate"))
        rps = parse_float(row.get("rps_mean"))
        lat = parse_float(row.get("p99_ms_mean"))
        vm1 = parse_float(row.get("vm1_cpu_util_pct_mean"))
        vm2 = parse_float(row.get("vm2_cpu_util_pct_mean"))
        points.append((x, rps, lat, vm1, vm2))
    points.sort(key=lambda p: p[0])

    has_vm_util = "vm1_cpu_util_pct_mean" in rows[0] and "vm2_cpu_util_pct_mean" in rows[0]
    return {
        "x": [p[0] for p in points],
        "x_label": "Target rate (req/s)",
        "rps_mean": [p[1] for p in points],
        "rps_std": [0.0 for _ in points],
        "lat_mean": [p[2] for p in points],
        "lat_std": [0.0 for _ in points],
        "lat_label": "p99 latency (ms)",
        "has_vm_util": has_vm_util,
        "vm1_cpu_mean": [p[3] for p in points],
        "vm1_cpu_std": [0.0 for _ in points],
        "vm2_cpu_mean": [p[4] for p in points],
        "vm2_cpu_std": [0.0 for _ in points],
    }


def load_httperf_points(run_dir: Path):
    httperf_summary = run_dir / "httperf-summary.csv"
    httperf_agg = run_dir / "httperf-summary-agg.csv"

    if httperf_summary.exists():
        rows = read_csv_rows(httperf_summary)
        if not rows:
            return None
        has_vm_util = "vm1_cpu_util_pct" in rows[0] and "vm2_cpu_util_pct" in rows[0]
        metric_fields = {
            "req_rate": "request_rate",
            "resp_ms": "response_time_ms",
        }
        if has_vm_util:
            metric_fields["vm1_cpu"] = "vm1_cpu_util_pct"
            metric_fields["vm2_cpu"] = "vm2_cpu_util_pct"
        points = aggregate_by_key(rows, key_field="offered_rate", metric_fields=metric_fields)
        if not points:
            return None

        out = {
            "x": [p["key"] for p in points],
            "x_label": "Offered rate (req/s)",
            "rps_mean": [p["req_rate_mean"] for p in points],
            "rps_std": [p["req_rate_std"] for p in points],
            "lat_mean": [p["resp_ms_mean"] for p in points],
            "lat_std": [p["resp_ms_std"] for p in points],
            "lat_label": "response time (ms)",
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

    if not httperf_agg.exists():
        return None

    rows = read_csv_rows(httperf_agg)
    if not rows:
        return None

    points = []
    for row in rows:
        x = parse_int(row.get("offered_rate"))
        rps = parse_float(row.get("request_rate_mean"))
        lat = parse_float(row.get("response_time_ms_mean"))
        vm1 = parse_float(row.get("vm1_cpu_util_pct_mean"))
        vm2 = parse_float(row.get("vm2_cpu_util_pct_mean"))
        points.append((x, rps, lat, vm1, vm2))
    points.sort(key=lambda p: p[0])

    has_vm_util = "vm1_cpu_util_pct_mean" in rows[0] and "vm2_cpu_util_pct_mean" in rows[0]
    return {
        "x": [p[0] for p in points],
        "x_label": "Offered rate (req/s)",
        "rps_mean": [p[1] for p in points],
        "rps_std": [0.0 for _ in points],
        "lat_mean": [p[2] for p in points],
        "lat_std": [0.0 for _ in points],
        "lat_label": "response time (ms)",
        "has_vm_util": has_vm_util,
        "vm1_cpu_mean": [p[3] for p in points],
        "vm1_cpu_std": [0.0 for _ in points],
        "vm2_cpu_mean": [p[4] for p in points],
        "vm2_cpu_std": [0.0 for _ in points],
    }


def plot_single_dataset(run_dir: Path, plots_dir: Path, data, figure_tag: str, throughput_title: str, latency_title: str):
    if not data:
        return []

    cfg = read_run_config(run_dir)
    run_kind = cfg.get("run_kind", "unknown")
    run_title = RUN_KIND_TITLE.get(run_kind, run_kind)

    x_vals = data["x"]
    rps_vals = data["rps_mean"]
    rps_std = data["rps_std"]
    lat_vals = data["lat_mean"]
    lat_std = data["lat_std"]

    if data["has_vm_util"]:
        fig, ((ax_rps, ax_lat), (ax_vm1, ax_vm2)) = plt.subplots(2, 2, figsize=(12, 8.0))
    else:
        fig, (ax_rps, ax_lat) = plt.subplots(1, 2, figsize=(12, 4.5))
        ax_vm1 = None
        ax_vm2 = None

    ax_rps.errorbar(x_vals, rps_vals, yerr=rps_std, marker="o", linewidth=2, capsize=3)
    ax_rps.set_title(throughput_title)
    ax_rps.set_xlabel(data["x_label"])
    ax_rps.set_ylabel("Requests/sec")
    ax_rps.grid(True, linestyle="--", alpha=0.4)

    ax_lat.errorbar(x_vals, lat_vals, yerr=lat_std, marker="o", linewidth=2, color="tab:orange", capsize=3)
    ax_lat.set_title(latency_title)
    ax_lat.set_xlabel(data["x_label"])
    ax_lat.set_ylabel(data["lat_label"])
    ax_lat.grid(True, linestyle="--", alpha=0.4)

    if data["has_vm_util"] and ax_vm1 is not None and ax_vm2 is not None:
        ax_vm1.errorbar(
            x_vals,
            data["vm1_cpu_mean"],
            yerr=data["vm1_cpu_std"],
            marker="o",
            linewidth=2,
            color="tab:green",
            capsize=3,
        )
        ax_vm1.set_title("vm1 CPU Utilization")
        ax_vm1.set_xlabel(data["x_label"])
        ax_vm1.set_ylabel("CPU util (%)")
        ax_vm1.set_ylim(0, 100)
        ax_vm1.grid(True, linestyle="--", alpha=0.4)

        ax_vm2.errorbar(
            x_vals,
            data["vm2_cpu_mean"],
            yerr=data["vm2_cpu_std"],
            marker="o",
            linewidth=2,
            color="tab:red",
            capsize=3,
        )
        ax_vm2.set_title("vm2 CPU Utilization")
        ax_vm2.set_xlabel(data["x_label"])
        ax_vm2.set_ylabel("CPU util (%)")
        ax_vm2.set_ylim(0, 100)
        ax_vm2.grid(True, linestyle="--", alpha=0.4)

    fig.suptitle(f"Experiment 1 ({run_title})")
    fig.tight_layout()

    out = plots_dir / f"{figure_tag}-overview.png"
    fig.savefig(out, dpi=180)
    plt.close(fig)
    return [out]


def plot_compare_dataset(
    direct_data,
    katran_data,
    out_dir: Path,
    figure_tag: str,
    title: str,
    x_label: str,
    throughput_title: str,
    latency_title: str,
    latency_label: str,
):
    if not direct_data or not katran_data:
        return []

    plots_dir = out_dir / "plots"
    plots_dir.mkdir(parents=True, exist_ok=True)

    fig, (ax_rps, ax_lat) = plt.subplots(1, 2, figsize=(12, 4.8))

    ax_rps.errorbar(
        direct_data["x"],
        direct_data["rps_mean"],
        yerr=direct_data["rps_std"],
        marker="o",
        linewidth=2,
        capsize=3,
        label="Direct Nginx",
    )
    ax_rps.errorbar(
        katran_data["x"],
        katran_data["rps_mean"],
        yerr=katran_data["rps_std"],
        marker="o",
        linewidth=2,
        capsize=3,
        label="Vanilla Katran",
    )
    ax_rps.set_title(throughput_title)
    ax_rps.set_xlabel(x_label)
    ax_rps.set_ylabel("Requests/sec")
    ax_rps.grid(True, linestyle="--", alpha=0.4)
    ax_rps.legend()

    ax_lat.errorbar(
        direct_data["x"],
        direct_data["lat_mean"],
        yerr=direct_data["lat_std"],
        marker="o",
        linewidth=2,
        capsize=3,
        label="Direct Nginx",
    )
    ax_lat.errorbar(
        katran_data["x"],
        katran_data["lat_mean"],
        yerr=katran_data["lat_std"],
        marker="o",
        linewidth=2,
        capsize=3,
        label="Vanilla Katran",
    )
    ax_lat.set_title(latency_title)
    ax_lat.set_xlabel(x_label)
    ax_lat.set_ylabel(latency_label)
    ax_lat.grid(True, linestyle="--", alpha=0.4)
    ax_lat.legend()

    fig.suptitle(title)
    fig.tight_layout()

    out = plots_dir / f"{figure_tag}-direct-vs-katran.png"
    fig.savefig(out, dpi=180)
    plt.close(fig)

    generated = [out]
    summary_names = []
    if figure_tag == "wrk":
        summary_names = ["comparison-summary.csv", "wrk-comparison-summary.csv"]
    else:
        summary_names = [f"{figure_tag}-comparison-summary.csv"]

    for name in summary_names:
        summary_out = out_dir / name
        with summary_out.open("w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            if figure_tag == "wrk":
                w.writerow([
                    "path",
                    "connections",
                    "rps_mean",
                    "rps_std",
                    "p99_ms_mean",
                    "p99_ms_std",
                ])
            elif figure_tag == "wrk2":
                w.writerow([
                    "path",
                    "target_rate",
                    "rps_mean",
                    "rps_std",
                    "p99_ms_mean",
                    "p99_ms_std",
                ])
            else:
                w.writerow([
                    "path",
                    "offered_rate",
                    "request_rate_mean",
                    "request_rate_std",
                    "response_time_ms_mean",
                    "response_time_ms_std",
                ])

            for idx, x in enumerate(direct_data["x"]):
                w.writerow([
                    "direct-nginx",
                    x,
                    f"{direct_data['rps_mean'][idx]:.6f}",
                    f"{direct_data['rps_std'][idx]:.6f}",
                    f"{direct_data['lat_mean'][idx]:.6f}",
                    f"{direct_data['lat_std'][idx]:.6f}",
                ])
            for idx, x in enumerate(katran_data["x"]):
                w.writerow([
                    "vanilla-katran",
                    x,
                    f"{katran_data['rps_mean'][idx]:.6f}",
                    f"{katran_data['rps_std'][idx]:.6f}",
                    f"{katran_data['lat_mean'][idx]:.6f}",
                    f"{katran_data['lat_std'][idx]:.6f}",
                ])
        generated.append(summary_out)

    return generated


def plot_single_run(run_dir: Path, plots_dir: Path):
    generated = []
    generated.extend(
        plot_single_dataset(
            run_dir,
            plots_dir,
            load_wrk2_points(run_dir),
            figure_tag="wrk2",
            throughput_title="wrk2 Achieved Throughput",
            latency_title="wrk2 p99 Latency",
        )
    )
    generated.extend(
        plot_single_dataset(
            run_dir,
            plots_dir,
            load_wrk_points(run_dir),
            figure_tag="wrk",
            throughput_title="wrk Throughput",
            latency_title="wrk p99 Latency",
        )
    )
    generated.extend(
        plot_single_dataset(
            run_dir,
            plots_dir,
            load_httperf_points(run_dir),
            figure_tag="httperf",
            throughput_title="httperf Achieved Throughput",
            latency_title="httperf Response Time",
        )
    )
    return generated


def plot_compare(direct_dir: Path, katran_dir: Path, out_dir: Path):
    generated = []

    wrk_direct = load_wrk_points(direct_dir)
    wrk_katran = load_wrk_points(katran_dir)
    generated.extend(
        plot_compare_dataset(
            wrk_direct,
            wrk_katran,
            out_dir,
            figure_tag="wrk",
            title="Experiment 1: wrk Direct vs Vanilla Katran",
            x_label="Connections",
            throughput_title="Throughput Comparison",
            latency_title="p99 Latency Comparison",
            latency_label="p99 latency (ms)",
        )
    )

    httperf_direct = load_httperf_points(direct_dir)
    httperf_katran = load_httperf_points(katran_dir)
    generated.extend(
        plot_compare_dataset(
            load_wrk2_points(direct_dir),
            load_wrk2_points(katran_dir),
            out_dir,
            figure_tag="wrk2",
            title="Experiment 1: wrk2 Direct vs Vanilla Katran",
            x_label="Target rate (req/s)",
            throughput_title="Achieved Throughput Comparison",
            latency_title="p99 Latency Comparison",
            latency_label="p99 latency (ms)",
        )
    )

    generated.extend(
        plot_compare_dataset(
            httperf_direct,
            httperf_katran,
            out_dir,
            figure_tag="httperf",
            title="Experiment 1: httperf Direct vs Vanilla Katran",
            x_label="Offered rate (req/s)",
            throughput_title="Achieved Throughput Comparison",
            latency_title="Response Time Comparison",
            latency_label="response time (ms)",
        )
    )

    return generated


def main():
    parser = argparse.ArgumentParser(description="Generate Exp1 wrk/wrk2/httperf plots")
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
        raise SystemExit(
            "no plot generated (provide --run-dir and/or compare args, and ensure wrk/wrk2/httperf summary files exist)"
        )

    print(f"generated {len(generated)} plot file(s)")
    for p in generated:
        print(Path(p).resolve())


if __name__ == "__main__":
    main()
