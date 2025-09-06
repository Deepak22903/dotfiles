#!/bin/bash

# This script provides a commented guide for the initial steps of an Arch Linux installation.
# It is intended for manual execution, as it involves disk partitioning and formatting.

# 1. Synchronize package databases.
# This refreshes the local package database with the latest from the repositories.
pacman -Sy

# 2. Ensure the Arch Linux keyring is up to date.
# This prevents package signature verification errors.
pacman -S archlinux-keyring

# 3. Install the 'archinstall' guided installer.
# This script provides a user-friendly, menu-driven installation process.
pacman -S archinstall

# --- MANUAL STEPS FOR DISK PREPARATION ---
# The following commands are commented out as they are examples.
# You must replace the placeholder device names (e.g., /dev/sdX) with your actual device names.

# 4. Partition the target disk using a tool like cfdisk.
# Example:
# cfdisk /dev/sdX

# You should create at least two partitions:
#   a) An EFI System Partition (at least 512M, 1G is safe), type "EFI System".
#   b) A root partition for the Linux filesystem, type "Linux filesystem", using the remaining space.

# 5. Format the newly created partitions.
# Format the EFI partition as FAT32.
# Example:
# mkfs.fat -F32 /dev/sdX1

# Format the root partition as ext4.
# Example:
# mkfs.ext4 /dev/sdX2

# 6. Mount the filesystems.
# Mount the root partition to /mnt.
# Example:
# mount /dev/sdX2 /mnt

# Create a boot directory on the new root.
# mkdir /mnt/boot

# Mount the EFI partition to /mnt/boot.
# Example:
# mount /dev/sdX1 /mnt/boot

# 7. Launch the guided installer.
# With the partitions mounted, you can now run archinstall to complete the setup.
# archinstall