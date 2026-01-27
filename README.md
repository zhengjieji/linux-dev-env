# Linux 内核开发环境

用于构建和修改 Linux 内核的开发环境。包含：
- Docker 容器：包含所有编译依赖和 QEMU
- QEMU 脚本：启动运行自定义内核的虚拟机
- 双 VM 环境：两个可互相通信的虚拟机，用于网络测试

## 快速开始

### 1. 构建 Docker 容器

```bash
make docker
```

> 确保已安装 pahole：`sudo apt-get install dwarves`

### 2. 下载 Linux 内核

```bash
git clone https://github.com/torvalds/linux.git
cd linux
git checkout v6.13
```

### 3. 复制配置文件

```bash
cp linux-configs/linux-config-6.13/.config ./linux
```

### 4. 编译

```bash
make headers-install
make modules-install
make vmlinux
make libbpf
make bpftool
```

### 5. 启动虚拟机

```bash
make qemu-run
```

## 常用命令

| 命令 | 说明 |
|------|------|
| `make qemu-run` | 启动单个虚拟机 |
| `make qemu-ssh` | SSH 连接到虚拟机 |
| `make enter-docker` | 进入 Docker 容器 |
| `make dual-vm1` | 启动双 VM 的 VM1 |
| `make dual-vm2` | 启动双 VM 的 VM2 |

## GDB 调试

在另一个终端：
```bash
cd linux
gdb vmlinux
target remote:1234
c
```

## 双虚拟机环境

用于 Katran、XDP、多主机 BPF 测试等网络实验场景。

### 架构

```
+------------------+                    +------------------+
|       VM1        |                    |       VM2        |
|    192.168.100.1 |<==== multicast ===>|    192.168.100.2 |
|    SSH: 52222    |                    |    SSH: 52232    |
+------------------+                    +------------------+
```

两个 VM 通过 UDP multicast 网络通信，可以独立启动。

### 启动

```bash
# 终端 1
make dual-vm1

# 终端 2
make dual-vm2
```

### 测试连通性

```bash
# VM1 上
ping 192.168.100.2

# VM2 上
ping 192.168.100.1

# TCP 测试
# VM1: nc -l -p 8080
# VM2: nc 192.168.100.1 8080
```

### SSH 连接

```bash
make dual-vm1-ssh   # 连接 VM1
make dual-vm2-ssh   # 连接 VM2
```

### 端口配置

| 服务 | VM1 | VM2 |
|------|-----|-----|
| SSH | 52222 | 52232 |
| GDB | 1234 | 1244 |

自定义端口：
```bash
make dual-vm1 SOCKET_PORT=54321 VM1_SSH_PORT=55222
make dual-vm2 SOCKET_PORT=54321 VM2_SSH_PORT=55232
```

## 添加端口映射

默认主机端口 52223 连接到 QEMU 虚拟机的 52223 端口。如需添加更多端口：

### Makefile 修改

添加主机到 Docker 的端口映射：
```
-p 127.0.0.1:HOST_PORT:DOCKER_PORT
```

### q-script 修改

在 `q-script/yifei-q` 中找到 `net += -netdev user...` 行，末尾添加：
```
hostfwd=tcp::DOCKER_PORT-:QEMU_PORT
```

## 关闭虚拟机

```bash
# VM 内
exit

# 或从主机强制关闭
docker ps
docker stop <container_id>
```
