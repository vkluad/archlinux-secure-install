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
In this programm we must created GUID partition table. For this press `o`.\
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
  > ```sh
    mkdir /mmcblk0
    mount /dev/mmcblk0p1 /mmcblk0
    ```
* **Create secret key for luks device**
  > ```sh
  dd if=/dev/random of=/mmcblk0/nvme0n1p2_luks.key bs=1024 count=4
  ```
* **Format to luks partition**
  >
  ```sh
  cryptsetup luksFormat --type luks2 --cipher aes-xts-plain64 --hash whirlpool --iter-time 5058 --key-size 512 --pbkdf argon2id --use-random  /dev/nvme0n1p2 /mmcblk0/nvme0n1p2_luks.key
  ```
  `--chipher aes-xts-plain64` - it's cipher who used in crypt you device, but your can chose another cipher\
   between `aes-xts-plain64`, `serpent-xts-plain64` and `twofish-xts-plain64`(with 512b key-size).\
  `--iter-time 5058` - you can chose another numbers, but no recommend over `10000` and smaller `2000`.\
  `--hash whirlpool` - you can chose another hash function, example `sha256`,`sha512`
* **Create luksHeaderBackup**
  >```sh
  cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file /mmcblk0/nvme0n1p2_luks_headerbackup.bin
  ```
* **Create master key backup**
>```sh
echo YES | cryptsetup luksDump --key-file /mmcblk0/nvme0n1p2_luks.key /dev/nvme0n1p2 --dump-master-key > /mmcblk0/nvme0n1p2_luks_master_key
```
* **Create passphrase (recommend 16+ random symbols)**
>```sh
cryptsetup luksAddKey --key-file /mmcblk0/nvme0n1p2_luks.key --hash whirlpool --pbkdf argon2id --iter-time 5058 /dev/nvme0n1p2
```
* **Open crypted device**
>```sh
cryptsetup luksOpen  --key-file /mmcblk0/nvme0n1p2_luks.key /dev/nvme0n1p2 nvme0n1p2_crypt
```
* **Format all partitions**
>```sh
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.btrfs -f /dev/mapper/nvme0n1p2_crypt
```
