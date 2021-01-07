#!/bin/bash
ln -svf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

read -p "Ether the host name: " HOSTNAME
read -p "Enter user name: " USERNAME

echo $HOSTNAME > /etc/hostname
echo "Add user $USERNAME"
useradd -m -g users -G wheel -s /bin/zsh $USERNAME
sed -i 's/.*# %wheel ALL=(ALL) ALL.*/%wheel ALL=(ALL) ALL/' /etc/sudoers

echo "Password for user $USERNAME"
passwd $USERNAME

echo "Password for root user"
passwd

echo 'Added locale in locale.gen'
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "uk_UA.UTF-8 UTF-8" >> /etc/locale.gen

echo 'Update locale in system now'
locale-gen

echo 'LANG="en_US.UTF-8"' > /etc/locale.conf

echo
echo "127.0.0.1  localhost
127.0.1.1  Arch.localdomain.my Arch
::1        localhost ip6-localhost ip6-loopback
ff02::1    ip6-allnodes
ff02::2    ip6-allrouters" >> /etc/hosts

echo 'Recommented library for 32-bit apps'
# sed -i 's/.*#\[multilib\]\n#Include = /etc/pacman.d/mirrorlist.*/\[multilib\]\nInclude = /etc/pacman.d/mirrorlist/' /etc/pacman.conf
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy
echo "Install bootloader"
bootctl --path=/boot install

echo "default Arch" > /boot/loader/loader.conf

PARTUUID="$(blkid /dev/$0\$1\2 | sed -n '/.*PARTUUID="/s///;s/"//p')"
echo "title\tArch Linux
linux\t/vmlinuz-linux
initrd\t/intel-ucode.img
initrd\t/initramfs-linux.img
options\troot=PARTUUID=$PARTUUID" > /boot/loader/entries/Arch.conf


pacman -Suy dialog wpa_supplicant gnome nvidia nvidia-prime nvidia-settings wget git atom gimp firefox blender cuda libreoffice discord telegram-desktop vulkan-devel


useradd -m -g users -G wheel -s /bin/zsh temp
echo "1111" | passwd temp
su temp
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
echo "password for temp user is : 1111"
sleep 2;
makepkg -si
yay -Sy optimus-manager gdm-prime libgdm-prime eclipse-cpp zoom teams skypeforlinux-stable-bin youtube-music-appimage

echo "[optimus]

# This parameter defines the method used to power switch the Nvidia card. See the documentation
# for a complete description of what each value does. Possible values :
#
# - nouveau : load the nouveau module on the Nvidia card.
# - bbswitch : power off the card using the bbswitch module (requires the bbswitch dependency).
# - acpi_call : try various ACPI method calls to power the card on and off (requires the acpi_call dependency)
# - custom: use custom scripts at /etc/optimus-manager/nvidia-enable.sh and /etc/optimus-manager/nvidia-disable.sh
# - none : do not use an external module for power management. For some laptop models it's preferable to
#          use this option in combination with pci_power_control (see below).
switching=none

# Enable PCI power management in Intel mode.
# This option is incompatible with acpi_call and bbswitch, so it will be ignored in those cases.
pci_power_control=no

# Remove the Nvidia card from the PCI bus.
# May prevent crashes caused by power switching.
# Ignored if switching=nouveau or switching=bbswitch.
pci_remove=no

# Reset the Nvidia card at the PCI level before reloading the nvidia module.
# Ensures the card is in a fresh state before reloading the nvidia module.
# May fix some switching issues. Possible values :
#
# - no : does not perform any reset
# - function_level : perform a light "function-level" reset
# - hot_reset : perform a "hot reset" of the PCI bridge. ATTENTION : this method messes with the hardware
#         directly, please read the online documentation of optimus-manager before using it.
#         Also, it will perform a PCI remove even if pci_remove=no.
#
pci_reset=no

# Automatically log out the current desktop session when switching GPUs.
# This feature is currently supported for the following DE/WM :
# GNOME, KDE Plasma, LXDE, Deepin, Xfce, i3, Openbox, AwesomeWM, bspwm and dwm
# If this option is disabled or you use a different desktop environment,
# GPU switching only becomes effective at the next graphical session login.
auto_logout=yes

# GPU mode to use at computer startup. Possible values: nvidia, intel, hybrid, auto
# "auto" is a special mode that auto-detects if the computer is running on battery
# and selects a proper GPU mode. See the other options below.
startup_mode=auto
# GPU mode to select when startup_mode=auto and the computer is running on battery.
# Possible values: nvidia, intel, hybrid
startup_auto_battery_mode=intel
# GPU mode to select when startup_mode=auto and the computer is running on external power.
# Possible values: nvidia, intel, hybrid
startup_auto_extpower_mode=nvidia


[intel]

# Driver to use for the Intel GPU. Possible values : modesetting, intel
# To use the intel driver, you need to install the package "xf86-video-intel".
driver=modesetting

# Acceleration method (corresponds to AccelMethod in the Xorg configuration).
# Only applies to the intel driver.
# Possible values : sna, xna, uxa
# Leave blank for the default (no option specified)
accel=

# Enable TearFree option in the Xorg configuration.
# Only applies to the intel driver.
# Possible values : yes, no
# Leave blank for the default (no option specified)
tearfree=

# DRI version. Possible values : 2, 3
DRI=3

# Whether or not to enable modesetting for the nouveau driver.
# Does not affect modesetting for the Intel GPU driver !
# This option only matters if you use nouveau as the switching backend.
modeset=yes

[nvidia]

# Whether or not to enable modesetting. Required for PRIME Synchronization (which prevents tearing).
modeset=yes

# Whether or not to enable the NVreg_UsePageAttributeTable option in the Nvidia driver.
# Recommended, can cause poor CPU performance otherwise.
PAT=yes

# DPI value. This will be set using the Xsetup script passed to your login manager.
# It will run the command
# xrandr --dpi <DPI>
# Leave blank for the default (the above command will not be run).
DPI=96

# If you're running an updated version of xorg-server (let's say to get PRIME Render offload enabled),
# the nvidia driver may not load because of an ABI version mismatch. Setting this flag to "yes"
# will allow the loading of the nvidia driver.
ignore_abi=no

# Set to yes if you want to use optimus-manager with external Nvidia GPUs (experimental)
allow_external_gpus=no

# Comma-separated list of Nvidia-specific options to apply.
# Available options :
# - overclocking : enable CoolBits in the Xorg configuration, which unlocks clocking options
#   in the Nvidia control panel. Note: does not work in hybrid mode.
# - triple_buffer : enable triple buffering.
options=overclocking"
