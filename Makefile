BASE_PROJ ?= $(shell pwd)
LINUX ?= ${BASE_PROJ}/linux
RUNTIME_IMAGE ?= zhengjie-dual-vm

SSH_PORT ?= "51022"
NET_PORT ?= "51023"
GDB_PORT ?= "1210"

DUAL_VM_SCRIPT ?= ${BASE_PROJ}/scripts/dual-vm.sh
DUAL_VM1_SSH_PORT ?= "53022"
DUAL_VM1_NET_PORT ?= "53023"
DUAL_VM1_GDB_PORT ?= "1311"
DUAL_VM2_SSH_PORT ?= "53122"
DUAL_VM2_NET_PORT ?= "53123"
DUAL_VM2_GDB_PORT ?= "1312"

KTRACK ?= ${BASE_PROJ}/tools/kernel-track/ktrack.sh
KATRAN_SCRIPT_DIR ?= ${BASE_PROJ}/scripts/katran

EXP_SCRIPT_DIR ?= ${BASE_PROJ}/scripts/experiments
EXP1_SCRIPT_DIR ?= ${EXP_SCRIPT_DIR}/exp1
EXP2_SCRIPT_DIR ?= ${EXP_SCRIPT_DIR}/exp2
EXP3_SCRIPT_DIR ?= ${EXP_SCRIPT_DIR}/exp3

KATRAN_MODE ?= baseline-no-katran
KATRAN_RATE_PPS ?= 200000
KATRAN_DURATION_SECS ?= 30
KATRAN_REPEATS ?= 3
KATRAN_RATES ?= 50000 100000 150000 200000 250000 300000 350000 400000 450000 500000 550000 600000 650000 700000 750000 800000 850000 900000 950000 1000000
KATRAN_PROGRESS_INTERVAL ?= 1
KATRAN_SUITE_DIR ?=

EXP1_MODE ?= ${KATRAN_MODE}
EXP1_RATE_PPS ?= ${KATRAN_RATE_PPS}
EXP1_DURATION_SECS ?= ${KATRAN_DURATION_SECS}
EXP1_REPEATS ?= ${KATRAN_REPEATS}
EXP1_RATES ?= ${KATRAN_RATES}
EXP1_PROGRESS_INTERVAL ?= ${KATRAN_PROGRESS_INTERVAL}
EXP1_MODES ?= baseline-no-katran katran-orig-bpf
EXP1_RESULTS_RUNS_DIR ?= ${BASE_PROJ}/results/exp1/runs
EXP1_RESULTS_SUITES_DIR ?= ${BASE_PROJ}/results/exp1/suites

EXP2_BASE_SOURCE_DIR ?= ${BASE_PROJ}/source/katran
EXP2_SOURCE_DIR ?= ${BASE_PROJ}/source/katran-exp2
EXP2_ORACLE_OBJ ?= ${EXP2_SOURCE_DIR}/build/katran/lib/bpf/balancer.bpf.o
EXP2_ORACLE_PATCH ?= ${BASE_PROJ}/scripts/experiments/exp2/patches/oracle-default.patch
EXP2_ORIG_OBJ ?= ${EXP2_BASE_SOURCE_DIR}/build/katran/lib/bpf/balancer.bpf.o
EXP2_BYTECODE_OUT_DIR ?= ${BASE_PROJ}/results/exp2/analysis/bytecode-compare

EXP2_PRECHECK_OUT_DIR ?= ${BASE_PROJ}/results/exp2/precheck
EXP2_SETUP_OUT_DIR ?= ${BASE_PROJ}/results/exp2/setup
EXP2_SMOKE_OUT_DIR ?= ${BASE_PROJ}/results/exp2/smoke
EXP2_DISCOVERY_OUT_DIR ?= ${BASE_PROJ}/results/exp2/discovery
EXP2_THROUGHPUT_OUT_DIR ?= ${BASE_PROJ}/results/exp2/measurement/throughput
EXP2_LATENCY_OUT_DIR ?= ${BASE_PROJ}/results/exp2/measurement/latency
EXP2_ANALYSIS_OUT_DIR ?= ${BASE_PROJ}/results/exp2/analysis
EXP2_ANALYSIS_DIR ?=
EXP2_PLOT_OUT_DIR ?=
EXP2_ORACLE_BUILD_OUT_DIR ?= ${BASE_PROJ}/results/exp2/oracle-builds

