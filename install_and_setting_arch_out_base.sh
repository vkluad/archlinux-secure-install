#!/bin/bash
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
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "uk_UA.UTF-8 UTF-8" >> /etc/locale.gen

echo 'Update locale in system now'
locale-gen

echo 'LANG="en_US.UTF-8"' > /etc/locale.conf

echo
echo "127.0.0.1  localhost
127.0.1.1  Arch.localdomain.my Arch
::1        localhost ip6-localhost ip6-loopback
ff02::1    ip6-allnodes
ff02::2    ip6-allrouters" >> /etc/hosts

echo 'Recommented library for 32-bit apps'
# sed -i 's/.*#\[multilib\]\n#Include = /etc/pacman.d/mirrorlist.*/\[multilib\]\nInclude = /etc/pacman.d/mirrorlist/' /etc/pacman.conf
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy
echo "Install bootloader"
bootctl --path=/boot install

echo "default Arch" > /boot/loader/loader.conf

PARTUUID="$(blkid /dev/$0\$1\2 | sed -n '/.*PARTUUID="/s///;s/"//p')"
echo "title\tArch Linux
linux\t/vmlinuz-linux
initrd\t/intel-ucode.img
initrd\t/initramfs-linux.img
options\troot=PARTUUID=$PARTUUID" > /boot/loader/entries/Arch.conf


pacman -Suy dialog wpa_supplicant gnome nvidia nvidia-prime nvidia-settings wget git atom gimp firefox blender
pacman -S cuda libreoffice discord telegram-desktop vulkan-devel nvidia-cg-toolkit lib32-nvidia-cg-toolkit chromium
pacman -S tor ghex handbrake htop jdk11-openjdk jre-openjdk jre-openjdk-headless jre11-openjdk jre11-openjdk-headless
pacman -S shotcut efibootmgr embree exfat-utils gstreamer-vaapi iotop qemu screen neofetch boxes zerotier-one
pacman -S zsh-syntax-highlighting

useradd -m -g users -G wheel -s /bin/zsh temp
echo "1111" | passwd temp
su temp
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
echo "password for temp user is : 1111"
sleep 2;
makepkg -si
yay -Sy optimus-manager gdm-prime libgdm-prime eclipse-cpp zoom teams skypeforlinux-stable-bin youtube-music-appimage
systemctl enable gdm-prime
cd /tmp

wget https://raw.githubusercontent.com/vkluad/Arch_linux_install/main/optimus-manager.conf
cp optimus-manager.conf /etc/optimus-manager/optimus-manager.conf
exit
userdel -r temp
exit
