#!/bin/bash

for F in $(find /boot -name "vmlinuz-*")
do
	F=$(echo $F | sed 's/^\///') # Remove '/' in beginning of path
	FILE=$(echo $F | sed 's/boot\///')
	BOOTDIR=/boot
	CERTDIR=/root/keys # must edit
	KERNEL=$F
	INITRAMFS="/boot/intel-ucode.img /boot/initramfs-$(echo $FILE | sed 's/vmlinuz-//').img"
	EFISTUB=/usr/lib/systemd/boot/efi/linuxx64.efi.stub
	BUILDDIR=/boot/_build_EFISTUB
	# OUTIMG=/boot/esp/$(echo $FILE | sed 's/vmlinuz-//').img
  OUTEFI=/boot/efi/EFI/Linux/Archlinux.efi
	CMDLINE=${BUILDDIR}/cmdline

	mkdir -p $BUILDDIR

	cat ${INITRAMFS} > ${BUILDDIR}/initramfs.img

	/usr/bin/objcopy \
		--add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
		--add-section .cmdline=${CMDLINE} --change-section-vma .cmdline=0x30000 \
    --add-section .splash="/usr/share/systemd/bootctl/splash-arch.bmp" --change-section-vma .splash=0x40000 \
		--add-section .linux=${KERNEL} --change-section-vma .linux=0x2000000 \
		--add-section .initrd=${BUILDDIR}/initramfs.img --change-section-vma .initrd=0x3000000 \
		${EFISTUB} ${BUILDDIR}/Archlinux-nosigned.efi

	/usr/bin/sbsign --key ${CERTDIR}/DB.key --cert ${CERTDIR}/DB.crt --output ${BUILDDIR}/Archlinux-signed.efi ${BUILDDIR}/Archlinux-nosigned.efi

	cp ${BUILDDIR}/Archlinux-signed.efi ${OUTEFI}

done