EXP2_RATES ?= ${EXP1_RATES}
EXP2_REPEATS ?= ${EXP1_REPEATS}
EXP2_DURATION_SECS ?= ${EXP1_DURATION_SECS}
EXP2_PROGRESS_INTERVAL ?= ${EXP1_PROGRESS_INTERVAL}

EXP2_LAT_RATES ?= 100000 300000 600000 900000
EXP2_LAT_REPEATS ?= 3
EXP2_LAT_DURATION_SECS ?= 30
EXP2_LAT_PING_INTERVAL ?= 0.02
EXP2_LAT_PROGRESS_INTERVAL ?= ${EXP2_PROGRESS_INTERVAL}

EXP2_DISCOVERY_RATE_PPS ?= 600000
EXP2_DISCOVERY_DURATION_SECS ?= 120
EXP2_DISCOVERY_INTERVAL_SECS ?= 30
EXP2_DISCOVERY_MAX_DUMP_LINES ?= 2000
EXP2_RUN_ALL_EXTRA_ARGS ?=

.ALWAYS:

all: vmlinux

docker: .ALWAYS
	docker buildx build --network=host --progress=plain -t $(RUNTIME_IMAGE) .

qemu-run:
	docker run --privileged --rm \
	--device=/dev/kvm:/dev/kvm \
	-v ${BASE_PROJ}:/linux-dev-env -v ${LINUX}:/linux \
	-w /linux \
	-p 127.0.0.1:${SSH_PORT}:52222 \
	-p 127.0.0.1:${NET_PORT}:52223 \
	-p 127.0.0.1:${GDB_PORT}:1234 \
	-it $(RUNTIME_IMAGE):latest \
	/linux-dev-env/q-script/yifei-q -s

qemu-ssh:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -t root@127.0.0.1 -p ${SSH_PORT}

dual-vm1:
	LINUX_DIR=${LINUX} RUNTIME_IMAGE=$(RUNTIME_IMAGE) \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM1_NET_PORT=${DUAL_VM1_NET_PORT} DUAL_VM1_GDB_PORT=${DUAL_VM1_GDB_PORT} \
	DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} DUAL_VM2_NET_PORT=${DUAL_VM2_NET_PORT} DUAL_VM2_GDB_PORT=${DUAL_VM2_GDB_PORT} \
	${DUAL_VM_SCRIPT} start vm1

dual-vm2:
	LINUX_DIR=${LINUX} RUNTIME_IMAGE=$(RUNTIME_IMAGE) \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM1_NET_PORT=${DUAL_VM1_NET_PORT} DUAL_VM1_GDB_PORT=${DUAL_VM1_GDB_PORT} \
	DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} DUAL_VM2_NET_PORT=${DUAL_VM2_NET_PORT} DUAL_VM2_GDB_PORT=${DUAL_VM2_GDB_PORT} \
	${DUAL_VM_SCRIPT} start vm2

dual-vm1-ssh:
	LINUX_DIR=${LINUX} RUNTIME_IMAGE=$(RUNTIME_IMAGE) \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} \
	${DUAL_VM_SCRIPT} ssh vm1

dual-vm2-ssh:
	LINUX_DIR=${LINUX} RUNTIME_IMAGE=$(RUNTIME_IMAGE) \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} \
	${DUAL_VM_SCRIPT} ssh vm2

dual-vm-status:
	LINUX_DIR=${LINUX} RUNTIME_IMAGE=$(RUNTIME_IMAGE) \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} \
	${DUAL_VM_SCRIPT} status

dual-vm-stop:
	LINUX_DIR=${LINUX} RUNTIME_IMAGE=$(RUNTIME_IMAGE) \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM1_NET_PORT=${DUAL_VM1_NET_PORT} DUAL_VM1_GDB_PORT=${DUAL_VM1_GDB_PORT} \
	DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} DUAL_VM2_NET_PORT=${DUAL_VM2_NET_PORT} DUAL_VM2_GDB_PORT=${DUAL_VM2_GDB_PORT} \
	${DUAL_VM_SCRIPT} stop all

vmlinux:
	KTRACK_KERNEL_DIR=${LINUX} ${KTRACK} auto-checkpoint --label vmlinux
	docker run --rm -v ${LINUX}:/linux -w /linux $(RUNTIME_IMAGE) make -j`nproc` bzImage

