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
```
