BASE_PROJ ?= $(shell pwd)
LINUX ?= ${BASE_PROJ}/linux
RUNTIME_IMAGE ?= runtime-dev-zj
SSH_PORT ?= "52222"
NET_PORT ?= "52223"
GDB_PORT ?= "1234"
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

vmlinux: 
	docker run --rm -v ${LINUX}:/linux -w /linux $(RUNTIME_IMAGE) make -j`nproc` bzImage 

headers-install: 
	docker run --rm -v ${LINUX}:/linux -w /linux $(RUNTIME_IMAGE) make -j`nproc` headers_install 

modules-install: 
	docker run --rm -v ${LINUX}:/linux -w /linux $(RUNTIME_IMAGE) make -j`nproc` modules
	docker run --rm -v ${LINUX}:/linux -w /linux $(RUNTIME_IMAGE) make -j`nproc` modules_install

kernel:
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

# =============================================================================
# BPF Kernel Patch - Track kernel file modifications across experiments
# See tools/bpf-kernel-patch/README.md for documentation
# =============================================================================

PATCH_SCRIPT := ./tools/bpf-kernel-patch/patch.sh

patch-new:
	@$(PATCH_SCRIPT) new $(NAME)

patch-list:
	@$(PATCH_SCRIPT) list

patch-delete:
	@$(PATCH_SCRIPT) delete $(NAME)

patch-activate:
	@$(PATCH_SCRIPT) activate $(NAME)

patch-track:
ifdef FILES
	@LINUX=$(LINUX) $(PATCH_SCRIPT) track $(FILES)
else ifdef FILE
	@LINUX=$(LINUX) $(PATCH_SCRIPT) track $(FILE)
else
	@echo "Usage: make patch-track FILE=<path> or FILES=\"<path1> <path2>\""
	@exit 1
endif

patch-track-add:
ifdef FILES
	@LINUX=$(LINUX) $(PATCH_SCRIPT) track-add $(FILES)
else ifdef FILE
	@LINUX=$(LINUX) $(PATCH_SCRIPT) track-add $(FILE)
else
	@echo "Usage: make patch-track-add FILE=<path> or FILES=\"<path1> <path2>\""
	@exit 1
endif

patch-untrack:
ifdef FILES
	@LINUX=$(LINUX) $(PATCH_SCRIPT) untrack $(FILES)
else ifdef FILE
	@LINUX=$(LINUX) $(PATCH_SCRIPT) untrack $(FILE)
else
	@echo "Usage: make patch-untrack FILE=<path> or FILES=\"<path1> <path2>\""
	@exit 1
endif

patch-apply:
	@LINUX=$(LINUX) $(PATCH_SCRIPT) apply

patch-revert:
	@LINUX=$(LINUX) $(PATCH_SCRIPT) revert

patch-status:
	@LINUX=$(LINUX) $(PATCH_SCRIPT) status

patch-diff:
ifdef FILE
	@LINUX=$(LINUX) $(PATCH_SCRIPT) diff $(FILE)
else
	@LINUX=$(LINUX) $(PATCH_SCRIPT) diff
endif

.PHONY: patch-new patch-list patch-delete patch-activate patch-track patch-track-add \
        patch-untrack patch-apply patch-revert patch-status patch-diff

# =============================================================================
# Dual VM - Two QEMU VMs with inter-VM communication
# See docs/dual-vm.md for documentation
# =============================================================================

# Ports for VM1
VM1_SSH_PORT ?= 52222
VM1_NET_PORT ?= 52223
VM1_GDB_PORT ?= 1234
VM1_SERIAL_PORT ?= 1235

# Ports for VM2
VM2_SSH_PORT ?= 52232
VM2_NET_PORT ?= 52233
VM2_GDB_PORT ?= 1244
VM2_SERIAL_PORT ?= 1236

# Socket port for inter-VM communication
SOCKET_PORT ?= 12345

# Start VM1 (server/host) - run this first
dual-vm1:
	docker run --privileged --rm \
	--device=/dev/kvm:/dev/kvm \
	-v ${BASE_PROJ}:/linux-dev-env -v ${LINUX}:/linux \
	-w /linux \
	--network host \
	-it $(RUNTIME_IMAGE):latest \
	/linux-dev-env/q-script/dual-vm --role vm1 -s \
		--socket-port $(SOCKET_PORT) \
		--ssh-port $(VM1_SSH_PORT) \
		--net-port $(VM1_NET_PORT) \
		--serial-port $(VM1_SERIAL_PORT) \
		--gdb-port $(VM1_GDB_PORT)

# Start VM2 (client) - run this after VM1 is ready
dual-vm2:
	docker run --privileged --rm \
	--device=/dev/kvm:/dev/kvm \
	-v ${BASE_PROJ}:/linux-dev-env -v ${LINUX}:/linux \
	-w /linux \
	--network host \
	-it $(RUNTIME_IMAGE):latest \
	/linux-dev-env/q-script/dual-vm --role vm2 -s \
		--socket-port $(SOCKET_PORT) \
		--ssh-port $(VM2_SSH_PORT) \
		--net-port $(VM2_NET_PORT) \
		--serial-port $(VM2_SERIAL_PORT) \
		--gdb-port $(VM2_GDB_PORT)

# SSH to VM1
dual-vm1-ssh:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -t root@127.0.0.1 -p ${VM1_SSH_PORT}

# SSH to VM2
dual-vm2-ssh:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -t root@127.0.0.1 -p ${VM2_SSH_PORT}

.PHONY: dual-vm1 dual-vm2 dual-vm1-ssh dual-vm2-ssh