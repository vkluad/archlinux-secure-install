#!/bin/bash

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
echo "password for temp user is : 1111"
sleep 2;
makepkg -si
yay -S wd719x-firmware upd72020x-fw aic94xx-firmware
yay -S optimus-manager gdm-prime libgdm-prime eclipse-cpp zoom teams skypeforlinux-stable-bin youtube-music-appimage
systemctl enable gdm-prime

wget -O /etc/oprimus-manager/optimus-manager.conf https://raw.githubusercontent.com/vkluad/Arch_linux_install/main/optimus-manager.conf
echo "Please run 'Bash /root/Arch_linux_install/clear.sh'"
exit
