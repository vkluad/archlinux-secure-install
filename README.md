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
**For scan you device run:**
```sh
fdisk -l
```
**This command will display somethings like that:**
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
 >For install base system in nvme drive run next command:
 ```sh
 gdisk /dev/nvme0n1
 ```
In this programm we must created GUID partition table. For this press `o`.\
Programm send for you some massage like that:\
 `This operation deleted all your information in this drive[Y/N]`\
  your course press `y`.\
Next
