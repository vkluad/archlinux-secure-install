# **Arch linux Installation script**

#### If you used wifi connection please run:
```sh
iwctl --passphrase=WLAN_PASSWORD station wlan0 connect NAME_WIFI
```
## **Prepear installation :**
Before installation you must have SD card or Yubikey for saving gpg key.\
If you haven't gpg key, you can create key or using passphrase for encrypt you drive and for security.

### **GPG keys:**

#### **To view our public keys there is a command:**
```sh
gpg -k
```
`gpg --list-keys --keyid-format LONG` (Or we used this command for views keys.)

#### **In order to see the private keys there is a command:**
```sh
gpg -K
```
`gpg --list-secret-keys --keyid-format LONG`(Or we used this command for views keys.)

#### **For generation key you can to used:**


<pre><font color="#C01C28"><b>root</b></font>@Pu4taz <b>/home/vlad </b>#
gpg --full-generate-key</pre> 


>After entering this command you views this:

```
gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
  (14) Existing key from card
Your selection?
```


### **For start installation you must download repository and run** programm:
```bash
git clone https://github.com/vkluad/Arch_linux_install.git
cd Arch_linux_install
./install.sh
```

When script finished, system will had 2 partitions on nvme0n1 devices and
2 partitions on sda device.\
If you wanna changes.
