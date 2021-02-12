# **Arch linux Installation script**

#### If you used wifi connection please run:
```sh
iwctl --passphrase=WLAN_PASSWORD station wlan0 connect NAME_WIFI
```
### **Before installation you must have mmblk device for saving key**
> You can used Yubikey for saving you keys but you must have gpg key.

#### **Download git repository**
```sh
git clone https://github.com/vkluad/Arch_linux_install.git
cd Arch_linux_install
```

#### **Check you devices**
> Run script check_dev.sh
```sh
./check_dev.sh
```
If script return :
```sh
Okay
```
This means you continue installation


### **For start installation  run script:**
```sh
./install.sh
```
