savedcmd_reg_kfunc.mod := printf '%s\n'   reg_kfunc.o | awk '!x[$$0]++ { print("./"$$0) }' > reg_kfunc.mod
