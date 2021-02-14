# **Arch linux Installation script**
> The script will install arch linux on the encrypted luks partition.

#### **Use the following command to connect to the wifi network**:
```sh
iwctl --passphrase=WLAN_PASSWORD station wlan0 connect NAME_WIFI
```

#### **Download a folder with installation script**
```sh
git clone https://github.com/vkluad/Arch_linux_install.git
cd Arch_linux_install
```

### **!!!You must have SD-card, SSD drive and HDD drive!!!**


### **For start installation  run script:**
> This script installed the base packeges, but system will not be able to boot.
```sh
./install.sh
```
> After this script run a settings script:
```sh
./settings.sh
```
>
## **Configure mkinitcpio**
##### You must edit /etc/mkinitcpio.conf HOOKS and FILES
>```sh
nano /etc/mkinitcpio.conf
```
Edit string who`s include:
>```
...
FILES=(vfat)
...
HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems fsck)
...
```
## **Installation EFISTUB bootloader**
##### You must configure efi vars.
>*So, those both scripts also install base system. In order to install loader or EFISTUB you must run this command:*
 ```sh
efibootmgr -d /dev/nvme0n1 -p 1 -c -L "Arch linux encrypt nvme" -l \vmlinuz-linux -u "dm.luks.name=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX=nvme0n1p2_crypt rd.luks.key=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX=/4HA6LZWyLGTu6bQv967KEQH5wg7WersN:UUID=ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ root=/dev/mapper/nvme0n1p2_crypt rw rootflags=subvol=@ initrd=\intel-ucode.img initrd=\initramfs-linux.img"
```
>*For sda:*
```sh
efibootmgr -d /dev/sda -p 1 -c -L "Arch linux encrypt sda" -l \vmlinuz-linux -u "dm.luks.name=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX=sda2_crypt rd.luks.key=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX=rhaTfhJBvhSvgK9E2hSZF4P4u6s8NUsY:UUID=ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ root=/dev/mapper/sda2_crypt rw rootflags=subvol=@ initrd=\intel-ucode.img initrd=\initramfs-linux.img"
```
>*XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX this UUID encryption drive,\
 ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ this UUID drive how`s include key file*

### **After install script :**
```sh
arch-chroot /{nvme_root_crypt or sda_root_crypt}

```
