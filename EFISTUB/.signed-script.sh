#!/bin/bash
# sudo dracut -f
BOOTDIR=/boot
CERTDIR=/root/keys # must edit
KERNEL=/boot/vmlinuz-linux
# INITRAMFS="/boot/intel-ucode.img /boot/initramfs-linux.img"
EFISTUB=/usr/lib/systemd/boot/efi/linuxx64.efi.stub
BUILDDIR=/boot/_build_EFISTUB
OUTEFI=/boot/efi/EFI/Linux/Archlinux.efi
BMPIMG=/usr/share/systemd/bootctl/splash-arch.bmp
CMDLINE=$(cat /boot/cmdline)
#
# mkdir -p $BUILDDIR
#
# cat ${INITRAMFS} > ${BUILDDIR}/initramfs.img
#
# /usr/bin/objcopy \
# 	--add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
# 	--add-section .cmdline=${CMDLINE} --change-section-vma .cmdline=0x30000 \
#   --add-section .splash="/usr/share/systemd/bootctl/splash-arch.bmp" --change-section-vma .splash=0x40000 \
# 	--add-section .linux=${KERNEL} --change-section-vma .linux=0x2000000 \
# 	--add-section .initrd=${BUILDDIR}/initramfs.img --change-section-vma .initrd=0x3000000 \
# 	${EFISTUB} ${BUILDDIR}/Archlinux-nosigned.efi

dracut -H --uefi --uefi-stub ${EFISTUB}	--uefi-splash-image ${BMPIMG}	--kernel-image ${KERNEL} --kernel-cmdline ${CMDLINE}\
-o "brltty lvm qemu nvmf nfs iscsi busybox dash mksh bootchart terminfo usrmount kernel-network-modules rngd network-legacy network-wicked network dmraid biosdevname memstrack tpm2-totp clevis-pin-tang"

/usr/bin/sbsign --key ${CERTDIR}/DB.key --cert ${CERTDIR}/DB.crt --output ${BUILDDIR}/Archlinux-signed.efi ${BUILDDIR}/Archlinux-nosigned.efi

cp ${BUILDDIR}/Archlinux-signed.efi ${OUTEFI}
