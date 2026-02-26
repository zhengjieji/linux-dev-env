#!/usr/bin/env python3

import argparse
import csv
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

from plot import load_wrk2_points, load_wrk_points


SERIES = (
    ("direct-nginx", "No Katran (Direct)", "tab:blue"),
    ("vanilla-katran", "Vanilla Katran", "tab:orange"),
    ("opt-katran", "Opt Katran (Oracle)", "tab:green"),
)


def _plot_dataset(name, out_dir, direct_data, vanilla_data, opt_data, x_label, lat_label):
    if not direct_data or not vanilla_data or not opt_data:
        return []

    plots_dir = out_dir / "plots"
    plots_dir.mkdir(parents=True, exist_ok=True)

    series_data = {
        "direct-nginx": direct_data,
        "vanilla-katran": vanilla_data,
        "opt-katran": opt_data,
    }

    fig, (ax_rps, ax_lat) = plt.subplots(1, 2, figsize=(12, 4.8))

    for key, label, color in SERIES:
        data = series_data[key]
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

    fig.suptitle(f"Experiment 2: {name} Direct vs Vanilla vs Opt Katran")
    fig.tight_layout()

    out_plot = plots_dir / f"{name}-direct-vs-vanilla-vs-opt.png"
    fig.savefig(out_plot, dpi=180)
    plt.close(fig)

    out_csv = out_dir / f"{name}-threeway-summary.csv"
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([name + "_path", "x", "rps_mean", "rps_std", "p99_ms_mean", "p99_ms_std"])
        for key, _label, _color in SERIES:
            data = series_data[key]
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
    parser = argparse.ArgumentParser(description="Generate Exp1/Exp2 three-way comparison plots")
    parser.add_argument("--direct-dir", required=True, help="results dir for no-katran direct run")
    parser.add_argument("--vanilla-dir", required=True, help="results dir for vanilla katran run")
    parser.add_argument("--opt-dir", required=True, help="results dir for oracle/opt katran run")
    parser.add_argument("--out-dir", required=True, help="output dir for three-way plots and summaries")
    args = parser.parse_args()

    direct_dir = Path(args.direct_dir).resolve()
    vanilla_dir = Path(args.vanilla_dir).resolve()
    opt_dir = Path(args.opt_dir).resolve()
    out_dir = Path(args.out_dir).resolve()

    for p, label in ((direct_dir, "direct"), (vanilla_dir, "vanilla"), (opt_dir, "opt")):
        if not p.exists():
            raise SystemExit(f"{label} directory not found: {p}")

    out_dir.mkdir(parents=True, exist_ok=True)

    generated = []
    generated.extend(
        _plot_dataset(
            "wrk",
            out_dir,
            load_wrk_points(direct_dir),
            load_wrk_points(vanilla_dir),
            load_wrk_points(opt_dir),
            x_label="Connections",
            lat_label="p99 latency (ms)",
        )
    )
    generated.extend(
        _plot_dataset(
            "wrk2",
            out_dir,
            load_wrk2_points(direct_dir),
            load_wrk2_points(vanilla_dir),
            load_wrk2_points(opt_dir),
            x_label="Target rate (req/s)",
            lat_label="p99 latency (ms)",
        )
    )

    if not generated:
        raise SystemExit("no three-way plot generated; ensure wrk/wrk2 summaries exist in all three run dirs")

    print(f"generated {len(generated)} file(s)")
    for p in generated:
        print(Path(p).resolve())


if __name__ == "__main__":
    main()
