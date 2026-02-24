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
DUAL_VM1_HOST_CPUSET ?= auto
DUAL_VM2_HOST_CPUSET ?= auto
DUAL_VM1_MEMORY_MB ?= 4096
DUAL_VM2_MEMORY_MB ?= 4096
DUAL_VM1_VCPUS ?= 4
DUAL_VM2_VCPUS ?= 4
KTRACK ?= ${BASE_PROJ}/tools/kernel-track/ktrack.sh
EXP1_SCRIPT_DIR ?= ${BASE_PROJ}/scripts/exp1
EXP1_KATRAN_BUILD_SCRIPT ?= ${BASE_PROJ}/scripts/exp1/build-katran.sh
EXP1_MODE ?= both
EXP1_WRK_CONNECTIONS ?= 1 2 4 8 16 32 64 128 256
EXP1_WRK_THREADS ?= 4
EXP1_WRK_WARMUP ?= 15
EXP1_WRK_DURATION ?= 60
EXP1_WRK_REPEATS ?= 5
EXP1_NGINX_CPUSET ?= 0-3
EXP1_WRK_CPUSET ?= 0-3
EXP1_KATRAN_CPUSET ?= 0-3
EXP1_KATRAN_VIP ?= 192.168.100.100
EXP1_KATRAN_GRPC_PORT ?= 50051
EXP1_KATRAN_DEFAULT_MAC ?= 52:54:00:aa:00:22
EXP1_KATRAN_FORWARDING_CORES ?= 0,1,2,3
EXP1_KATRAN_LRU_SIZE ?= 1000000
EXP1_KATRAN_SERVER_BIN ?= /linux-dev-env/source/katran/_build/build/example_grpc/katran_server_grpc
EXP1_KATRAN_BPF_OBJ ?= /linux-dev-env/source/katran/_build/deps/bpfprog/bpf/balancer.bpf.o
EXP1_KATRAN_GOCLIENT_BIN ?= /linux-dev-env/source/katran/example_grpc/goclient/src/katranc/main/main
EXP1_KATRAN_LIB_DIRS ?= /linux-dev-env/source/katran/_build/deps/lib:/linux-dev-env/source/katran/_build/deps/lib64
EXP1_KATRAN_AUTO_BUILD ?= 1
EXP1_KATRAN_FORCE_REBUILD ?= 0
EXP1_KATRAN_INSTALL_BUILD_DEPS ?= 1
EXP1_RUN_DIR ?=
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
	DUAL_VM1_HOST_CPUSET=${DUAL_VM1_HOST_CPUSET} DUAL_VM2_HOST_CPUSET=${DUAL_VM2_HOST_CPUSET} \
	DUAL_VM1_MEMORY_MB=${DUAL_VM1_MEMORY_MB} DUAL_VM2_MEMORY_MB=${DUAL_VM2_MEMORY_MB} \
	DUAL_VM1_VCPUS=${DUAL_VM1_VCPUS} DUAL_VM2_VCPUS=${DUAL_VM2_VCPUS} \
	${DUAL_VM_SCRIPT} start vm1

dual-vm2:
	LINUX_DIR=${LINUX} RUNTIME_IMAGE=$(RUNTIME_IMAGE) \
	DUAL_VM1_SSH_PORT=${DUAL_VM1_SSH_PORT} DUAL_VM1_NET_PORT=${DUAL_VM1_NET_PORT} DUAL_VM1_GDB_PORT=${DUAL_VM1_GDB_PORT} \
	DUAL_VM2_SSH_PORT=${DUAL_VM2_SSH_PORT} DUAL_VM2_NET_PORT=${DUAL_VM2_NET_PORT} DUAL_VM2_GDB_PORT=${DUAL_VM2_GDB_PORT} \
	DUAL_VM1_HOST_CPUSET=${DUAL_VM1_HOST_CPUSET} DUAL_VM2_HOST_CPUSET=${DUAL_VM2_HOST_CPUSET} \
	DUAL_VM1_MEMORY_MB=${DUAL_VM1_MEMORY_MB} DUAL_VM2_MEMORY_MB=${DUAL_VM2_MEMORY_MB} \
	DUAL_VM1_VCPUS=${DUAL_VM1_VCPUS} DUAL_VM2_VCPUS=${DUAL_VM2_VCPUS} \
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
	DUAL_VM1_HOST_CPUSET=${DUAL_VM1_HOST_CPUSET} DUAL_VM2_HOST_CPUSET=${DUAL_VM2_HOST_CPUSET} \
	DUAL_VM1_MEMORY_MB=${DUAL_VM1_MEMORY_MB} DUAL_VM2_MEMORY_MB=${DUAL_VM2_MEMORY_MB} \
	DUAL_VM1_VCPUS=${DUAL_VM1_VCPUS} DUAL_VM2_VCPUS=${DUAL_VM2_VCPUS} \
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

