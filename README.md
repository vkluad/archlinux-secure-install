# NOT COMPLETED

# **Arch linux Installation script**
> The script will install arch linux on the encrypted luks partition.

### **Use the following command to connect to the wifi network**:
```sh
iwctl --passphrase=WLAN_PASSWORD station wlan0 connect NAME_WIFI
```

### **Download a folder with installation script**
```sh
git clone https://github.com/vkluad/Arch_linux_install.git
cd Arch_linux_install
```

> Okay, admissibly you have all requirements for archlinux install.

### **The first step is set the date.**
**For this you must run command:**
```sh
timedatectl set-ntp true
```
> This command set date in all system ( and BIOS/UEFI ).\
And if you verify date you can run `timedatectl status`

### **The next step you must created partition on you drive('s)**
>**For scan you device run:**

```sh
fdisk -l
```
>**This command will display somethings like that:**

```
Disk /dev/nvme0n1: 232.89 GiB, 250059350016 bytes, 488397168 sectors
Disk model: KINGSTON SA2000M8250G                   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: DEA48E55-19A1-4A37-BA06-42A84A14FE4E

Device          Start       End   Sectors   Size Type
/dev/nvme0n1p1     40    614439    614400   300M EFI System
/dev/nvme0n1p2 614440 488397134 487782695 232.6G Linux filesystem


Disk /dev/sda: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors
Disk model: ST1000LX015-1U71
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 0CAC0EB5-94F5-4171-83CA-EF1F8949B566

Device      Start        End    Sectors   Size Type
/dev/sda1      40     614439     614400   300M EFI System
/dev/sda2  614440 1953525134 1952910695 931.2G Linux filesystem

```

**Next we need to select the drive on which the system will be installed.\
I chose nvme0n1 drive, but this just because nvme drive is very fastly.**
 >For nvme drive run next command:
 ```sh
 gdisk /dev/nvme0n1
 ```
 >In this programm we must created GUID partition table. For this press `o`.\
  Programm send for you some massage like that:\
 `This operation deleted all your information in this drive[Y/N]`\
  Your course press `y`.\
  Next, just added **efi** and **linux filesystem** partition , but if you have\
  the same opinion as i am and you appreciate every byte, then you like to start\
  the drive with `40` bytes instead of `2048`.\
  To do so just press `x` then `l`, and enter `40`, after press `m`.\
  Next you have create partition, so, press `n` after chose initial byte( we chose\
  default byte equal `40` if you do previous step. If no, then default byte is `2048` )\
  UEFI partitions like 100-500 Mb, I recommend chose over 300 Mb.\
  And you must chose ef00 is type partition.\
  Okay, your terminal will be liked in this:

```
GPT fdisk (gdisk) version 1.0.6

Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.

Command (? for help): o
This option deletes all partitions and creates a new protective MBR.
Proceed? (Y/N): y

Command (? for help): x

Expert command (? for help): l
Enter the sector alignment value (1-65536, default = 2048): 40

Expert command (? for help): m

Command (? for help): n
Partition number (1-128, default 1):
First sector (34-30240734, default = 40) or {+-}size{KMGTP}:
Last sector (40-30240734, default = 30240734) or {+-}size{KMGTP}: +300M      
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300): ef00
Changed type of partition to 'EFI system partition'

Command (? for help): n
Partition number (2-128, default 2):
First sector (34-30240734, default = 614440) or {+-}size{KMGTP}:
Last sector (614440-30240734, default = 30240734) or {+-}size{KMGTP}:
Current type is 8300 (Linux filesystem)
Hex code or GUID (L to show codes, Enter = 8300):
Changed type of partition to 'Linux filesystem'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): y
```
```
o
y
x
l
40
m
n
(Enter)
(Enter)
+300M
ef00
n
(Enter)
(Enter)
(Enter)
(Enter)
w
y
```

#### **For next manipulation you must have mmcblk device( SD card):**
* **MountSD card**
  ```sh
  mkdir /mmcblk0
  mount /dev/mmcblk0p1 /mmcblk0
  ```
* **Create secret key for luks device**
  ```sh
  dd if=/dev/random of=/mmcblk0/nvme0n1p2_luks.key bs=1024 count=4
  ```
