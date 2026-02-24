#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
ROOT_DIR_ABS="$(cd -- "${ROOT_DIR}" && pwd)"

RUNTIME_IMAGE="${RUNTIME_IMAGE:-zhengjie-dual-vm}"
KATRAN_SRC_DIR="${EXP1_KATRAN_SRC_DIR:-${ROOT_DIR}/source/katran}"
KATRAN_BUILD_DIR="${EXP1_KATRAN_BUILD_DIR:-${KATRAN_SRC_DIR}/_build}"
FORCE_REBUILD="${EXP1_KATRAN_FORCE_REBUILD:-0}"
INSTALL_BUILD_DEPS="${EXP1_KATRAN_INSTALL_BUILD_DEPS:-1}"
ENABLE_THRIFT="${EXP1_KATRAN_ENABLE_THRIFT:-0}"
ENABLE_TOOLS="${EXP1_KATRAN_ENABLE_TOOLS:-0}"
ENABLE_KATRAN_TPR="${EXP1_KATRAN_ENABLE_KATRAN_TPR:-0}"
USE_OFFICIAL_GRPC_CLIENT="${EXP1_KATRAN_USE_OFFICIAL_GRPC_CLIENT:-1}"
STRICT_OFFICIAL_GRPC_CLIENT="${EXP1_KATRAN_STRICT_OFFICIAL_GRPC_CLIENT:-0}"
OFFICIAL_GRPC_GOFLAGS="${EXP1_KATRAN_OFFICIAL_GRPC_GOFLAGS:--buildvcs=false}"
KATRAN_BPF_DEFINES="${EXP1_KATRAN_BPF_DEFINES:--DLOCAL_DELIVERY_OPTIMIZATION}"

SERVER_BIN_HOST="${KATRAN_BUILD_DIR}/build/example_grpc/katran_server_grpc"
BPF_OBJ_HOST="${KATRAN_BUILD_DIR}/deps/bpfprog/bpf/balancer.bpf.o"
GOCLIENT_BIN_HOST="${KATRAN_SRC_DIR}/example_grpc/goclient/src/katranc/main/main"
BPF_DEFINES_MARKER_HOST="${KATRAN_BUILD_DIR}/.exp1_bpf_defines"

log() {
	echo "[exp1-katran-build] $*"
}

