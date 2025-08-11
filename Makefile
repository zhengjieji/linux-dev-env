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

# BPF Verifier Management
verifier-setup:
	@chmod +x scripts/setup_verifiers.sh
	@./scripts/setup_verifiers.sh $(LINUX)

verifier-replace:
	@chmod +x scripts/replace_verifier.sh
	@./scripts/replace_verifier.sh $(LINUX)

verifier-revert:
	@chmod +x scripts/revert_verifier.sh
	@./scripts/revert_verifier.sh $(LINUX)

verifier-status:
	@echo "=== BPF Verifier Status ==="
	@if [ -f $(LINUX)/kernel/bpf/verifier.c.original ]; then \
		echo "✓ Backup: $(LINUX)/kernel/bpf/verifier.c.original"; \
	else \
		echo "✗ Backup: Not found (run 'make verifier-setup')"; \
	fi
	@if [ -f verifiers/original.c ]; then \
		echo "✓ Original: verifiers/original.c"; \
	else \
		echo "✗ Original: Not found"; \
	fi
	@if [ -f verifiers/custom.c ]; then \
		if diff -q verifiers/original.c verifiers/custom.c >/dev/null 2>&1; then \
			echo "✓ Custom: verifiers/custom.c (unmodified)"; \
		else \
			echo "✓ Custom: verifiers/custom.c (modified)"; \
		fi; \
	else \
		echo "✗ Custom: Not found"; \
	fi
	@if [ -f $(LINUX)/kernel/bpf/verifier.c ] && [ -f verifiers/custom.c ]; then \
		if diff -q $(LINUX)/kernel/bpf/verifier.c verifiers/custom.c >/dev/null 2>&1; then \
			echo "✓ Active: Custom verifier"; \
		elif [ -f $(LINUX)/kernel/bpf/verifier.c.original ] && diff -q $(LINUX)/kernel/bpf/verifier.c $(LINUX)/kernel/bpf/verifier.c.original >/dev/null 2>&1; then \
			echo "✓ Active: Original verifier"; \
		else \
			echo "? Active: Unknown state"; \
		fi; \
	fi

verifier-clean:
	@rm -rf verifiers/
	@echo "✓ Cleaned verifier files"

.PHONY: verifier-setup verifier-replace verifier-revert verifier-status verifier-clean