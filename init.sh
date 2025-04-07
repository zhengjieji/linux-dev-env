#!/bin/bash
set -e  # Exit immediately if a command fails

# 1. Execute Docker build
echo "Executing: sudo make docker"
sudo make docker

# 2. Download Linux source code
echo "Cloning Linux repository..."
git clone https://github.com/torvalds/linux.git

# Enter the linux directory
cd linux

# 3. Checkout to the specific tag
echo "Switching to tag v6.13..."
git checkout v6.13

# 4. Copy the configuration file to the current directory
# Note: This assumes that the linux-config-6.13 directory is located in the parent directory of the cloned repository
echo "Copying configuration file..."
cp ../linux-config-6.13/.config .

# 5. Build dependencies
cd ..
echo "Installing headers..."
sudo make headers-install

echo "Installing modules..."
sudo make modules-install

# 6. Build Linux
echo "Building vmlinux..."
sudo make vmlinux

# 7. Build tools
echo "Building libbpf..."
sudo make libbpf

echo "Building bpftool..."
sudo make bpftool

echo "All steps completed successfully!"