fail() {
	echo "[exp1-katran-build][error] $*" >&2
	exit 1
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

host_to_container_path() {
	local host_path="$1"
	local host_abs
	host_abs="$(realpath -m "${host_path}")"
	case "${host_abs}" in
		"${ROOT_DIR_ABS}"/*)
			echo "/linux-dev-env${host_abs#${ROOT_DIR_ABS}}"
			;;
		*)
			fail "path must be under repo root '${ROOT_DIR_ABS}', got: ${host_abs}"
			;;
	esac
}

is_bool_01() {
	case "$1" in
		0|1) return 0 ;;
		*) return 1 ;;
	esac
}

check_outputs() {
	[ -x "${SERVER_BIN_HOST}" ] || fail "missing Katran server binary: ${SERVER_BIN_HOST}"
	[ -f "${BPF_OBJ_HOST}" ] || fail "missing Katran BPF object: ${BPF_OBJ_HOST}"
	[ -x "${GOCLIENT_BIN_HOST}" ] || fail "missing Katran gRPC client binary: ${GOCLIENT_BIN_HOST}"
}

main() {
	require_cmd docker
	require_cmd realpath
	is_bool_01 "${FORCE_REBUILD}" || fail "EXP1_KATRAN_FORCE_REBUILD must be 0 or 1"
	is_bool_01 "${INSTALL_BUILD_DEPS}" || fail "EXP1_KATRAN_INSTALL_BUILD_DEPS must be 0 or 1"
	is_bool_01 "${ENABLE_THRIFT}" || fail "EXP1_KATRAN_ENABLE_THRIFT must be 0 or 1"
	is_bool_01 "${ENABLE_TOOLS}" || fail "EXP1_KATRAN_ENABLE_TOOLS must be 0 or 1"
	is_bool_01 "${ENABLE_KATRAN_TPR}" || fail "EXP1_KATRAN_ENABLE_KATRAN_TPR must be 0 or 1"
	is_bool_01 "${USE_OFFICIAL_GRPC_CLIENT}" || fail "EXP1_KATRAN_USE_OFFICIAL_GRPC_CLIENT must be 0 or 1"
	is_bool_01 "${STRICT_OFFICIAL_GRPC_CLIENT}" || fail "EXP1_KATRAN_STRICT_OFFICIAL_GRPC_CLIENT must be 0 or 1"

	local katran_src_host
	local katran_build_host
	local katran_src_container
	local katran_build_container
	katran_src_host="$(realpath -m "${KATRAN_SRC_DIR}")"
	katran_build_host="$(realpath -m "${KATRAN_BUILD_DIR}")"

	[ -d "${katran_src_host}" ] || fail "Katran source directory not found: ${katran_src_host}"
	[ -f "${katran_src_host}/build_katran.sh" ] || fail "build_katran.sh not found in ${katran_src_host}"
	katran_src_container="$(host_to_container_path "${katran_src_host}")"
	katran_build_container="$(host_to_container_path "${katran_build_host}")"

	SERVER_BIN_HOST="${katran_build_host}/build/example_grpc/katran_server_grpc"
	BPF_OBJ_HOST="${katran_build_host}/deps/bpfprog/bpf/balancer.bpf.o"
	GOCLIENT_BIN_HOST="${katran_src_host}/example_grpc/goclient/src/katranc/main/main"
	BPF_DEFINES_MARKER_HOST="${katran_build_host}/.exp1_bpf_defines"

	local image_ref=""
	if docker image inspect "${RUNTIME_IMAGE}:latest" >/dev/null 2>&1; then
		image_ref="${RUNTIME_IMAGE}:latest"
	elif docker image inspect "${RUNTIME_IMAGE}" >/dev/null 2>&1; then
		image_ref="${RUNTIME_IMAGE}"
	else
		fail "Docker image '${RUNTIME_IMAGE}' not found. Run: make docker"
	fi

	if [ "${FORCE_REBUILD}" -eq 1 ]; then
		log "force rebuild requested; removing ${katran_build_host}"
		rm -rf "${katran_build_host}"
		rm -f "${GOCLIENT_BIN_HOST}"
	fi

	log "building Katran artifacts inside Docker image ${image_ref}"
	docker run --rm --network host \
		-v "${ROOT_DIR}:/linux-dev-env" \
		-w "${katran_src_container}" \
		"${image_ref}" \
		bash -lc "
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

if ! command -v sudo >/dev/null 2>&1; then
	mkdir -p /tmp/exp1-katran-tools
	cat >/tmp/exp1-katran-tools/sudo <<'EOF_SUDO'
#!/usr/bin/env bash
exec \"\$@\"
EOF_SUDO
	chmod +x /tmp/exp1-katran-tools/sudo
	export PATH=\"/tmp/exp1-katran-tools:\${PATH}\"
fi

if [ \"${INSTALL_BUILD_DEPS}\" -eq 1 ]; then
	apt-get update
	apt-get install -y \
		libgoogle-glog-dev \
		libgflags-dev \
		libelf-dev \
		libmnl-dev \
		liblzma-dev \
		libre2-dev \
		liblz4-dev \
		libsodium-dev \
		libfmt-dev \
		libboost-all-dev \
		libevent-dev \
		libdouble-conversion-dev \
		libsnappy-dev \
		zlib1g-dev \
		binutils-dev \
		libjemalloc-dev \
		pkg-config \
		libiberty-dev \
		libunwind8-dev \
		libdwarf-dev \
		libprotobuf-dev \
		protobuf-compiler \
		protobuf-compiler-grpc \
		libgrpc++-dev \
		golang-go
fi

# Build Katran using upstream official flow (build + tests + bpf modules).
unset BUILD_EXAMPLE_GRPC || true
export CMAKE_BUILD_EXAMPLE_GRPC=1
if [ \"${ENABLE_THRIFT}\" -eq 1 ]; then
	export BUILD_EXAMPLE_THRIFT=1
fi
if [ \"${ENABLE_TOOLS}\" -eq 1 ]; then
	export BUILD_TOOLS=1
fi
if [ \"${ENABLE_KATRAN_TPR}\" -eq 1 ]; then
	export BUILD_KATRAN_TPR=1
fi
mkdir -p \"${katran_build_container}\"
	./build_katran.sh \
		-p \"${katran_build_container}\" \
		-i \"${katran_build_container}/deps\"

	# Rebuild BPF objects with Exp1-specific compile-time defines.
	if [ -n \"${KATRAN_BPF_DEFINES}\" ]; then
		./build_bpf_modules_opensource.sh \
			-s \"${katran_src_container}\" \
			-b \"${katran_build_container}\" \
			-d \"${KATRAN_BPF_DEFINES}\"
	fi
	: >\"${katran_build_container}/.exp1_bpf_defines\"
	for define_token in ${KATRAN_BPF_DEFINES}; do
		case \"\${define_token}\" in
			-D*) define_token=\"\${define_token#-D}\" ;;
		esac
		[ -n \"\${define_token}\" ] && printf '%s\n' \"\${define_token}\" >>\"${katran_build_container}/.exp1_bpf_defines\"
	done

cd \"${katran_src_container}/example_grpc\"
export GOPATH=\"\$(pwd)/goclient\"
export PATH=\"\${PATH}:\${GOPATH}/bin\"
grpc_client_built=0
if [ \"${USE_OFFICIAL_GRPC_CLIENT}\" -eq 1 ]; then
	if [ -n \"${OFFICIAL_GRPC_GOFLAGS}\" ]; then
		export GOFLAGS=\"${OFFICIAL_GRPC_GOFLAGS}\"
	fi
	set +e
	./build_grpc_client.sh
	official_rc=\$?
	set -e
	if [ \"\${official_rc}\" -eq 0 ]; then
		grpc_client_built=1
	else
		echo \"[exp1-katran-build][warn] official build_grpc_client.sh failed (\${official_rc}); fallback to modern go module mode\"
		if [ \"${STRICT_OFFICIAL_GRPC_CLIENT}\" -eq 1 ]; then
			exit \"\${official_rc}\"
		fi
	fi
fi

if [ \"\${grpc_client_built}\" -ne 1 ]; then
	if [ ! -x \"\${GOPATH}/bin/protoc-gen-go\" ]; then
		go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	fi
	if [ ! -x \"\${GOPATH}/bin/protoc-gen-go-grpc\" ]; then
		go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	fi
	if [ -x \"\${GOPATH}/bin/protoc-gen-go-grpc\" ] && [ ! -x \"\${GOPATH}/bin/protoc-gen-go_grpc\" ]; then
		cp \"\${GOPATH}/bin/protoc-gen-go-grpc\" \"\${GOPATH}/bin/protoc-gen-go_grpc\"
	fi

	# Build gRPC Go client in module mode (compatible with modern Go toolchain).
	rm -rf goclient/src/katranc/lb_katran
	mkdir -p goclient/src/katranc/lb_katran
	protoc -I protos katran.proto \
		--go_out=goclient/src/katranc/lb_katran \
		--go_grpc_out=goclient/src/katranc/lb_katran

	pushd goclient/src/katranc
	if [ ! -f go.mod ]; then
		go mod init katranc
	fi
	GO111MODULE=on go mod tidy
	popd

	pushd goclient/src/katranc/main
	GO111MODULE=on go build -buildvcs=false
	popd
fi
"

	check_outputs
	log "build complete"
	log "katran_server_grpc: ${SERVER_BIN_HOST}"
	log "balancer.bpf.o: ${BPF_OBJ_HOST}"
	log "katran gRPC client: ${GOCLIENT_BIN_HOST}"
	log "katran bpf defines marker: ${BPF_DEFINES_MARKER_HOST}"
}

main "$@"
