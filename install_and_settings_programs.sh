#!/bin/bash
NAME_SSD="nvme0n1"
ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
chsh -s /bin/zsh
chmod 777 ~/Arch_linux_install/*.*
read -p "Enter user name: " USERNAME

echo "Create Pu4taz hostname and user name!!!"
echo "Pu4taz" > /etc/hostname
echo "Add user $USERNAME"
useradd -m -g users -G wheel -s /bin/zsh $USERNAME
sed -i 's/.*# %wheel ALL=(ALL) ALL.*/%wheel ALL=(ALL) ALL/' /etc/sudoers

echo "Password for user $USERNAME"
passwd $USERNAME

echo "Password for root user"
passwd

echo 'Added locale in locale.gen'
sleep 2;
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "uk_UA.UTF-8 UTF-8" >> /etc/locale.gen

echo 'Update locale in system now'
locale-gen

echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo
echo "127.0.0.1  localhost
127.0.1.1  Arch.localdomain.my Arch
::1        localhost ip6-localhost ip6-loopback
ff02::1    ip6-allnodes
ff02::2    ip6-allrouters" >> /etc/hosts

echo 'Recommented library for 32-bit apps'
cp -r ./configuration/pacman.conf /etc/pacman.conf
pacman -Syy
echo "Install bootloader"
bootctl --path=/boot install

echo "default\tArch
timeout\t0" > /boot/loader/loader.conf

PARTUUID="$(blkid /dev/$NAME_SSD\p2 | sed -n '/.*PARTUUID="/s///;s/"//p')"
echo "title\tArch Linux
linux\t/vmlinuz-linux
initrd\t/intel-ucode.img
initrd\t/initramfs-linux.img
options\troot=PARTUUID=$PARTUUID rw rootflags=subvol=@" > /boot/loader/entries/Arch.conf

pacman -Suy dialog wpa_supplicant gnome nvidia nvidia-prime nvidia-settings wget git atom gimp \
firefox blender cuda libreoffice-still discord telegram-desktop vulkan-devel nvidia-cg-toolkit \
lib32-nvidia-cg-toolkit chromium tor ghex handbrake htop jdk11-openjdk jre-openjdk \
jre-openjdk-headless jre11-openjdk jre11-openjdk-headless shotcut efibootmgr embree \
exfat-utils gstreamer-vaapi iotop screen neofetch zerotier-one ncdu ntfs-3g rsync \
chrome-gnome-shell torbrowser-launcher qbittorrent obs-studio

useradd -m -g users -G wheel -s /bin/zsh installer
echo "1111" | passwd installer
echo "###############################################"
echo "###############################################\n"
echo "Please run 'bash aur_install.sh'\n"
echo "###############################################"
echo "###############################################"

su installer
