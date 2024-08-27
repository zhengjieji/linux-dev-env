BASE_PROJ ?= $(shell pwd)
LINUX ?= ${BASE_PROJ}/linux
USER_ID ?= "$(shell id -u):$(shell id -g)"
SSH_PORT ?= "52227"
.ALWAYS:

all: vmlinux fs samples

docker: .ALWAYS
	make -C docker/docker-linux-builder docker

qemu-run: 
	docker run --privileged --rm \
	--device=/dev/kvm:/dev/kvm --device=/dev/net/tun:/dev/net/tun \
	-v ${BASE_PROJ}:/linux-dev-env -v ${LINUX}:/linux \
	-w /linux \
	-p 127.0.0.1:${SSH_PORT}:52222 \
	-it runtime:latest \
	/linux-dev-env/q-script/yifei-q -s

# mapping the gdb port 1234 from docker container 
qemu-run-gdb: 
	docker run --privileged --rm \
	--device=/dev/kvm:/dev/kvm --device=/dev/net/tun:/dev/net/tun \
	-v ${BASE_PROJ}:/linux-dev-env -v ${LINUX}:/linux \
	-w /linux \
	-p 127.0.0.1:${SSH_PORT}:52222 \
	-p 127.0.0.1:1234:1234 \
	-it runtime:latest \
	/linux-dev-env/q-script/yifei-q -s

# connect running qemu by ssh
qemu-ssh:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -t root@127.0.0.1 -p ${SSH_PORT}

vmlinux: 
	docker run --rm -u ${USER_ID} -v ${LINUX}:/linux -w /linux runtime  make -j`nproc` bzImage 

headers-install: 
	docker run --rm -u ${USER_ID} -v ${LINUX}:/linux -w /linux runtime  make -j`nproc` headers_install 

modules-install: 
	docker run --rm -u ${USER_ID} -v ${LINUX}:/linux -w /linux runtime  make -j`nproc` modules
	sudo docker run --rm -u ${USER_ID} -v ${LINUX}:/linux -w /linux runtime  make -j`nproc` modules_install

kernel:
	docker run --rm -u ${USER_ID} -v ${LINUX}:/linux -w /linux runtime  make -j`nproc` 

linux-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux runtime make distclean

enter-docker:
	docker run --rm -u ${USER_ID} -v ${BASE_PROJ}:/linux-dev-env -w /linux-dev-env -it runtime /bin/bash

