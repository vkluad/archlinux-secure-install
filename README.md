# **Arch linux Installation script**
> This script installed arch linux on encrypted LUKS partition

#### If you used wifi connection please run:
```sh
iwctl --passphrase=WLAN_PASSWORD station wlan0 connect NAME_WIFI
```
### **Before installation you must have mmcblk0 device for saving key**
> You can used Yubikey for saving you keys but you must have gpg key.

#### **Download git repository**
```sh
git clone https://github.com/vkluad/Arch_linux_install.git
cd Arch_linux_install
```

### **!!!You must have SD-card, SSD drive and HDD drive!!!**


### **For start installation  run script:**
```sh
./install.sh
```
