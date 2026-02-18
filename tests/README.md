# Tests

`tests/` contains Linux VM development environment tests.

## Run

```sh
# full non-destructive test pass
./tests/run.sh

# VM pipeline tests only
./tests/vm-linux-dev/run.sh

# tool tests (kept with the tool)
./tools/kernel-track/tests/run.sh
```

Optional live VM integration:

```sh
./tests/vm-linux-dev/run-live.sh --docker-build --kernel-build --qemu-boot

# dual-vm live integration (host<->vm ssh, vm<->vm ping, xdp smoke)
./tests/vm-linux-dev/dual-vm-live.sh

# same via unified live runner
./tests/vm-linux-dev/run-live.sh --dual-vm
```
