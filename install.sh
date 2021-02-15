#!/bin/bash
# This script created specially for gpt disk and ssd

if  ! ping -c1 8.8.8.8 > /dev/null;
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
BOOT_SIZE="200M"
HOME_SIZE="10G"


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
    echo; # -$HOME_SIZE;
    echo 8300;

    echo w;
    echo y;
) | gdisk /dev/nvme0n1

echo "Created partitions on sda device"
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


echo "Created partitions on SD Card"
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
    echo;
    echo 8300;

    echo w;
    echo y;
) | gdisk /dev/mmcblk0



echo "Format disk and mount on /mnt"

MOUNT_SSD=nvme_root_crypt
MOUNT_HDD=sda_root_crypt
MOUNT_SD=mmcblk
mkfs.ext4 /dev/mmcblk0p1
mkdir /{${MOUNT_SD} ,${MOUNT_HDD} ,${MOUNT_SSD}}

LUKS_KEY_SSD=nvme0n1p2_luks.key
LUKS_KEY_HDD=sda2_luks.key
HEADERBACKUP_SSD=nvme0n1p2_luks_headerbackup.bin
HEADERBACKUP_HDD=sda2_luks_headerbackup.bin
MASTERKEY_SSD=nvme0n1p2_luks_master_key
MASTERKEY_HDD=sda2_luks_master_key

mount /dev/mmcblk0p1 /${MOUNT_SD}
dd if=/dev/random of=/${MOUNT_SD}/${LUKS_KEY_SSD} bs=1024 count=4 # create secret key nvme0n1 luks-nvme0n1p2.key
dd if=/dev/random of=/${MOUNT_SD}/${LUKS_KEY_HDD} bs=1024 count=4 # create secret key sda luks-sda2.key

# cryptsetup
cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash whirlpool --iter-time 5058 --key-size 512 --pbkdf argon2id --sector-size 4096 --use-random  /dev/nvme0n1p2 /${MOUNT_SD}/${LUKS_KEY_SSD}
cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash whirlpool --iter-time 5058 --key-size 512 --pbkdf argon2id --sector-size 4096 --use-random  /dev/sda2 /${MOUNT_SD}/${LUKS_KEY_HDD}

cryptsetup luksHeaderBackup /dev/sda2 --header-backup-file /${MOUNT_SD}/${HEADERBACKUP_HDD}        # luksHeaderBackup for sda2 /${MOUNT_SD}/HeaderBackup_sda2
cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file /${MOUNT_SD}/${HEADERBACKUP_SSD}   # luksHeaderBackup for nvme0n1 /${MOUNT_SD}/HeaderBackup_nvme0n1p2

echo YES | cryptsetup luksDump --key-file /${MOUNT_SD}/${LUKS_KEY_SSD} /dev/nvme0n1p2 --dump-master-key > /${MOUNT_SD}/${MASTERKEY_SSD} # master-key-file for nvme0n1
echo YES | cryptsetup luksDump --key-file /${MOUNT_SD}/${LUKS_KEY_HDD} /dev/sda2 --dump-master-key > /${MOUNT_SD}/${MASTERKEY_HDD} # master-key-file for sda

# cryptsetup luksAddKey --key-file /${MOUNT_SD}/${LUKS_KEY_HDD} --hash whirlpool --pbkdf argon2id --iter-time 4058 /dev/sda2 # add passphrase or keys on HDD
# cryptsetup luksAddKey --key-file /${MOUNT_SD}/${LUKS_KEY_SSD} --hash whirlpool --pbkdf argon2id --iter-time 4058 /dev/nvme0n1p2 # add passphrase or keys on SSD

cryptsetup luksOpen  --key-file /${MOUNT_SD}/${LUKS_KEY_SSD} /dev/nvme0n1p2 nvme0n1p2_crypt
cryptsetup luksOpen  --key-file /${MOUNT_SD}/${LUKS_KEY_HDD} /dev/sda2 sda2_crypt

mkfs.fat -F32 -S 4096 /dev/nvme0n1p1
mkfs.fat -F32 -S 4096 /dev/sda1

################################################################################
mkfs.btrfs -s 4096 /dev/mapper/nvme0n1p2_crypt
mkfs.btrfs -s 4096 /dev/mapper/sda2_crypt

mount /dev/mapper/nvme0n1p2_crypt /${MOUNT_SSD}
mount /dev/mapper/sda2_crypt /${MOUNT_HDD}