* **Format to luks partition**

  ```sh
  cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash whirlpool --iter-time 5058\
   --key-size 512 --pbkdf argon2id --use-random  /dev/nvme0n1p2 /mmcblk0/nvme0n1p2_luks.key
  ```
  > `--chipher aes-xts-plain64` - it's cipher who used in crypt you device, but your can chose another cipher\
   between `aes-xts-plain64`, `serpent-xts-plain64` and `twofish-xts-plain64`(with 512b key-size).\
  `--iter-time 5058` - you can chose another numbers, but no recommend over `10000` and smaller `2000`.\
  `--hash whirlpool` - you can chose another hash function, example `sha256`,`sha512`
* **Create luksHeaderBackup**
  ```sh
  cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file /mmcblk0/nvme0n1p2_luks_headerbackup.bin
  ```
* **Create master key backup**
  ```sh
  echo YES | cryptsetup luksDump --key-file /mmcblk0/nvme0n1p2_luks.key /dev/nvme0n1p2\
   --dump-master-key > /mmcblk0/nvme0n1p2_luks_master_key
  ```
* **Create passphrase (recommend 16+ random symbols)**
  ```sh
  cryptsetup luksAddKey --key-file /mmcblk0/nvme0n1p2_luks.key --hash whirlpool\
   --pbkdf argon2id --iter-time 5058 /dev/nvme0n1p2
  ```
* **Open crypted device**
  ```sh
  cryptsetup luksOpen  --key-file /mmcblk0/nvme0n1p2_luks.key /dev/nvme0n1p2 nvme0n1p2_crypt
  ```
* **Format all partitions**
  ```sh
  mkfs.fat -F32 /dev/nvme0n1p1
  mkfs.btrfs -f /dev/mapper/nvme0n1p2_crypt
  ```
* **Mount created filesystem and create subvolume**
  ```sh
  mount /dev/mapper/nvme0n1p2_crypt /mnt
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@.snapshots
  umount /dev/mapper/nvme0n1p2_crypt
  ```
  >**Also you can create other subvolume**

* **Mount filesystem with disk parameters**
  ```sh
  mount -o noatime,compress=zstd,space_cache,subvol=@\
   /dev/mapper/nvme0n1p2_crypt /mnt/
  ```
  >We must create folders for mount other subvolume
  ```sh
  mkdir -p /mnt/{boot/efi,home,.snapshots,data}
  ```
  >`data` folder created for you data disk, if you haven't other disk or memory your do not need it.
* **Mount efi partition:**
  ```sh
  mount /dev/nvme0n1p1 /mnt/boot/efi
  ```
* **Mount other subvolumes:**
  ```sh
  mount -o noatime,compress=zstd:7,space_cache,subvol=@home\
   /dev/mapper/nvme0n1p2_crypt /mnt/home
  mount -o noatime,compress=zstd:7,space_cache,subvol=@.snapshots\
   /dev/mapper/nvme0n1p2_crypt /mnt/.snapshots
  ```
  or `HDD` added `nodatacow`:
  ```sh
   mount -o noatime,nodatacow,compress=zstd:7, ...
   ```
* **Refresh mirrorlist:**
  ```sh
  reflector --verbose --country 'Ukraine' --sort rate --save /etc/pacman.d/mirrorlist
  ```
* **Install base package:**
  ```sh
  pacstrap /mnt base base-devel linux linux-firmware dracut nano dhcpcd intel-ucode zsh reflector btrfs-progs go networkmanager man
  ```
* **Copying mirrorlist to new system:**
  ```sh
  cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
  ```
* **Generate fstab:**
  ```sh
  genfstab -U /mnt >> /mnt/etc/fstab
  ```
* **Copying settings for zsh to new system:**
  ```sh
  cp -r /etc/zsh/* /mnt/etc/zsh/
  ```
* **Copy git folders to new system:**
  ```sh
  cp -r /root/archlinux-secure-install /mnt/root/
  ```
* **Umount SD card:**
  ```sh
  umount /dev/mmcblk0p1
  ```
* **Login to chroot:**
  ```sh
  arch-chroot /mnt
  ```
* **Localtime settings:**
  ```sh
  ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
  ```
* **Change command shell:**
  ```sh
  chsh -s /bin/zsh
  ```
* **Create hostname for you pc**
  ```sh
  echo "arch-pc" > /etc/hostaname
  ```

* **Create new user**
  ```sh
  useradd -m -g users -G wheel -s /bin/zsh USERNAME
  ```
  >If you wanna sudo privilegies for your user, you must uncomment `# %wheel ALL=(ALL) ALL` in /etc/sudoers:

