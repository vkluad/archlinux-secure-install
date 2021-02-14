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
> **You must edit /etc/mkinitcpio.conf HOOKS and FILES**

```sh
nano /etc/mkinitcpio.conf
```

> **Edit string who`s include:**

```
...
FILES=(vfat)
...
HOOKS=(base systemd sd-plymouth autodetect keyboard sd-vconsole modconf block sd-encrypt filesystems fsck)
...
```
