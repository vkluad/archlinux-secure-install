# **Arch linux Installation programm**

#### If you used wifi connection please run:
```sh
iwctl --passphrase=WLAN_PASSWORD station wlan0 connect NAME_WIFI
```
## **Prepear installation :**
Before installation you must have SD card or Yubikey for saves gpg key.\
If you haven`t gpg key, you can create key or using passphrase for encrypt you drive


#### For start installation you must download repository and run programm:
```bash
git clone https://github.com/vkluad/Arch_linux_install.git
cd Arch_linux_install
./install.sh
```

When script finished, system will had 2 partitions on nvme0n1 devices and
