# Current Dual-VM Setup (Implementation Reference)

This document describes the **current implemented dual-VM environment** in this repository, including VM parameters, networking, communication paths, lifecycle, and CPU pinning behavior.

## 1) Scope and Components

The runtime has three layers:

1. Host machine
2. A privileged Docker session container (`dual-vm-session`)
3. Two QEMU guests (`vm1`, `vm2`) launched inside that container

High-level view:

```text
Host
  └─ Docker container: dual-vm-session (privileged, /dev/kvm)
       ├─ QEMU vm1
       ├─ QEMU vm2
       ├─ bridge br-dual (192.168.100.254/24)
       ├─ tap-dual-vm1
       └─ tap-dual-vm2
```

## 2) VM Parameters (Current Defaults)

These are the active defaults from `q-script/yifei-q` and `scripts/dual-vm.sh`.

Runtime image defaults:

- `scripts/dual-vm.sh` fallback default: `dual-vm-zhengjie`
- `Makefile` default used by normal `make` commands: `zhengjie-dual-vm`

### 2.1 Shared QEMU defaults (both VMs)

- Acceleration: `-machine accel=kvm:tcg`
- CPU model: `-cpu host`
- Base launcher defaults in `yifei-q`: `-smp 4` (`NRCPU=4`), `-m 2048` (`MEMORY=2048`)
- Effective dual-vm defaults from `Makefile`: `DUAL_VM1_VCPUS=4`, `DUAL_VM2_VCPUS=4`, `DUAL_VM1_MEMORY_MB=4096`, `DUAL_VM2_MEMORY_MB=4096`
- Kernel: `/linux/arch/x86/boot/bzImage`
- Root style: 9p + overlay setup in guest bootstrap script
- SSH server in guest: enabled (`-s` path in launcher)

`scripts/dual-vm.sh` now forwards `-N` and `-M` to `yifei-q` when `DUAL_VM{1,2}_VCPUS` / `DUAL_VM{1,2}_MEMORY_MB` are set.

### 2.2 Per-VM identity and ports

| Item | vm1 | vm2 |
|---|---|---|
| Host SSH port | `53022` | `53122` |
| Host NET port | `53023` | `53123` |
| Host GDB port | `1311` | `1312` |
| Container forwarded SSH port | `52222` | `52322` |
| Container forwarded NET port | `52223` | `52323` |
| QEMU GDB listen port (inside container) | `1234` | `1237` |
| Serial TCP port (inside container) | `1235` | `1236` |
| Data-plane TAP name | `tap-dual-vm1` | `tap-dual-vm2` |
| Data-plane MAC | `52:54:00:aa:00:11` | `52:54:00:aa:00:22` |
| Data-plane IP | `192.168.100.1/24` | `192.168.100.2/24` |

Bridge defaults:

- Bridge name: `br-dual`
- Bridge IP: `192.168.100.254/24`
- Host CPU pinning defaults: `DUAL_VM1_HOST_CPUSET=auto`, `DUAL_VM2_HOST_CPUSET=auto`

## 3) How VMs Communicate

There are **two network planes**:

1. Management plane (port-forwarded path)
2. Data plane (direct vm1<->vm2 L2 bridge)

### 3.1 Management plane

Each VM gets a QEMU user-network interface (`-netdev user,id=virtual`), with host forwarding enabled.

SSH path example (`vm1`):

`host 127.0.0.1:53022 -> docker-published 53022:52222 -> QEMU hostfwd 52222->guest:22`

NET port uses the same forwarding model (to guest port `52223` for vm1, `52323` for vm2).

GDB path is different:

- docker publishes host GDB port directly to the container-side QEMU gdb listener
- vm1: `1311 -> 1234`
- vm2: `1312 -> 1237`

### 3.2 Data plane

`scripts/dual-vm.sh` adds one extra virtio NIC per VM using TAP:

- vm1 NIC attached to `tap-dual-vm1`
- vm2 NIC attached to `tap-dual-vm2`
- both TAPs enslaved to `br-dual`

After boot, the script SSHes into each VM, identifies the data NIC by MAC, and configures static IP:

- vm1: `192.168.100.1/24`
- vm2: `192.168.100.2/24`

This is the path used by experiments (for example vm2 `wrk` to vm1 nginx).

## 4) Lifecycle and Control

Primary commands:

```bash
make dual-vm1
make dual-vm2
make dual-vm-status
make dual-vm1-ssh
make dual-vm2-ssh
make dual-vm-stop
```

Behavior notes:

- Starting either VM auto-creates or reuses the session container.
- `dual-vm-stop` stops both QEMU processes, deletes TAPs, and removes the session container.
- VM logs are inside the session container at `/tmp/vm1.log` and `/tmp/vm2.log`.

## 5) CPU Pinning

CPU pinning is implemented at two layers.

### 5.1 Host-level pinning (QEMU threads)

Environment variables:

- `DUAL_VM1_HOST_CPUSET`
- `DUAL_VM2_HOST_CPUSET`
- `DUAL_VM1_VCPUS`
- `DUAL_VM2_VCPUS`
- `DUAL_VM1_MEMORY_MB`
- `DUAL_VM2_MEMORY_MB`

Default mode is `auto` for both VMs.