exp1-katran-build:
	EXP1_KATRAN_FORCE_REBUILD="$(EXP1_KATRAN_FORCE_REBUILD)" \
	EXP1_KATRAN_INSTALL_BUILD_DEPS="$(EXP1_KATRAN_INSTALL_BUILD_DEPS)" \
	${EXP1_KATRAN_BUILD_SCRIPT}

exp1-run:
	DUAL_VM1_HOST_CPUSET="$(DUAL_VM1_HOST_CPUSET)" \
	DUAL_VM2_HOST_CPUSET="$(DUAL_VM2_HOST_CPUSET)" \
	DUAL_VM1_MEMORY_MB="$(DUAL_VM1_MEMORY_MB)" \
	DUAL_VM2_MEMORY_MB="$(DUAL_VM2_MEMORY_MB)" \
	DUAL_VM1_VCPUS="$(DUAL_VM1_VCPUS)" \
	DUAL_VM2_VCPUS="$(DUAL_VM2_VCPUS)" \
	EXP1_MODE="$(EXP1_MODE)" \
	EXP1_WRK_CONNECTIONS="$(EXP1_WRK_CONNECTIONS)" \
	EXP1_WRK_THREADS="$(EXP1_WRK_THREADS)" \
	EXP1_WRK_WARMUP="$(EXP1_WRK_WARMUP)" \
	EXP1_WRK_DURATION="$(EXP1_WRK_DURATION)" \
	EXP1_WRK_REPEATS="$(EXP1_WRK_REPEATS)" \
	EXP1_NGINX_CPUSET="$(EXP1_NGINX_CPUSET)" \
	EXP1_WRK_CPUSET="$(EXP1_WRK_CPUSET)" \
	EXP1_KATRAN_CPUSET="$(EXP1_KATRAN_CPUSET)" \
	EXP1_KATRAN_VIP="$(EXP1_KATRAN_VIP)" \
	EXP1_KATRAN_GRPC_PORT="$(EXP1_KATRAN_GRPC_PORT)" \
	EXP1_KATRAN_DEFAULT_MAC="$(EXP1_KATRAN_DEFAULT_MAC)" \
	EXP1_KATRAN_FORWARDING_CORES="$(EXP1_KATRAN_FORWARDING_CORES)" \
	EXP1_KATRAN_LRU_SIZE="$(EXP1_KATRAN_LRU_SIZE)" \
	EXP1_KATRAN_SERVER_BIN="$(EXP1_KATRAN_SERVER_BIN)" \
	EXP1_KATRAN_BPF_OBJ="$(EXP1_KATRAN_BPF_OBJ)" \
	EXP1_KATRAN_GOCLIENT_BIN="$(EXP1_KATRAN_GOCLIENT_BIN)" \
	EXP1_KATRAN_LIB_DIRS="$(EXP1_KATRAN_LIB_DIRS)" \
	EXP1_KATRAN_AUTO_BUILD="$(EXP1_KATRAN_AUTO_BUILD)" \
	${EXP1_SCRIPT_DIR}/run.sh

exp1-smoke:
	DUAL_VM1_HOST_CPUSET="$(DUAL_VM1_HOST_CPUSET)" \
	DUAL_VM2_HOST_CPUSET="$(DUAL_VM2_HOST_CPUSET)" \
	DUAL_VM1_MEMORY_MB="$(DUAL_VM1_MEMORY_MB)" \
	DUAL_VM2_MEMORY_MB="$(DUAL_VM2_MEMORY_MB)" \
	DUAL_VM1_VCPUS="$(DUAL_VM1_VCPUS)" \
	DUAL_VM2_VCPUS="$(DUAL_VM2_VCPUS)" \
	EXP1_MODE="direct" \
	EXP1_WRK_THREADS="1" \
	EXP1_WRK_CONNECTIONS="1 2" \
	EXP1_WRK_WARMUP="2" \
	EXP1_WRK_DURATION="4" \
	EXP1_WRK_REPEATS="1" \
	EXP1_NGINX_CPUSET="$(EXP1_NGINX_CPUSET)" \
	EXP1_WRK_CPUSET="$(EXP1_WRK_CPUSET)" \
	${EXP1_SCRIPT_DIR}/run.sh

exp1-plot:
	@if [ -z "$(EXP1_RUN_DIR)" ]; then \
		echo "set EXP1_RUN_DIR=results/exp1/<run-id>-<direct-nginx|vanilla-katran>"; \
		exit 1; \
	fi
	MPLCONFIGDIR=/tmp/mplconfig-exp1 python3 ${EXP1_SCRIPT_DIR}/plot.py --run-dir "$(EXP1_RUN_DIR)"

test:
	./tests/run.sh
