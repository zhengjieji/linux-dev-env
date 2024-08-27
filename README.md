***This repository is cloned and modified from rosalab/(unknown)-kernel***

#### Build Docker Container

``` make docker ```

#### Copy config file to linux folder

``` cp linux-config/.config ./linux ```

or 

```
cd linux
make defconfig
cd ../
```

#### Build linux

```
make vmlinux
```

#### Run Qemu
```
make qemu-run
```

#### If you want to ssh into the qemu
```
make qemu-ssh
```

#### If you want to enter the docker container where qemu is running
```
make enter-docker
```

#### If you want to debug the kernel using gdb
```
make qemu-run-gdb
```
In an another terminal
```
cd linux
gdb vmlinux
targer remote:1234
c
```
then set your breakpoints and debug more


