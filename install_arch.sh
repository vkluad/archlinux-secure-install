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
# NAME_HDD="sda"
BOOT_SIZE="300M"
# SWAP_SIZE="8G"
# ROOT_SIZE="75G"
HOME_SIZE="10G"
# DATA_SIZE=""



echo "#####################################################"
echo "Will be created root partition on /dev/nvme0n1"
echo
echo "Will be created data patition on /dev/sda"
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


echo "Create partiotion on nvme0n1"
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
) | gdisk /dev/nvme0n1


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
    echo;
    echo 8300;

    echo w;
    echo y;
) | gdisk /dev/sda


echo "Format disk and mount on /mnt"
mkfs.vfat -S 4096 /dev/nvme0n1p1

mkfs.btrfs /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@.snapshots
umount /dev/nvme0n1p2
mount -o noatime,compress=lzo,space_cache,subvol=@root /dev/nvme0n1p2 /mnt/
mkdir /mnt/{boot,home,.snapshots,data}
mkdir /mnt/data/{Data,MassiveData}
mount /dev/nvme0n1p1 /mnt/boot
mount -o noatime,compress=lzo,space_cache,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o noatime,compress=lzo,space_cache,subvol=@.snapshots /dev/nvme0n1p2 /mnt/.snapshots
mount -o noatime,nodatacow,compress=lzo,space_cache,subvol=@data /dev/sda2 /mnt/data/Data
mount -o noatime,nodatacow,compress=lzo,space_cache,subvol=@secure_data /dev/sda2 /mnt/data/SecureData
mount -o noatime,nodatacow,compress=lzo,space_cache,subvol=@massive_data /dev/sda2 /mnt/data/MassiveData

sleep 3;

echo "Refresh mirror list"
reflector --verbose --country 'Ukraine' --sort rate --save /etc/pacman.d/mirrorlist
sleep 2;

echo "Install base package"
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd intel-ucode zsh reflector btrfs-progs go networkmanager man
sleep 2;

echo "Copying mirrorlist"
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
sleep 2;

echo "Setting system"
genfstab -U /mnt >> /mnt/etc/fstab
cp /etc/zsh/* /mnt/etc/zsh/
echo "Chroot enter"
cp -r /root/Arch_linux_install /mnt/root/

acrh-chroot /mnt bash -c "$(echo "Please run 'bash /root/Arch_linux_install/install_and_settings_programs.sh'")"
# arch-chroot /mnt bash -c "$(curl -fsSL https://raw.githubusercontent.com/vkluad/Arch_linux_install/main/install_and_settings_programs.sh)" $NAME_SSD
