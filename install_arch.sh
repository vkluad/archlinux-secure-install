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
NAME_HDD="sda"
BOOT_SIZE="300M"
SWAP_SIZE="8G"
ROOT_SIZE="75G"
HOME_SIZE="30G"
GAME_SIZE="350G"
DATA_SIZE=""



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
echo "swap $SWAP_SIZE on HDD"
echo "/ $ROOT_SIZE(f2fs)"
echo "/home all other - $HOME_SIZE(f2fs)"
echo "/data/Games/ $GAME_SIZE (XFS)"
echo "/data/data/ other size(XFS)"
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
    echo +$ROOT_SIZE;
    echo 8304;

    echo n;
    echo;
    echo;
    echo -$HOME_SIZE;
    echo 8302;

    echo w;
    echo y;
) | gdisk /dev/$NAME_SSD

echo "Create Partition on $NAME_HDD"
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
    echo +$SWAP_SIZE;
    echo 8200;

    # echo n;
    # echo;
    # echo;
    # echo +$GAME_SIZE;
    # echo 8300;

    echo n;
    echo;
    echo;
    echo;
    echo 8300;

    echo w;
    echo y;
) | gdisk /dev/$NAME_HDD



echo "Format disk and mount on /mnt"
mkfs.vfat -S 4096 /dev/$NAME_SSD$P\1
mkswap /dev/$NAME_HDD\1
swapon /dev/$NAME_HDD\1
mkfs.f2fs /dev/$NAME_SSD\p2
mkfs.f2fs /dev/$NAME_SSD\p3
# mkfs.xfs -f -L "GAMES" -b 4096 /dev/$NAME_HDD\2
mkfs.xfs -f -L "DATA" -b 4096 /dev/$NAME_HDD\2

mount /dev/$NAME_SSD\p2 /mnt
mkdir /mnt/home
mkdir /mnt/boot
mkdir /mnt/data/data
mkdir /mnt/data/Games

mount /dev/$NAME_SSD\p1 /mnt/boot
mount /dev/$NAME_SSD\p3 /mnt/home
# mount /dev/$NAME_HDD\2 /mnt/data/Games
mount /dev/$NAME_HDD\2 /mnt/data/data

sleep 3;

echo "Refresh mirror list"
reflector --verbose --country 'Ukraine' --sort rate --save /etc/pacman.d/mirrorlist
sleep 2;

echo "Install base package"
pacstrap /mnt base base-devel linux linux-firmware nano netctl dhcpcd intel-ucode zsh reflector f2fs-tools
sleep 2;

echo "Copying mirrorlist"
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
sleep 2;

echo "Setting system"
genfstab -U /mnt >> /mnt/etc/fstab
echo "Chroot enter"
arch-chroot /mnt bash -c "$(curl -fsSL https://raw.githubusercontent.com/vkluad/Arch_linux_install/main/install_and_setting_arch_out_base.sh)" $NAME_SSD
