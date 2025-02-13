savedcmd_/linux-dev-env/bpf-progs/ko/reg_kfunc.mod := printf '%s\n'   reg_kfunc.o | awk '!x[$$0]++ { print("/linux-dev-env/bpf-progs/ko/"$$0) }' > /linux-dev-env/bpf-progs/ko/reg_kfunc.mod