Accepted format: `taskset` cpuset syntax, for example:

- `0-7`
- `0-3,8-11`

Supported modes:

- `auto`: derive cpuset from host topology (physical-core first threads, split by socket if available)
- `off`: disable host-level pinning
- explicit cpuset: manual `taskset` format

How it is applied:

1. VM start command is wrapped with `taskset -c <cpuset> ... yifei-q ...`
2. After QEMU PID is known, script runs `taskset -apc <cpuset> <pid>`

This second step applies affinity to all current QEMU threads under that process.

Recommended: use non-overlapping host core sets between vm1 and vm2 to reduce cross-VM CPU contention.

Example:

```bash
DUAL_VM1_HOST_CPUSET="0-7" \
DUAL_VM2_HOST_CPUSET="8-15" \
make dual-vm1

DUAL_VM1_HOST_CPUSET="0-7" \
DUAL_VM2_HOST_CPUSET="8-15" \
make dual-vm2
```

Disable host pinning example:

```bash
DUAL_VM1_HOST_CPUSET="off" \
DUAL_VM2_HOST_CPUSET="off" \
make dual-vm1
```

### 5.2 Guest-level pinning (Exp1 workload processes)

For Experiment 1 (`scripts/exp1/run.sh`):

- `EXP1_NGINX_CPUSET`: pins nginx process in vm1 via `taskset -c`
- `EXP1_WRK_CPUSET`: pins wrk process in vm2 via `taskset -c`

Defaults:

- `EXP1_NGINX_CPUSET=0-3`
- `EXP1_WRK_CPUSET=0-3`

Accepted format is the same cpuset syntax.

Example:

```bash
DUAL_VM1_HOST_CPUSET="0-7" \
DUAL_VM2_HOST_CPUSET="8-15" \
EXP1_NGINX_CPUSET="0-3" \
EXP1_WRK_CPUSET="0-3" \
make exp1-run
```

Disable guest pinning example:

```bash
EXP1_NGINX_CPUSET="off" \
EXP1_WRK_CPUSET="off" \
make exp1-run
```

Important:

- Guest CPU IDs are guest vCPU indices.
- With current defaults (`-smp 4`), guest cpuset should stay within `0-3`.

## 6) Experiment-1 Traffic Path (Current)

Current Exp1 baseline path:

`vm2 (wrk client) -> vm1 (nginx server)`

Current defaults in `Makefile`:

- `EXP1_WRK_CONNECTIONS = 1 2 4 8 16 32 64 128 256`
- `EXP1_WRK_THREADS = 4`
- `EXP1_WRK_WARMUP = 15`
- `EXP1_WRK_DURATION = 60`
- `EXP1_WRK_REPEATS = 5`
- `EXP1_NGINX_CPUSET = 0-3`
- `EXP1_WRK_CPUSET = 0-3`

Per measured run, Exp1 also records vm1/vm2 CPU utilization (from `/proc/stat` deltas) into:

- `wrk-summary.csv`: `vm1_cpu_util_pct`, `vm2_cpu_util_pct`
- `wrk-summary-agg.csv`: `vm1_cpu_util_pct_mean`, `vm2_cpu_util_pct_mean`

The default overview plot includes these utilization curves with error bars across repeats.

Server target defaults in `scripts/exp1/run.sh`:

- server IP: `192.168.100.1`
- server port: `8080`
- file: `exp1-1k.txt`

Exp1 sanity checks include:

- vm2 ping vm1 data IP
- vm2 curl vm1 payload + `/healthz`
- nginx access log line growth check on vm1

## 7) Useful Verification Commands

### 7.1 Verify dual-VM status

```bash
make dual-vm-status
```

### 7.2 Verify host-level QEMU pinning

```bash
docker exec dual-vm-session bash -lc 'taskset -cp $(cat /tmp/vm1.pid)'
docker exec dual-vm-session bash -lc 'taskset -cp $(cat /tmp/vm2.pid)'
```

### 7.3 Verify data-plane connectivity

```bash
./scripts/dual-vm.sh ssh vm1 'ip -4 addr'
./scripts/dual-vm.sh ssh vm2 'ping -c 2 192.168.100.1'
```

### 7.4 Verify guest process pinning (Exp1)

```bash
./scripts/dual-vm.sh ssh vm1 'for p in $(pgrep -x nginx); do taskset -cp $p; done'
./scripts/dual-vm.sh ssh vm2 'pgrep -x wrk | xargs -r -n1 taskset -cp'
```

Note: `wrk` is short-lived per run point; use a longer duration if you want to inspect it while running.

## 8) Current Constraints and Caveats

- Guest filesystem changes are ephemeral per boot due overlay-based setup in `yifei-q` guest bootstrap.
- VM compute shape is configurable via `DUAL_VM{1,2}_VCPUS` and `DUAL_VM{1,2}_MEMORY_MB` (defaults in this repo are 4 vCPU / 4096 MiB per VM).
- Host-level QEMU pinning is enabled by default (`auto`) for dual-VM workflows; if needed, set `off`.
- Guest-level process pinning is enabled by default for Exp1; Exp2/Exp3 guest-level defaults are not yet implemented because those pipelines are still scaffold-only.