headers-install:
	KTRACK_KERNEL_DIR=${LINUX} ${KTRACK} auto-checkpoint --label headers-install
	docker run --rm -v ${LINUX}:/linux -w /linux $(RUNTIME_IMAGE) make -j`nproc` headers_install

modules-install:
	KTRACK_KERNEL_DIR=${LINUX} ${KTRACK} auto-checkpoint --label modules-install
	docker run --rm -v ${LINUX}:/linux -w /linux $(RUNTIME_IMAGE) make -j`nproc` modules
	docker run --rm -v ${LINUX}:/linux -w /linux $(RUNTIME_IMAGE) make -j`nproc` modules_install

kernel:
	KTRACK_KERNEL_DIR=${LINUX} ${KTRACK} auto-checkpoint --label kernel
	docker run --rm -v ${LINUX}:/linux -w /linux $(RUNTIME_IMAGE) make -j`nproc`

linux-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux $(RUNTIME_IMAGE) make distclean

enter-docker:
	docker run --rm -v ${BASE_PROJ}:/linux-dev-env -w /linux-dev-env -it $(RUNTIME_IMAGE) /bin/bash

libbpf:
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/lib/bpf $(RUNTIME_IMAGE) make -j`nproc`

libbpf-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/lib/bpf $(RUNTIME_IMAGE) make clean -j`nproc`

bpftool:
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/bpf/bpftool $(RUNTIME_IMAGE) make -j`nproc`

bpftool-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/bpf/bpftool $(RUNTIME_IMAGE) make clean -j`nproc`

ktrack-status:
	KTRACK_KERNEL_DIR=${LINUX} ${KTRACK} status

ktrack-list:
	KTRACK_KERNEL_DIR=${LINUX} ${KTRACK} list

ktrack-checkpoint:
	KTRACK_KERNEL_DIR=${LINUX} ${KTRACK} checkpoint --label manual

test-ktrack:
	./tools/kernel-track/tests/run.sh

test-vm-dev:
	./tests/vm-linux-dev/run.sh

test:
	./tests/run.sh

katran-clone:
	${KATRAN_SCRIPT_DIR}/clone-katran.sh --runtime-image ${RUNTIME_IMAGE}

katran-build-host:
	${KATRAN_SCRIPT_DIR}/build-katran-host.sh --runtime-image ${RUNTIME_IMAGE}

katran-vm1-setup:
	${DUAL_VM_SCRIPT} ssh vm1 /linux-dev-env/scripts/katran/vm1-setup.sh

katran-vm2-setup:
	${DUAL_VM_SCRIPT} ssh vm2 /linux-dev-env/scripts/katran/vm2-setup.sh

exp-results-init:
	${EXP_SCRIPT_DIR}/init-results-layout.sh

exp1-vm-setup:
	${EXP1_SCRIPT_DIR}/vm-setup.sh

exp1-run-one:
	RUNTIME_IMAGE=${RUNTIME_IMAGE} \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM1_NET_PORT=${DUAL_VM1_NET_PORT} DUAL_VM1_GDB_PORT=${DUAL_VM1_GDB_PORT} \
	DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} DUAL_VM2_NET_PORT=${DUAL_VM2_NET_PORT} DUAL_VM2_GDB_PORT=${DUAL_VM2_GDB_PORT} \
	EXP1_MODE=${EXP1_MODE} EXP1_RATE_PPS=${EXP1_RATE_PPS} EXP1_DURATION_SECS=${EXP1_DURATION_SECS} EXP1_RUNS_DIR=${EXP1_RESULTS_RUNS_DIR} \
	${EXP1_SCRIPT_DIR}/run-one.sh

exp1-run-suite:
	RUNTIME_IMAGE=${RUNTIME_IMAGE} \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM1_NET_PORT=${DUAL_VM1_NET_PORT} DUAL_VM1_GDB_PORT=${DUAL_VM1_GDB_PORT} \
	DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} DUAL_VM2_NET_PORT=${DUAL_VM2_NET_PORT} DUAL_VM2_GDB_PORT=${DUAL_VM2_GDB_PORT} \
	EXP1_MODES="${EXP1_MODES}" EXP1_RATES="${EXP1_RATES}" EXP1_REPEATS=${EXP1_REPEATS} EXP1_DURATION_SECS=${EXP1_DURATION_SECS} EXP1_PROGRESS_INTERVAL=${EXP1_PROGRESS_INTERVAL} EXP1_SUITES_DIR=${EXP1_RESULTS_SUITES_DIR} \
	${EXP1_SCRIPT_DIR}/run-suite.sh