* **Create password for you users**
  >Password for root:
  ```sh
  passwd
  ```
  >Password for another users:
  ```sh
  passwd USERNAME
  ```
* **Uncomment you locale in file `/etc/locale.conf`:**
  > Uncomment `en_US.UTF-8 UTF-8` if your language is english
* **Generate your locale:**
  ```sh
  locale-gen
  ```
* **Add your current locale:**
  ```sh
  echo 'LANG=en_US.UTF-8' > /etc/locale.conf
  ```
* **Added `vconsole.conf` for preload console setting.**
  ```sh
  cp /root/archlinux-secure-install/configuration/vconsole.conf /etc/vconsole.conf
  ```
* **Added `/etc/hosts` :**
  ```sh
  cp /root/archlinux-secure-install/configuration//hosts /etc/hosts
  ```
* **For used to lib32 apps you must uncoment:**\
  `[multilib]` and `Include = /etc/pacman.d/mirrorlist`\
  in file `/etc/pacman.conf`
* **Set up NetworkManager to autostart:**
  ```sh
  systemctl enable NetworkManager
  ```

  * **Instalation programm for you**
    ```sh
    pacman -Suy dialog wpa_supplicant gnome nvidia nvidia-prime nvidia-settings wget git atom gimp \
    firefox blender cuda libreoffice-still discord telegram-desktop vulkan-devel nvidia-cg-toolkit \
    lib32-nvidia-cg-toolkit chromium tor ghex htop jdk11-openjdk jre-openjdk \
    jre-openjdk-headless jre11-openjdk jre11-openjdk-headless shotcut efibootmgr embree \
    exfat-utils gstreamer-vaapi iotop screen neofetch zerotier-one ncdu ntfs-3g rsync \
    chrome-gnome-shell torbrowser-launcher qbittorrent obs-studio clevis tpm2-tools tpm2-tss \
    tpm2-totp tpm2-tss-engine tpm2-abrmd dracut libpwquality luksmeta nmap squashfs-tools efitools sbsingtools
    ```
    >**Install yay for installing program from AUR:**
    >**Your user must have sudo permition**
    ```sh
    su USERNAME
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    yay -S wd719x-firmware aic94xx-firmware upd72020x-fw plymouth \
    optimus-manager gdm-prime libgdm-prime zoom teams skypeforlinux-stable-bin\
    youtube-music-appimage clion clion-jre clion-cmake clion-gdb clion-lldb
    exit
    systemctl enable gdm
    systemctl enable fstrim.timer #if you used to ssd drive
    ```
    >You can delete all program except `wd719x-firmware aic94xx-firmware upd72020x-fw plymouth`.

* **Mount SD card for next manipulation**
  ```sh
  mkdir -p /run/media/USERNAME/LABEL_DEVICE
  mount /dev/mmcblk0p1 /run/media/USERNAME/LABEL_DEVICE

  ```
* **Generate sertificates**
  ```sh
  mkdir /run/media/USERNAME/LABEL_DEVICE/UEFI_SIGNATURE_KEY
  cd /run/media/USERNAME/LABEL_DEVICE/UEFI_SIGNATURE_KEY
  ./root/archlinux-secure-install/sertificates/get-sertificates.sh
  ```

* **Configure dracut:**
  >Before copying you must edit this file:
  paste you `UUID` in `/root/archlinux-secure-install/configuration/dracut.conf`\
  And other setting edit in this file.\
  For seen UUID used to `blkid /dev/nvme0n1p2`\
  or another drive who used for luks crypt.\
  For optimus-manager you can find the configuration file you want to copy\
  to `/etc/optimus-manager/optimus-manager.conf`

  ```sh
  cp /root/archlinux-secure-install/configuration/dracut.conf /usr/lib/dracut/dracut.conf.d/dracut.conf
  mkdir /etc/pacman.d/hooks
  cp /root/archlinux-secure-install/configuration/dracut-install.sh /etc/pacman.d/hooks/dracut-install.sh
  cp /root/archlinux-secure-install/configuration/dracut-remove.sh /etc/pacman.d/hooks/dracut-remove.sh
  cp /root/archlinux-secure-install/configuration/*.hook /etc/pacman.d/hooks/
  mkdir -p /boot/efi/EFI/Linux
  ```
  
  * **Nano syntax light: **
  > `find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> ~/.nanorc`
  
