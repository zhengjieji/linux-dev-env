# Experiment Plan 3 — Automated Specialization System (Approach-to-Oracle)

> **Purpose**: Build and evaluate an automated specialization pipeline that identifies invariant config-map values and produces a specialized BPF program automatically, aiming to **approach the oracle upper bound** from Experiment 1 with minimal overhead and correct invalidation behavior.

---

## 1. Research Question

**RQ2**: Can we automatically specialize BPF programs using invariant map values (and later verifier-derived facts) such that performance approaches the oracle upper bound, while maintaining correctness under configuration changes?

---

## 2. Target Outcomes

- **Performance**: Auto-specialized performance is close to oracle (e.g., ≥80–95% of oracle gain) on macro metrics.
- **Overhead**: Specialization + guard/deopt overhead is negligible compared to benefits.
- **Correctness**: Behavior matches vanilla under stable configs; updates trigger correct fallback/re-specialization.

---

## 3. System Scope (start constrained, expand later)

To avoid over-engineering, version the automation:

### v0 — “Automatic Patch Generator” (fastest path to results)
- Input: discovered invariant (map,key,value) tuples (from Run A style discovery)
- Output: auto-generated patch / rebuilt BPF program with those constants baked in
- Update handling: **strong assumption** (config is frozen during measurement) or manual reload

### v1 — “Auto + Guard/Deopt”
- Adds invalidation: map update increments generation/version; specialized program checks version and falls back
- Optional: auto re-specialize after updates

### v2 — “Verifier/JIT Integrated Propagation” (research final form)
- Encode constants into verifier reg_state and pass to JIT/optimizer for deeper global optimization
- Enables call-site helper specialization synergy (optional extension)

---

## 4. Experimental Conditions

At minimum compare:

1) **Vanilla** (same as Exp 1)  
2) **Oracle** (Exp 1 hard-coded, as the upper bound reference)  
3) **Auto-v0** (automatic specialization without deopt, or freeze semantics)  
4) **Auto-v1** (automatic specialization with guard/deopt) — if implemented

Native baseline is recommended if available, but not required for the “approach-to-oracle” argument.

---

## 5. Automation Pipeline (v0/v1)

### 5.1 Discovery module (low-intrusive; not part of measurement runs)
- Same methodology as Exp 1 Run A:
  - snapshot maps post warm-up, compute digests, identify stable entries
- Output: specialization spec file, e.g.:
  - list of (map_id, key, value_bytes, type_info, validity window)
  - optionally, callsite mapping if available

### 5.2 Program transformation module
- Generate constants in a form that enables propagation (const/rodata-like)
- Rewrite map lookups (at known callsites) into direct constant loads
- Keep the generic path available when needed (for v1)

### 5.3 Deployment module
- Load & attach specialized program
- If v1: ensure fallback path is available and correct

---

## 6. Measurement Plan

### 6.1 Clean measurement requirement
All measurement runs must be **uninstrumented** (no BPF-internal timestamp+map writes).
Discovery runs are separate.

### 6.2 Workloads
- Start with the same workload profile used in Exp 1 (Katran).
- After stable results, add a second workload (Cilium or BMC) to demonstrate generality.

### 6.3 Metrics
Use the same macro/micro metrics as Exp 1:
- Throughput curve, loss curve, latency curve (avg/p99/p999)
- Micro evidence: BPF time, code size, helper counts (non-intrusive)

### 6.4 How to quantify “approach-to-oracle”
For each offered load point (or for summary metrics like peak throughput):
- Define gain over vanilla:  
  `Gain(X) = Metric_vanilla(X) → Metric_variant(X)`
- Define oracle gap closure for throughput (higher is better):  
  `Closure = (Auto - Vanilla) / (Oracle - Vanilla)`
Report Closure across key points (near-knee, peak).

---

## 7. Update/Invalidation Tests (v1+)

To prove correctness beyond “frozen config”:

### 7.1 Controlled update scenario
- During steady traffic, update one config map value that the specialization depends on.
- Expected behavior:
  - Specialized version detects mismatch and falls back to generic safely
  - Optional: triggers re-specialization and returns to specialized path

### 7.2 Metrics for invalidation
- Time-to-fallback (safety)
- Time-to-re-specialize (if implemented)
- Performance during transition (overhead spike)

---

## 8. Correctness & Safety Checks

- Functional tests: same as vanilla under stable config
- Differential check: compare packet forwarding decisions/log outputs between vanilla and auto
- Crash/safety: ensure no verifier regressions; no unsafe memory assumptions

---

## 9. Deliverables

**Core deliverable**: A “stair-step” performance story:

- Vanilla (baseline)
- Oracle (upper bound)
- Auto-v0 (first automation; shows feasibility)
- Auto-v1 (guard/deopt; shows robustness)

Paired with:
- Approach-to-oracle closure numbers
- Cost breakdown: specialization overhead, guard overhead, transition overhead

---

## 10. Risk Management & Debug Checklist

- If Auto-v0 << Oracle:
  - transformation didn’t enable propagation (constants not actually constant)
  - missed key callsites or values are not stable for this workload
- If Auto-v1 overhead erases benefits:
  - guard placed on hot path too frequently / too expensive
  - consider coarse-grained invalidation (rare checks) or version caching
- If results differ from Exp 1:
  - verify *exact same workload profile* and map values
  - ensure no discovery tooling is active during measurement runs
