# Experiment 2 — Oracle Hard-code (Upper Bound) with Separate Discovery & Run Stages

> **Goal**: Measure the *theoretical upper bound* of config‑map specialization by (i) **discovering** map values that do not change under a given workload profile, (ii) hard-coding those values into Katran’s BPF program (oracle), and (iii) running a clean 3‑way comparison: **No Katran vs Vanilla Katran vs Oracle Katran**.  
> **Key requirement**: **Discovery is allowed to be intrusive; the actual comparison runs must be clean/uninstrumented.**

This plan assumes the same **throughput + latency** metrics and plotting style as Experiment 1 (Nginx + wrk baseline).

---

## 0) Definitions

- **No Katran (Direct)**: client sends HTTP requests directly to backend Nginx (IP:port).
- **Vanilla Katran**: client sends HTTP requests to VIP; Katran forwards to backend Nginx using the original BPF program.
- **Oracle Katran (Hard-coded)**: same as Vanilla Katran, but with discovered invariant config-map values hard-coded into the BPF program.

---

## 1) Two stages

### Stage A — Discovery (workload + Katran + map dumps)
**Purpose**: identify which map entries behave like “dynamic constants” under the target workload profile.

**This stage is NOT used to produce performance plots.**

#### A1. Run the target workload profile (with Katran)
- Deploy **Vanilla Katran** on the data path (VIP active).
- Run the same Nginx + wrk workload profile that you will use in Stage B.

#### A2. Dump maps repeatedly during steady state
- Warm-up until stable traffic (e.g., 30–60s).
- Dump candidate maps at multiple times:
  - `t0` (after warm-up), `t1`, …, `t_end`
  - Suggested cadence: every 30–60s for 5–10 minutes (tunable)
- For each dump, compute a digest (hash) per map (and per-entry if needed) to detect change.

#### A3. Decide “invariant under workload profile”
For a map entry to be considered invariant for the oracle:
- the value is identical across dumps in the steady-state window, and
- ideally, there is no evidence of updates during that window (if observable cheaply).

> You do **not** need to prove “never changes forever.” For oracle, define invariance as “stable for the duration of this workload window.”

#### A4. Output of Stage A: specialization spec
Produce a machine-readable “specialization spec” (even a simple text file) listing:
- map name/id
- key (bytes or human-readable)
- value (bytes / decoded fields)
- map type (array/hash), key/value sizes

This file is what you will hand to Codex to generate hard-code patches.

---

### Stage B — Run Stage (clean measurement comparison)
**Purpose**: produce paper-quality curves comparing Direct vs Vanilla vs Oracle.

**This stage MUST be clean: no dumping, no BPF-internal timing/map-write instrumentation.**

#### B0. Build the oracle version
- Prompt Codex with:
  - the specialization spec from Stage A
  - the relevant Katran BPF source files
  - instructions: replace map lookups at the known call sites with constants in a way that allows propagation/DCE (e.g., const/rodata-like), and preserve semantics.

Validate that:
- the patched program compiles/loads
- behavior matches Vanilla under the same workload (HTTP correctness)

#### B1. Conditions to run
Run the **same** workload profile under **three conditions**:

1) **No Katran (Direct)**  
2) **Vanilla Katran**  
3) **Oracle Katran (Hard-coded)**  

Keep everything else identical:
- same Nginx config
- same client wrk config (threads, connections sweep)
- same CPU pinning / machine placement

---

## 2) Metrics (same as Experiment 1)

### Primary metrics (macro, paper-facing)
- **Throughput**: achieved **RPS** (Requests/sec) from wrk output
- **Latency**: avg + p99 (and p999 if available)
- **Errors**: non-2xx, timeouts

### Optional “peak latency over time” (if you already plan it in Exp 1)
At a representative high-load point near the knee:
- collect windowed tail latency over time (e.g., 1s p99)
- define peak latency = max(windowed p99)

---

## 3) Run protocol (how to execute each load point)

For each concurrency point in your sweep:
1) Warm-up 10–30s (discard)
2) Measure 60–180s
3) Repeat 3–5 times
4) Save:
   - full wrk output
   - exact command line
   - Nginx/server CPU snapshot, client CPU snapshot

Plot:
- **concurrency → RPS**
- **concurrency → p99 latency**
for each of the 3 conditions.

---

## 4) Sanity gates (especially important for Oracle)

Before running full sweeps, verify:

- **Direct**: requests hit backend (Nginx logs) and client receives 200 OK.
- **Vanilla**: requests to VIP still reach Nginx and return 200 OK.
- **Oracle**:
  - still reaches Nginx
  - responses match Vanilla (functional equivalence)
  - no unexpected error spikes
- Ensure the oracle is not accidentally “short-circuiting” (e.g., dropping requests or bypassing server). Nginx logs are the simplest check.

---

## 5) Deliverables

1) A clean 3-way comparison figure set:
- Direct vs Vanilla vs Oracle:
  - throughput curve (RPS)
  - latency curve (p99)

2) A short oracle patch summary:
- which maps/entries were hard-coded (from specialization spec)
- evidence of stability during Stage A
- (optional) code size reduction / branch elimination evidence

---

## 6) Common failure modes (and how to debug quickly)

- **Oracle beats Direct**: indicates the request may not be reaching Nginx or the path differs; check Nginx logs/counters first.
- **Vanilla ≈ Oracle**: likely you hard-coded values that don’t affect hot path, or constants were encoded in a way that didn’t propagate.
- **Results unstable**: check CPU pinning, client bottleneck, and remove any remaining discovery/dump activities from Stage B.
