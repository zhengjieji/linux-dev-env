# Experiment 2 Scripts

This directory contains automation for **Experiment 2 (Oracle Hard-code)**.

Current implemented parts:

- **Stage A (Discovery)**
- **Stage B (Oracle build, all supported invariant maps + policy macros)**
- **Stage C (Full eval one-command runner)**

## Stage A: Discovery

`discover.sh` runs a long vanilla-katran workload (via `scripts/exp1/run.sh`) and periodically samples selected Katran BPF maps from `vm1`, then `analyze-maps.py` generates an invariant specialization spec.

Sampling policy:

- normal maps: per-sample full dump (`<map>.json`)
- large maps (`max_entries > EXP2_STAGEA_MAX_MAP_DUMP_ENTRIES`): per-sample hash-only (`<map>.hash.json`)
- if hash-only map is invariant and `EXP2_STAGEA_KEEP_INVARIANT_HASH_ONLY_DUMP=1`, keep exactly one final full dump in `final-dumps/<map>.json`

### Files

- `scripts/exp2/discover.sh`
- `scripts/exp2/analyze-maps.py`

### Default behavior (`make exp2-discover`)

- workloads: `wrk` then `wrk2` (separate Stage A runs)
- wrk2 target rate: `250000`
- steady warmup: `30s`
- sample interval: `30s`
- sample count: `10`
- sampled maps: `all` (all maps attached to balancer program)
- large-map hash-only threshold: `1000000` entries
- keep one retained dump for invariant hash-only maps: `on`

If you run script directly (not through Makefile), default map list is still:

- `ctl_array vip_map ch_rings reals server_id_map`

Use `--maps all` for full balancer map coverage.

### Example

```sh
scripts/exp2/discover.sh \
  --workload wrk2 \
  --wrk2-rate 300000 \
  --maps all \
  --steady-warmup-secs 45 \
  --sample-interval-secs 30 \
  --sample-count 8
```

Run discovery separately for `wrk` and `wrk2` if you want workload-specific invariants:

```sh
scripts/exp2/discover.sh --workload wrk --wrk-connections "256"
scripts/exp2/discover.sh --workload wrk2 --wrk2-rate 300000
```

### Outputs

Under `results/exp2/discovery/<run-id>-stageA/`:

- `stageA-config.env`
- `exp1-stageA.log`
- `map-show-start.json`
- `prog-show-start.json`
- `map-ids.json`
- `samples/sample-*/<map>.json` and/or `samples/sample-*/<map>.hash.json`
- `final-dumps/<map>.json` (only for invariant hash-only maps when enabled)
- `invariant-summary.csv`
- `specialization-spec.json`

`specialization-spec.json` includes:

- selection metadata (`named` vs `all-from-program`)
- balancer program metadata (`id`, `name`, `type`, `map_ids`)
- per-map metadata (raw `bpftool map show` object)
- per-map invariant status (whole-map hash stability)
- sampling mode per map (`dump` / `hash_only`)
- retained final dump linkage for invariant hash-only maps (if captured)
- per-entry invariant candidates (`key`, `value`, hashes)

This is the machine-readable input for Stage B oracle hard-code patch generation.

## Stage B: Oracle Build

`build-oracle.sh` consumes one Stage A `specialization-spec.json`, generates:

- `source/katran/katran/lib/bpf/oracle/exp2_oracle_generated.h`

Then builds Katran in an isolated build dir with oracle define:

- default defines: `-DLOCAL_DELIVERY_OPTIMIZATION -DEXP2_ORACLE_CH_RINGS`
- default build dir: `source/katran/_build_exp2_oracle`

This keeps vanilla and oracle artifacts separate.

### Default behavior (`make exp2-oracle-build`)

- use latest Stage A spec from `results/exp2/discovery/*-stageA/specialization-spec.json`
- generate oracle header for all supported invariant maps
- build oracle Katran artifacts in isolated build dir
- output env file:
  - `results/exp2/oracle/<run-id>-build/oracle-artifacts.env`

### Examples

Generate + build:

```sh
make exp2-oracle-build
```

Generate only (skip build):

```sh
make exp2-oracle-build EXP2_ORACLE_SKIP_BUILD=1
```

Use a specific Stage A spec:

```sh
make exp2-oracle-build \
  EXP2_ORACLE_SPEC=results/exp2/discovery/20260225T175014Z-stageA/specialization-spec.json
```

## Stage C: Full Eval (One Command)

`eval.sh` runs the full Exp2 performance comparison without rebuilding discovery/oracle:

1. `direct` (no katran)
2. `vanilla` katran
3. `opt` katran (oracle artifacts from latest `oracle-artifacts.env` unless overridden)
4. generate three-way comparison plots/csv

### Default behavior (`make exp2-eval`)

- eval output base: `results/exp2/eval`
- oracle env source: latest `results/exp2/oracle/*-build/oracle-artifacts.env`
- workload settings: inherited from `make exp1-run` defaults (or your overrides), i.e. full wrk + wrk2 sweep
- `EXP1_KATRAN_AUTO_BUILD` policy in eval lanes:
  - vanilla lane: `1` (avoid failing due to inherited shell env)
  - opt lane: `0` (must use oracle artifacts explicitly)
- old three-way dirs are archived under `results/exp2/eval/archive/threeway/`

### Examples

Run full eval with defaults:

```sh
make exp2-eval
```

Use a specific oracle env:

```sh
make exp2-eval \
  EXP2_EVAL_ORACLE_ENV=results/exp2/oracle/20260225T213748Z-build/oracle-artifacts.env
```

Disable three-way archive rotation:

```sh
make exp2-eval EXP2_EVAL_ARCHIVE_OLD=0
```

Force no auto-build for vanilla lane too (requires vanilla artifacts already present):

```sh
make exp2-eval EXP2_EVAL_VANILLA_KATRAN_AUTO_BUILD=0
```
