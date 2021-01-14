#!/bin/bash
pacman -Scc
yay -Scc
userdel -r temp
rm -rf /root/Arch_linux_install
