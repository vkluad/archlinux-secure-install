#!/bin/bash
# This script created specially for gpt disk and ssd

if  ! ping -c1 8.8.8.8 >/dev/null;
then
  echo "Your internet connection fails!!!"
  echo "Please connect to internet."
  exit
else
  echo "Internet connection done."
fi

timedatectl set-ntp true
echo
echo "Your time status:"
timedatectl status
sleep 2

fdisk -l | grep "Disk /"
START_SEC=40
NAME_SSD="nvme0n1"
# NAME_HDD="sda"
BOOT_SIZE="300M"
# SWAP_SIZE="8G"
# ROOT_SIZE="75G"
HOME_SIZE="30G"
# DATA_SIZE=""



echo "#####################################################"
echo "Will be created root partition on /dev/$NAME_SSD"
echo
echo "Will be created data patition on /dev/$NAME_HDD"
echo
echo "Start sector for gpt ssd is 40"
echo
echo "#####################################################"

echo "#####################################################"
echo "/boot (esp) $BOOT_SIZE"
# echo "swap $SWAP_SIZE on HDD"
echo "/ btrfs subvolume created (@root,@home,@.snapshots)"
echo "#####################################################"

sleep 2;


echo "Create partiotion on $NAME_SSD"
sleep 2;

(
    echo o;
    echo y;

    echo x;
    echo l;
    echo $START_SEC;
    echo m;

    echo n;
    echo;
    echo;
    echo +$BOOT_SIZE;
    echo ef00;

    echo n;
    echo;
    echo;
    echo -$HOME_SIZE;
    echo 8300;

    echo w;
    echo y;
) | gdisk /dev/$NAME_SSD

# echo "Create HDD partition and reserv copy system?(y/N)"
# read chsy;
# if [ $chsy = 'y' ]
# then
# (
#     echo o;
#     echo y;
#
#     echo x;
#     echo l;
#     echo $START_SEC;
#     echo m;
#
#     echo n;
#     echo;
#     echo;
#     echo +$BOOT_SIZE;
#     echo ef00;
#
#     echo n;
#     echo;
#     echo;
#     echo;
#     echo 8300;
#
#     echo w;
#     echo y;
# ) | gdisk /dev/$NAME_HDD
#


echo "Format disk and mount on /mnt"
mkfs.vfat -S 4096 /dev/$NAME_SSD$P\1

mkfs.btrfs /dev/$NAME_SSD\p2
mount /dev/$NAME_SSD\p2 /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@.snapshots
umount /dev/$NAME_SSD\p2
mount -o noatime,compress=lzo,space_cache,subvol=@root /dev/$NAME_SSD /mnt/
mkdir /mnt/{boot,home,.snapshots,data}
mount -o noatime,compress=lzo,space_cache,subvol=@home /dev/$NAME_SSD /mnt/home
mount -o noatime,compress=lzo,space_cache,subvol=@.snapshots /dev/$NAME_SSD /mnt/.snapshots



mount /dev/$NAME_SSD\p1 /mnt/boot
mount /dev/$NAME_SSD\p3 /mnt/home
# mount /dev/$NAME_HDD\2 /mnt/data/Games
mount /dev/$NAME_HDD\2 /mnt/data

sleep 3;

echo "Refresh mirror list"
reflector --verbose --country 'Ukraine' --sort rate --save /etc/pacman.d/mirrorlist
sleep 2;

echo "Install base package"
pacstrap /mnt base base-devel linux linux-firmware nano netctl dhcpcd intel-ucode zsh reflector f2fs-tools xfsprogs
sleep 2;

echo "Copying mirrorlist"
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
sleep 2;

echo "Setting system"
genfstab -U /mnt >> /mnt/etc/fstab
echo "Chroot enter"
arch-chroot /mnt bash -c "$(curl -fsSL https://raw.githubusercontent.com/vkluad/Arch_linux_install/main/install_and_setting_arch_out_base.sh)" $NAME_SSD
