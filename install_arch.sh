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
NAME_D=""


while [[ $I != 1 ]]; do
  echo "Enter the disk name "
  read NAME_D
  for NAME_D_T in "sda" "vda" "nvme0n1"
  do
    if [[ $NAME_D = $NAME_D_T ]]; then
      if [[ "$(fdisk -l | grep "$NAME_D")" ]]; then
        I=1
      else
        echo
        echo "Please enter Disk in "
        echo
        fdisk -l | grep "Disk /"
      fi

    fi
  done
done

echo "#####################################################"
echo "Will be created partition on /dev/$NAME_D"
echo
echo "Start sector for gpt ssd is 40"
echo
echo "#####################################################"
echo "If your wanna change start sector please enter y/N "
read CH_SEC;
if [ "$CH_SEC" = "y" ]
then
  echo "Please enter the start setion (34(for gpt 512b), 40 for gpt 4K) default 40:"
  read START_SEC_T
  if [ $START_SEC_T > 33 ]
  then
    START_SEC=$START_SEC_T
  else
    echo "40 is default start sector now"
  fi
fi



read STOP;
BOOT_SIZE="300M"
ROOT_SIZE="90G"
HOME_SIZE="10G"

echo "/boot (esp) $BOOT_SIZE"
echo "/ $ROOT_SIZE(f2fs)"
echo "/home all other + $HOME_SIZE(f2fs)"
echo

echo "If your wanna change please enter y/N"
read CH_DISK;
if [[ "$CH_DISK" = "y" ]]
then
  echo "Please enter size of /boot partition(recommented minimum size 300M)"
  read BOOT_SIZE_T
  if [ "$BOOT_SIZE_T" > "100M" ]
  then
    BOOT_SIZE=$BOOT_SIZE_T
  else
    echo "System selected default value($BOOT_SIZE)"
  fi

  echo "Please enter size of root partiotion(recommented minimum size 25G)"
  read ROOT_SIZE_T
  if [ "$ROOT_SIZE_T" > "25G" ]
  then
    ROOT_SIZE=$ROOT_SIZE_T
  else
    echo "System selected default value($ROOT_SIZE)"
  fi

  echo "Home partition will be created of all free size -$HOME_SIZE"

fi

echo "Press enter to continue"
read STOP;

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
) | gdisk /dev/$NAME_D

if [ "$NAME_D" = "nvme0n1" ]
then
  P='p'
else
  P=''
fi

echo "Format disk and mount on /mnt"
mkfs.vfat /dev/$NAME_D$P\1
mkfs.f2fs /dev/$NAME_D$P\2
mkfs.f2fs /dev/$NAME_D$P\3
mount /dev/$NAME_D$P\2 /mnt
mkdir /mnt/home
mkdir /mnt/boot
mount /dev/$NAME_D$P\1 /mnt/boot
mount /dev/$NAME_D$P\3 /mnt/home
echo "please enter to continiue"
read STOP;
sleep 3

echo "Refresh mirror list"
reflector --verbose --country 'Ukraine' --sort rate --save /etc/pacman.d/mirrorlist
sleep 2

echo "Install base package"
pacstrap /mnt base base-devel linux linux-firmware nano netctl dhcpcd intel-ucode zsh reflector
sleep 2

echo "Copying mirrorlist"
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
sleep 2

echo "Setting system"
genfstab -U /mnt >> /mnt/etc/fstab
echo "Chroot enter"
arch-chroot /mnt bash -c "$(curl -fsSL https://raw.githubusercontent.com/vkluad/Arch_linux_install/main/install_and_setting_arch_out_base.sh)"