btrfs subvolume create /${MOUNT_SSD}/@
btrfs subvolume create /${MOUNT_HDD}/@

btrfs subvolume create /${MOUNT_SSD}/@home
btrfs subvolume create /${MOUNT_HDD}/@home

btrfs subvolume create /${MOUNT_SSD}/@.snapshots
btrfs subvolume create /${MOUNT_HDD}/@.snapshots

btrfs subvolume create /${MOUNT_HDD}/@data
btrfs subvolume create /${MOUNT_HDD}/@massive_data

umount /dev/mapper/nvme0n1p2_crypt
umount /dev/mapper/sda2_crypt


mount -o noatime,compress=zstd,space_cache,subvol=@ /dev/mapper/nvme0n1p2_crypt /${MOUNT_SSD}/
mount -o noatime,nodatacow,compress=zstd,space_cache,subvol=@ /dev/mapper/sda2_crypt /${MOUNT_HDD}/

mkdir /${MOUNT_SSD}/{boot,home,.snapshots,data}
mkdir /${MOUNT_HDD}/{boot,home,.snapshots,data}
mkdir /${MOUNT_SSD}/boot/efi
mkdir /${MOUNT_HDD}/boot/efi

mkdir /${MOUNT_SSD}/data/{Data,MassiveData}
mkdir /${MOUNT_HDD}/data/{Data,MassiveData}

mount /dev/nvme0n1p1 /${MOUNT_SSD}/boot/efi
mount /dev/sda1 /${MOUNT_HDD}/boot/efi

mount -o noatime,compress=zstd,space_cache,subvol=@home /dev/mapper/nvme0n1p2_crypt /${MOUNT_SSD}/home
mount -o noatime,nodatacow,compress=zstd,space_cache,subvol=@home /dev/mapper/sda2_crypt /${MOUNT_HDD}/home

mount -o noatime,compress=zstd,space_cache,subvol=@.snapshots /dev/mapper/nvme0n1p2_crypt /${MOUNT_SSD}/.snapshots
mount -o noatime,nodatacow,compress=zstd,space_cache,subvol=@.snapshots /dev/mapper/sda2_crypt /${MOUNT_HDD}/.snapshots

mount -o noatime,nodatacow,compress=zstd,space_cache,subvol=@data /dev/mapper/sda2_crypt /${MOUNT_SSD}/data/Data
mount -o noatime,nodatacow,compress=zstd,space_cache,subvol=@data /dev/mapper/sda2_crypt /${MOUNT_HDD}/data/Data

mount -o noatime,nodatacow,compress=zstd,space_cache,subvol=@massive_data /dev/mapper/sda2_crypt /${MOUNT_SSD}/data/MassiveData
mount -o noatime,nodatacow,compress=zstd,space_cache,subvol=@massive_data /dev/mapper/sda2_crypt /${MOUNT_HDD}/data/MassiveData

sleep 3;

echo "Refresh mirror list"
reflector --verbose --country 'Ukraine' --sort rate --save /etc/pacman.d/mirrorlist
sleep 2;

echo "Install base package"
pacstrap /${MOUNT_SSD} base base-devel linux linux-firmware nano dhcpcd intel-ucode zsh reflector btrfs-progs go networkmanager man
pacstrap /${MOUNT_HDD} base base-devel linux linux-firmware nano dhcpcd intel-ucode zsh reflector btrfs-progs go networkmanager man
sleep 2;

echo "Copying mirrorlist"
cp /etc/pacman.d/mirrorlist /${MOUNT_SSD}/etc/pacman.d/mirrorlist
cp /etc/pacman.d/mirrorlist /${MOUNT_HDD}/etc/pacman.d/mirrorlist
sleep 2;

echo "Setting system"
genfstab -U /${MOUNT_SSD} >> /${MOUNT_SSD}/etc/fstab
genfstab -U /${MOUNT_HDD} >> /${MOUNT_HDD}/etc/fstab

cp /etc/zsh/* /${MOUNT_SSD}/etc/zsh/
cp /etc/zsh/* /${MOUNT_HDD}/etc/zsh/
echo "Chroot enter"
cp -r /root/Arch_linux_install /${MOUNT_SSD}/root/
cp -r /root/Arch_linux_install /${MOUNT_HDD}/root/



# arch-chroot /mnt bash -c "$(echo "Please run 'bash /root/Arch_linux_install/install_and_settings_programs.sh'")"
# arch-chroot /mnt bash -c "$(/root/Arch_linux_install/install_and_settings_programs.sh)"