exp1-plot-latest:
	EXP1_SUITES_DIR=${EXP1_RESULTS_SUITES_DIR} EXP1_SUITE_DIR=${KATRAN_SUITE_DIR} \
	${EXP1_SCRIPT_DIR}/plot-latest.sh

exp2-precheck:
	${EXP2_SCRIPT_DIR}/precheck.sh --out-root ${EXP2_PRECHECK_OUT_DIR}

exp2-vm-setup:
	${EXP2_SCRIPT_DIR}/vm-setup.sh --out-root ${EXP2_SETUP_OUT_DIR}

exp2-prepare-source:
	RUNTIME_IMAGE=${RUNTIME_IMAGE} ${EXP2_SCRIPT_DIR}/prepare-source.sh --base-src ${EXP2_BASE_SOURCE_DIR} --exp2-src ${EXP2_SOURCE_DIR} --runtime-image ${RUNTIME_IMAGE}

exp2-build-oracle:
	@if [ -n "${EXP2_ORACLE_PATCH}" ]; then \
		RUNTIME_IMAGE=${RUNTIME_IMAGE} ${EXP2_SCRIPT_DIR}/build-oracle.sh --base-src ${EXP2_BASE_SOURCE_DIR} --exp2-src ${EXP2_SOURCE_DIR} --runtime-image ${RUNTIME_IMAGE} --out-root ${EXP2_ORACLE_BUILD_OUT_DIR} --patch ${EXP2_ORACLE_PATCH}; \
	else \
		RUNTIME_IMAGE=${RUNTIME_IMAGE} ${EXP2_SCRIPT_DIR}/build-oracle.sh --base-src ${EXP2_BASE_SOURCE_DIR} --exp2-src ${EXP2_SOURCE_DIR} --runtime-image ${RUNTIME_IMAGE} --out-root ${EXP2_ORACLE_BUILD_OUT_DIR}; \
	fi

exp2-bytecode-compare:
	${EXP2_SCRIPT_DIR}/bytecode-compare.sh --orig-obj ${EXP2_ORIG_OBJ} --oracle-obj ${EXP2_ORACLE_OBJ} --out-dir ${EXP2_BYTECODE_OUT_DIR}

exp2-test-smoke:
	RUNTIME_IMAGE=${RUNTIME_IMAGE} ${EXP2_SCRIPT_DIR}/test-smoke.sh --out-root ${EXP2_SMOKE_OUT_DIR} --oracle-obj ${EXP2_ORACLE_OBJ}

exp2-discovery:
	RUNTIME_IMAGE=${RUNTIME_IMAGE} ${EXP2_SCRIPT_DIR}/discovery.sh --out-root ${EXP2_DISCOVERY_OUT_DIR} --rate-pps ${EXP2_DISCOVERY_RATE_PPS} --duration ${EXP2_DISCOVERY_DURATION_SECS} --interval ${EXP2_DISCOVERY_INTERVAL_SECS} --max-dump-lines ${EXP2_DISCOVERY_MAX_DUMP_LINES}

exp2-run-throughput:
	RUNTIME_IMAGE=${RUNTIME_IMAGE} ${EXP2_SCRIPT_DIR}/run-throughput.sh --out-root ${EXP2_THROUGHPUT_OUT_DIR} --rates "${EXP2_RATES}" --repeats ${EXP2_REPEATS} --duration ${EXP2_DURATION_SECS} --progress-interval ${EXP2_PROGRESS_INTERVAL} --oracle-obj ${EXP2_ORACLE_OBJ}

exp2-run-latency:
	RUNTIME_IMAGE=${RUNTIME_IMAGE} ${EXP2_SCRIPT_DIR}/run-latency.sh --out-root ${EXP2_LATENCY_OUT_DIR} --rates "${EXP2_LAT_RATES}" --repeats ${EXP2_LAT_REPEATS} --duration ${EXP2_LAT_DURATION_SECS} --ping-interval ${EXP2_LAT_PING_INTERVAL} --progress-interval ${EXP2_LAT_PROGRESS_INTERVAL} --oracle-obj ${EXP2_ORACLE_OBJ}

