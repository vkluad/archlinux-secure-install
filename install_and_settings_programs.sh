#!/bin/bash
NAME_SSD="nvme0n1"
ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

read -p "Ether the host name: " HOSTNAME
read -p "Enter user name: " USERNAME

echo $HOSTNAME > /etc/hostname
echo "Add user $USERNAME"
useradd -m -g users -G wheel -s /bin/zsh $USERNAME
sed -i 's/.*# %wheel ALL=(ALL) ALL.*/%wheel ALL=(ALL) ALL/' /etc/sudoers

echo "Password for user $USERNAME"
passwd $USERNAME

echo "Password for root user"
passwd

echo 'Added locale in locale.gen'
sleep 1;
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
# sed -i 's/.*#\[multilib\]\n#Include = /etc/pacman.d/mirrorlist.*/\[multilib\]\nInclude = /etc/pacman.d/mirrorlist/' /etc/pacman.conf
echo "[multilib]" >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy
echo "Install bootloader"
bootctl --path=/boot install

echo "default Arch
timeout 1" > /boot/loader/loader.conf

PARTUUID="$(blkid /dev/$NAME_SSD\p2 | sed -n '/.*PARTUUID="/s///;s/"//p')"
echo "title\tArch Linux
linux\t/vmlinuz-linux
initrd\t/intel-ucode.img
initrd\t/initramfs-linux.img
options\troot=PARTUUID=$PARTUUID rw rootflags=subvol=@root" > /boot/loader/entries/Arch.conf

pacman -Suy dialog wpa_supplicant gnome nvidia nvidia-prime nvidia-settings wget git atom gimp firefox blender cuda libreoffice-still discord telegram-desktop vulkan-devel nvidia-cg-toolkit lib32-nvidia-cg-toolkit chromium tor ghex handbrake htop jdk11-openjdk jre-openjdk jre-openjdk-headless jre11-openjdk jre11-openjdk-headless shotcut efibootmgr embree exfat-utils gstreamer-vaapi iotop screen neofetch zerotier-one ncdu ntfs-3g

useradd -m -g users -G wheel -s /bin/zsh temp
echo "1111" | passwd temp
echo "Please run 'bash aur_install.sh'"
cd 
su temp
