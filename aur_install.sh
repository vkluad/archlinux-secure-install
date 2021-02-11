#!/bin/bash

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
echo "password for temp user is : 1111"
sleep 2;
makepkg -si
yay -S wd719x-firmware aic94xx-firmware upd72020x-fw
yay -S optimus-manager gdm-prime libgdm-prime zoom teams skypeforlinux-stable-bin youtube-music-appimage\
clion clion-jre clion-cmake clion-gdb clion-lldb

systemctl enable gdm
systemctl enable NetworkManager

cp -r ./configuration/optimus-manager.conf /etc/optimus-manager/optimus-manager.conf
echo "Please run 'Bash /root/Arch_linux_install/clear.sh'"
exit
