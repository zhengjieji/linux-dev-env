# BPF Verifier‑Guided Specialization（Main Doc · Nginx+wrk & Nginx+httperf）

> **Last updated**: 2026‑02‑20  
> **People**: Yusheng, Andy, Dan  
> **Core idea**: Convert *runtime invariants* (especially config‑map values) and *verifier knowledge* into **static facts** that downstream layers (program/JIT/helpers) can exploit to generate **specialized fast paths**, with guard/deopt to preserve correctness when invariants change.

---

## 1. What we are trying to show

BPF has a cross‑layer “information gap”: facts proven (or effectively true) at verification/runtime are not available to later components, forcing conservative generic paths. We argue that propagating invariants—starting with **config maps that are stable during the hot path**—enables **global simplification** (constant propagation, branch elimination, dead‑code elimination), not just micro “lookup removal”.

We will structure the project as three experiments:

1) **Experiment 1 (Baseline)**: build a *clean, interpretable* end‑to‑end benchmark using **Nginx + wrk** and **Nginx + httperf**.  
2) **Experiment 2 (Oracle hard‑code)**: manually hard‑code invariant config‑map values into the BPF program to measure an **upper bound**.  
3) **Experiment 3 (Automation)**: automatically discover invariants and generate/deploy a specialized program; quantify how close it gets to the oracle.

---

## 2. Why we must use a web benchmark (recent meeting correction)

A prior “PacketGen + IPVS + XDP” setup did **not** provide a clear end‑to‑end application workload and could short‑circuit different parts of the kernel stack, leading to paradoxical results (e.g., “with Katran faster than without Katran”). To make the performance story interpretable, we use an end‑to‑end HTTP workload:

- There is a real application server (**Nginx**) listening on a TCP port.
- The client tool measures completed HTTP requests and latency.
- The “No Katran” baseline is truly “same service work without the load balancer in the path”.

This makes the intended story valid: **adding Katran should add overhead; optimizations should reduce that overhead**.

---

## 3. Benchmark settings used in this project

We will use **two complementary baseline settings**, each with a clear meaning:

### Setting A — Nginx + wrk (mostly closed‑loop; concurrency‑driven)

**What it does**: `wrk` creates a fixed number of threads and TCP connections and continuously issues HTTP requests. Each connection issues a new request after the previous one completes (or pipelines depending on config). The offered rate is not explicitly controlled; it emerges from server responsiveness.

**What you sweep on X‑axis**: usually **concurrency (#connections)** (and/or threads).  
**What you measure on Y‑axis**: achieved throughput (RPS) and latency percentiles (p99/p999).

**Why we use it**: it is widely used, stable, and good for demonstrating “typical” end‑to‑end throughput/latency under increasing concurrency.

### Setting B — Nginx + httperf (open‑loop; rate‑driven)

**What it does**: `httperf` can send HTTP requests at a specified **fixed offered rate** (open‑loop). This is ideal for *offered load → achieved throughput* curves and for revealing the saturation knee and overload behavior.

**What you sweep on X‑axis**: **offered request rate (offered RPS)**.  
**What you measure on Y‑axis**: achieved RPS, errors/timeouts, latency statistics (and optionally a time‑series peak).

**Why we use it**: it provides the most direct version of the “load→throughput curve” your advisor described: throughput rises with load, then plateaus/falls as the system saturates.

> Together, wrk (closed‑loop) and httperf (open‑loop) give complementary views. We will report both.

---

## 4. System under test (SUT) topology and baselines

We evaluate three **path baselines** under each setting:

1) **Direct (No Katran)**  
   Client → backend Nginx directly (backend IP:port).  
   *Meaning*: best achievable end‑to‑end performance without the load balancer overhead.

2) **Vanilla Katran**  
   Client → VIP handled by Katran/XDP → backend Nginx.  
   *Meaning*: baseline overhead of Katran (generic program, generic map accesses).

3) **Optimized Katran**  
   Same as Vanilla, but with either Oracle hard‑code (Exp 2) or automation (Exp 3).  
   *Meaning*: how much of Katran’s overhead can be removed using specialization.

**Expected ordering** (for real end‑to‑end work):  
Direct fastest, Vanilla slowest, Optimized in the middle and as close to Direct as possible.

---

## 5. Main technical direction (P0): Config‑map value propagation

We start from the observation that many maps used by BPF programs are effectively **configuration injection**. During the hot path they are stable, but the program treats them as dynamic values. If we propagate these values as constants:

- map lookups can be replaced by constant loads,
- and more importantly, downstream control flow can collapse, enabling aggressive DCE/branch elimination.

We will first establish an oracle upper bound (Exp 2) and then implement automation (Exp 3).

---

## 6. What we will report (paper‑facing)

For each setting (wrk, httperf), and for each baseline (Direct/Vanilla/Optimized), we report:

- **Throughput curves**
  - wrk: concurrency → achieved RPS
  - httperf: offered RPS → achieved RPS
- **Latency**
  - avg, p99 (and p999 if available)
- **Peak latency (time series) at a representative high‑load point**
  - compute windowed tail latency over time (e.g., 1s p99) and report its max

Micro evidence is used to explain results (not as primary claims): BPF time, code size, helper counts.

---

## 7. Roadmap & milestones

- **M1**: Baselines stable and interpretable on both settings (wrk and httperf), with sanity gates passing.  
- **M2**: Oracle hard‑code shows clear improvements relative to Vanilla on both settings; understand where gains appear (especially near knee).  
- **M3**: Automation closes a large fraction of the oracle gap; quantify closure and overhead; optionally add update/fallback behavior.

---

## 8. Local design notes (Chinese)

- `documents/exp-2-three-node-four-sets-design.md`  
  3-node 拓扑 + 4 组对照（`direct` / `direct-forward` / `vanilla-katran` / `oracle-katran`）实现设计草案。
