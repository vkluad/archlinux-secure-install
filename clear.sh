#!/bin/bash
pacman -Scc
yay -Scc
userdel -r installer
rm -rf /root/Arch_linux_install
