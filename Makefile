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
KATRAN_MODE ?= baseline-no-katran
KATRAN_RATE_PPS ?= 200000
KATRAN_DURATION_SECS ?= 30
KATRAN_REPEATS ?= 3
KATRAN_RATES ?= 50000 100000 150000 200000 250000 300000 350000 400000 450000 500000 550000 600000 650000 700000 750000 800000 850000 900000 950000 1000000
KATRAN_PROGRESS_INTERVAL ?= 1
KATRAN_SUITE_DIR ?=
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

# connect running qemu by ssh
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

katran-exp-one:
	RUNTIME_IMAGE=${RUNTIME_IMAGE} \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM1_NET_PORT=${DUAL_VM1_NET_PORT} DUAL_VM1_GDB_PORT=${DUAL_VM1_GDB_PORT} \
	DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} DUAL_VM2_NET_PORT=${DUAL_VM2_NET_PORT} DUAL_VM2_GDB_PORT=${DUAL_VM2_GDB_PORT} \
	${KATRAN_SCRIPT_DIR}/run-experiment.sh --mode ${KATRAN_MODE} --rate-pps ${KATRAN_RATE_PPS} --duration ${KATRAN_DURATION_SECS}

katran-exp-suite:
	RUNTIME_IMAGE=${RUNTIME_IMAGE} \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM1_NET_PORT=${DUAL_VM1_NET_PORT} DUAL_VM1_GDB_PORT=${DUAL_VM1_GDB_PORT} \
	DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} DUAL_VM2_NET_PORT=${DUAL_VM2_NET_PORT} DUAL_VM2_GDB_PORT=${DUAL_VM2_GDB_PORT} \
	${KATRAN_SCRIPT_DIR}/run-suite.sh --rates "${KATRAN_RATES}" --repeats ${KATRAN_REPEATS} --duration ${KATRAN_DURATION_SECS} --progress-interval ${KATRAN_PROGRESS_INTERVAL}

katran-install-plot-tool:
	${KATRAN_SCRIPT_DIR}/install-gnuplot-user.sh

katran-plot-suite:
	if [ -n "${KATRAN_SUITE_DIR}" ]; then \
		${KATRAN_SCRIPT_DIR}/plot-suite.sh --install-gnuplot-user --suite-dir ${KATRAN_SUITE_DIR}; \
	else \
		${KATRAN_SCRIPT_DIR}/plot-suite.sh --install-gnuplot-user; \
	fi
