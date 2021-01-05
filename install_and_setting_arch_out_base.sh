#!/bin/bash
ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

read -p "Ether the host name: " HOSTNAME
read -p "Enter user name: " USERNAME

echo $HOSTNAME > /etc/hostname

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
