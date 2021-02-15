#!/bin/bash
ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
chsh -s /bin/zsh
read -p "Enter user name: " USERNAME

echo "Create Pu4taz hostname and user name!!!"
echo "Pu4taz" > /etc/hostname
echo "Add user $USERNAME"
useradd -m -g users -G wheel -s /bin/zsh $USERNAME
sed -i 's/.*# %wheel ALL=(ALL) ALL.*/%wheel ALL=(ALL) ALL/' /etc/sudoers

echo "Password for user $USERNAME"
passwd $USERNAME
echo "Password for root user"
sleep 2;
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
systemctl enable NetworkManager
