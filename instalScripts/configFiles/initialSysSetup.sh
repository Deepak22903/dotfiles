#!/bin/bash

pacman -Sy
pacman -S archlinux-keyring
pacman -S archinstall
# after this use command cfdisk /dev/<name of free space device>
# create two partitions 1 for efi (1GB and type efi system) and 2 for / (type linux file system)
# now format the partitions
# mkfs.fat -F32 /dev/<efi device>
# mkfs.ext4 /dev/<root partition device>
# now mount the partitions
# mount /dev/<root partition> /mnt
# mkdir /mnt/boot
# mount /dev/<efi partition> /mnt/boot
# then type archinstall
