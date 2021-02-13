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
BOOT_SIZE="300M"
HOME_SIZE="10G"



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
echo "/ btrfs subvolume created (@,@home,@.snapshots)"
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

mkfs.ext4 /dev/mmcblk0p1
mkdir /{mmcblk0,sda,nvme0n1}
MOUNT_SSD=nvme0n1
MOUNT_HDD=sda
mount /dev/mmcblk0p1 /mmcblk0
dd if=/dev/random of=/mmcblk0/4HA6LZWyLGTu6bQv967KEQH5wg7WersN bs=1024 count=4 # create secret key nvme0n1
dd if=/dev/random of=/mmcblk0/rhaTfhJBvhSvgK9E2hSZF4P4u6s8NUsY bs=1024 count=4 # create secret key sda

# cryptsetup
cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash whirlpool --iter-time 4082 --key-size 512 --pbkdf argon2id --sector-size 4096 --use-random  /dev/nvme0n1p2 /mmcblk0/4HA6LZWyLGTu6bQv967KEQH5wg7WersN
cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash whirlpool --iter-time 4082 --key-size 512 --pbkdf argon2id --sector-size 4096 --use-random  /dev/sda2 /mmcblk0/rhaTfhJBvhSvgK9E2hSZF4P4u6s8NUsY

cryptsetup luksHeaderBackup /dev/sda2 --header-backup-file /mmcblk0/EvvXtpkDXFTNqd22ePpv7ECtHLmNgBpU        # luksHeaderBackup for sda2
cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file /mmcblk0/rVAd46RpwrNw97kNEnBFj7tsNsx3yMPq   # luksHeaderBackup for nvme0n1

echo YES | cryptsetup luksDump --key-file /mmcblk0/4HA6LZWyLGTu6bQv967KEQH5wg7WersN /dev/nvme0n1p2 --dump-master-key > /mmcblk0/nxbD8Zu4Qk9xFz2Bc66eweQQkZfbRn64 # master-key-file for nvme0n1
echo YES | cryptsetup luksDump --key-file /mmcblk0/rhaTfhJBvhSvgK9E2hSZF4P4u6s8NUsY /dev/sda2 --dump-master-key > /mmcblk0/c9mrqFA8Lh5mf7xWqTNdk3CHgU7Xecrz # master-key-file for sda

# cryptsetup luksAddKey --key-file key --hash whirlpool --pbkdf argon2id --iter-time 4082 /dev/sda3 # add passphrase or keys















mkfs.vfat -S 4096 /dev/nvme0n1p1
mkfs.vfat -S 4096 /dev/sda1

################################################################################
mkfs.btrfs -s 4096 /dev/nvme0n1p2
mkfs.btrfs -s 4096 /dev/sda1

mount /dev/nvme0n1p2 /$MOUNT_SSD
mount /dev/sda2 /$MOUNT_HDD

btrfs subvolume create /$MOUNT_SSD/@
btrfs subvolume create /$MOUNT_HDD/@

btrfs subvolume create /$MOUNT_SSD/@home
btrfs subvolume create /$MOUNT_HDD/@home

btrfs subvolume create /$MOUNT_SSD/@.snapshots
btrfs subvolume create /$MOUNT_HDD/@.snapshots

umount /dev/nvme0n1p2
umount /dev/sda2

################################################################################

mount -o noatime,compress=lzo,space_cache,subvol=@ /dev/nvme0n1p2 /$MOUNT_SSD/
mount -o noatime,nodatacow,compress=lzo,space_cache,subvol=@ /dev/nvme0n1p2 /$MOUNT_HDD/

mkdir /$MOUNT_SSD/{boot,home,.snapshots,data}
mkdir /$MOUNT_HDD/{boot,home,.snapshots,data}

mkdir /$MOUNT_SSD/data/{Data,MassiveData}
mkdir /$MOUNT_HDD/data/{Data,MassiveData}

mount /dev/nvme0n1p1 /$MOUNT_SSD/boot
mount /dev/sda1 /$MOUNT_HDD/boot

mount -o noatime,compress=lzo,space_cache,subvol=@home /dev/nvme0n1p2 /$MOUNT_SSD/home
mount -o noatime,nodatacow,compress=lzo,space_cache,subvol=@home /dev/nvme0n1p2 /$MOUNT_HDD/home

mount -o noatime,compress=lzo,space_cache,subvol=@.snapshots /dev/nvme0n1p2 /$MOUNT_SSD/.snapshots
mount -o noatime,nodatacow,compress=lzo,space_cache,subvol=@.snapshots /dev/nvme0n1p2 /$MOUNT_HDD/.snapshots
################################################################################

mount -o noatime,nodatacow,compress=lzo,space_cache,subvol=@data /dev/sda2 /$MOUNT_SSD/data/Data
mount -o noatime,nodatacow,compress=lzo,space_cache,subvol=@data /dev/sda2 /$MOUNT_HDD/data/Data

mount -o noatime,nodatacow,compress=lzo,space_cache,subvol=@massive_data /dev/sda2 /$MOUNT_SSD/data/MassiveData
mount -o noatime,nodatacow,compress=lzo,space_cache,subvol=@massive_data /dev/sda2 /$MOUNT_HDD/data/MassiveData

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

# arch-chroot /mnt bash -c "$(echo "Please run 'bash /root/Arch_linux_install/install_and_settings_programs.sh'")"
arch-chroot /mnt bash -c "$(/root/Arch_linux_install/install_and_settings_programs.sh)"
