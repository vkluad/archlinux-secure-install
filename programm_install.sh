#!/bin/bash
sudo pacman -Suy dialog wpa_supplicant gnome nvidia nvidia-prime nvidia-settings wget git atom gimp \
firefox blender cuda libreoffice-still discord telegram-desktop vulkan-devel nvidia-cg-toolkit \
lib32-nvidia-cg-toolkit chromium tor ghex handbrake htop jdk11-openjdk jre-openjdk \
jre-openjdk-headless jre11-openjdk jre11-openjdk-headless shotcut efibootmgr embree \
exfat-utils gstreamer-vaapi iotop screen neofetch zerotier-one ncdu ntfs-3g rsync \
chrome-gnome-shell torbrowser-launcher qbittorrent obs-studio clevis tpm2-tools \
tpm2-tss tpm2-totp tpm2-abrmd


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
systemctl enable fstrim.timer

cp -r ./configuration/optimus-manager.conf /etc/optimus-manager/optimus-manager.conf
