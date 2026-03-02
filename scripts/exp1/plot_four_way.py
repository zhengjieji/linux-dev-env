#!/usr/bin/env python3

import argparse
import csv
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

from plot import load_wrk2_points, load_wrk_points


SERIES = (
    ("direct-nginx", "Direct", "tab:blue"),
    ("direct-forward", "Direct + Forward", "tab:purple"),
    ("vanilla-katran", "Vanilla Katran", "tab:orange"),
    ("oracle-katran", "Oracle Katran", "tab:green"),
)


def _plot_dataset(name, out_dir, data_map, x_label, lat_label):
    if any(not data_map[key] for key, _, _ in SERIES):
        return []

    plots_dir = out_dir / "plots"
    plots_dir.mkdir(parents=True, exist_ok=True)

    fig, (ax_rps, ax_lat) = plt.subplots(1, 2, figsize=(12, 4.8))

    for key, label, color in SERIES:
        data = data_map[key]
        ax_rps.errorbar(
            data["x"],
            data["rps_mean"],
            yerr=data["rps_std"],
            marker="o",
            linewidth=2,
            capsize=3,
            color=color,
            label=label,
        )
        ax_lat.errorbar(
            data["x"],
            data["lat_mean"],
            yerr=data["lat_std"],
            marker="o",
            linewidth=2,
            capsize=3,
            color=color,
            label=label,
        )

    ax_rps.set_title("Throughput Comparison")
    ax_rps.set_xlabel(x_label)
    ax_rps.set_ylabel("Requests/sec")
    ax_rps.set_xlim(left=0)
    ax_rps.set_ylim(bottom=0)
    ax_rps.grid(True, linestyle="--", alpha=0.4)
    ax_rps.legend()

    ax_lat.set_title("p99 Latency Comparison")
    ax_lat.set_xlabel(x_label)
    ax_lat.set_ylabel(lat_label)
    ax_lat.set_xlim(left=0)
    ax_lat.set_ylim(bottom=0)
    ax_lat.grid(True, linestyle="--", alpha=0.4)
    ax_lat.legend()

    fig.suptitle(f"Experiment 2: {name} Four-way Comparison")
    fig.tight_layout()

    out_plot = plots_dir / f"{name}-fourway.png"
    fig.savefig(out_plot, dpi=180)
    plt.close(fig)

    out_csv = out_dir / f"{name}-fourway-summary.csv"
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([name + "_path", "x", "rps_mean", "rps_std", "p99_ms_mean", "p99_ms_std"])
        for key, _label, _color in SERIES:
            data = data_map[key]
            for i, x in enumerate(data["x"]):
                writer.writerow(
                    [
                        key,
                        x,
                        f"{data['rps_mean'][i]:.6f}",
                        f"{data['rps_std'][i]:.6f}",
                        f"{data['lat_mean'][i]:.6f}",
                        f"{data['lat_std'][i]:.6f}",
                    ]
                )

    return [out_plot, out_csv]


def main():
    parser = argparse.ArgumentParser(description="Generate Exp2 four-way comparison plots")
    parser.add_argument("--direct-dir", required=True, help="results dir for direct run")
    parser.add_argument("--forward-dir", required=True, help="results dir for direct+forward run")
    parser.add_argument("--vanilla-dir", required=True, help="results dir for vanilla katran run")
    parser.add_argument("--oracle-dir", required=True, help="results dir for oracle katran run")
    parser.add_argument("--out-dir", required=True, help="output dir for four-way plots and summaries")
    args = parser.parse_args()

    direct_dir = Path(args.direct_dir).resolve()
    forward_dir = Path(args.forward_dir).resolve()
    vanilla_dir = Path(args.vanilla_dir).resolve()
    oracle_dir = Path(args.oracle_dir).resolve()
    out_dir = Path(args.out_dir).resolve()

    for p, label in (
        (direct_dir, "direct"),
        (forward_dir, "forward"),
        (vanilla_dir, "vanilla"),
        (oracle_dir, "oracle"),
    ):
        if not p.exists():
            raise SystemExit(f"{label} directory not found: {p}")

    out_dir.mkdir(parents=True, exist_ok=True)

    generated = []
    generated.extend(
        _plot_dataset(
            "wrk",
            out_dir,
            {
                "direct-nginx": load_wrk_points(direct_dir),
                "direct-forward": load_wrk_points(forward_dir),
                "vanilla-katran": load_wrk_points(vanilla_dir),
                "oracle-katran": load_wrk_points(oracle_dir),
            },
            x_label="Connections",
            lat_label="p99 latency (ms)",
        )
    )
    generated.extend(
        _plot_dataset(
            "wrk2",
            out_dir,
            {
                "direct-nginx": load_wrk2_points(direct_dir),
                "direct-forward": load_wrk2_points(forward_dir),
                "vanilla-katran": load_wrk2_points(vanilla_dir),
                "oracle-katran": load_wrk2_points(oracle_dir),
            },
            x_label="Target rate (req/s)",
            lat_label="p99 latency (ms)",
        )
    )

    if not generated:
        raise SystemExit("no four-way plot generated; ensure wrk/wrk2 summaries exist in all run dirs")

    print(f"generated {len(generated)} file(s)")
    for p in generated:
        print(Path(p).resolve())


if __name__ == "__main__":
    main()