exp2-analyze:
	${EXP2_SCRIPT_DIR}/analyze.sh --throughput-root ${EXP2_THROUGHPUT_OUT_DIR} --latency-root ${EXP2_LATENCY_OUT_DIR} --out-root ${EXP2_ANALYSIS_OUT_DIR}

exp2-install-plot-tool:
	${KATRAN_SCRIPT_DIR}/install-gnuplot-user.sh

exp2-plot:
	@args="--analysis-root ${EXP2_ANALYSIS_OUT_DIR} --install-gnuplot-user"; \
	if [ -n "${EXP2_ANALYSIS_DIR}" ]; then args="--analysis-dir ${EXP2_ANALYSIS_DIR} --install-gnuplot-user"; fi; \
	if [ -n "${EXP2_PLOT_OUT_DIR}" ]; then args="$$args --out-dir ${EXP2_PLOT_OUT_DIR}"; fi; \
	${EXP2_SCRIPT_DIR}/plot.sh $$args

exp2-run-all:
	@if [ -n "${EXP2_ORACLE_PATCH}" ]; then \
		RUNTIME_IMAGE=${RUNTIME_IMAGE} ${EXP2_SCRIPT_DIR}/run-all.sh --runtime-image ${RUNTIME_IMAGE} --patch ${EXP2_ORACLE_PATCH} --tp-rates "${EXP2_RATES}" --tp-repeats ${EXP2_REPEATS} --tp-duration ${EXP2_DURATION_SECS} --tp-progress-interval ${EXP2_PROGRESS_INTERVAL} --lat-rates "${EXP2_LAT_RATES}" --lat-repeats ${EXP2_LAT_REPEATS} --lat-duration ${EXP2_LAT_DURATION_SECS} --lat-ping-interval ${EXP2_LAT_PING_INTERVAL} --lat-progress-interval ${EXP2_LAT_PROGRESS_INTERVAL} --discovery-rate ${EXP2_DISCOVERY_RATE_PPS} --discovery-duration ${EXP2_DISCOVERY_DURATION_SECS} --discovery-interval ${EXP2_DISCOVERY_INTERVAL_SECS} --discovery-max-dump-lines ${EXP2_DISCOVERY_MAX_DUMP_LINES} ${EXP2_RUN_ALL_EXTRA_ARGS}; \
	else \
		RUNTIME_IMAGE=${RUNTIME_IMAGE} ${EXP2_SCRIPT_DIR}/run-all.sh --runtime-image ${RUNTIME_IMAGE} --tp-rates "${EXP2_RATES}" --tp-repeats ${EXP2_REPEATS} --tp-duration ${EXP2_DURATION_SECS} --tp-progress-interval ${EXP2_PROGRESS_INTERVAL} --lat-rates "${EXP2_LAT_RATES}" --lat-repeats ${EXP2_LAT_REPEATS} --lat-duration ${EXP2_LAT_DURATION_SECS} --lat-ping-interval ${EXP2_LAT_PING_INTERVAL} --lat-progress-interval ${EXP2_LAT_PROGRESS_INTERVAL} --discovery-rate ${EXP2_DISCOVERY_RATE_PPS} --discovery-duration ${EXP2_DISCOVERY_DURATION_SECS} --discovery-interval ${EXP2_DISCOVERY_INTERVAL_SECS} --discovery-max-dump-lines ${EXP2_DISCOVERY_MAX_DUMP_LINES} ${EXP2_RUN_ALL_EXTRA_ARGS}; \
	fi
exp3-auto-v0:
	${EXP3_SCRIPT_DIR}/run-auto-v0.sh

# Backward-compatible aliases
katran-exp-one: exp1-run-one

katran-exp-suite: exp1-run-suite

katran-install-plot-tool:
	${KATRAN_SCRIPT_DIR}/install-gnuplot-user.sh

katran-plot-suite:
	if [ -n "${KATRAN_SUITE_DIR}" ]; then \
		${KATRAN_SCRIPT_DIR}/plot-suite.sh --install-gnuplot-user --suite-dir ${KATRAN_SUITE_DIR}; \
	else \
		$(MAKE) exp1-plot-latest; \
	fi
