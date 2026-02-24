# Experiment 3 — Automation (Approach the Oracle) using Nginx+wrk and Nginx+httperf

> **Goal**: Automatically discover invariants and generate/deploy a specialized program. Evaluate how close automation gets to the oracle on both benchmark settings.

---

## 1) Compare these conditions

For each setting (wrk and httperf):

1) Vanilla Katran  
2) Oracle Hard‑coded Katran (upper bound reference)  
3) Auto Specialized Katran (system)

(Optional: Direct baseline as context.)

---

## 2) Automation versions (progressive)

### Auto‑v0 (fastest to results)
- Input: specialization spec (map,key,value) from discovery
- Output: auto‑generated specialized program that hard‑codes constants
- Assumption: config is frozen during measurement

### Auto‑v1 (robustness, if time)
- Add invalidation/rollback:
  - detect map updates (version/generation)
  - fall back to Vanilla (generic) or trigger re‑specialization

---

## 3) Pipeline stages

### Stage A — Discovery (separate run)
- Same as Exp 2 Run A: dump maps after warm‑up, detect stable entries.

### Stage B — Transformation
- Emit constants in propagatable form
- Rewrite targeted lookup sites → constant loads
- Keep generic path available if doing Auto‑v1 fallback

### Stage C — Deployment
- Reload/attach specialized program
- Ensure all other environment settings unchanged

---

## 4) Measurement plan (clean runs)

- Reuse Exp 1 sweeps and durations.
- No dumping, no BPF internal timing/map‑writes during measurement.
- Collect same curves for both settings.

---

## 5) Quantify “approach to oracle”

Define closure for throughput at each load point:

`Closure = (Auto − Vanilla) / (Oracle − Vanilla)`

Report closure:
- near knee (most meaningful)
- at peak achieved throughput
- optionally at a fixed high load

Do the analogous analysis for latency improvements (careful with sign).

---

## 6) Optional: update/invalidation test (Auto‑v1)

- Under steady load, update a config value used by specialization.
- Expected:
  - safe fallback to Vanilla (correctness preserved)
  - optional re‑specialization and performance recovery
Measure transition overhead and time to recover.

---

## 7) Deliverables

- Vanilla vs Oracle vs Auto curves for both settings:
  - wrk: concurrency→RPS, concurrency→p99
  - httperf: offeredRPS→achievedRPS, offeredRPS→p99, offeredRPS→errors
- Closure numbers + overhead discussion (specialization/guard/updates)
