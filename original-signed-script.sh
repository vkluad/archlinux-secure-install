#!/bin/bash

for F in $(find /boot -name "vmlinuz-*")
do
	F=$(echo $F | sed 's/^\///') # Remove '/' in beginning of path
	FILE=$(echo $F | sed 's/boot\///')
	BOOTDIR=/boot
	CERTDIR=/root/keys
	KERNEL=$F
	INITRAMFS="/boot/intel-ucode.img /boot/initramfs-$(echo $FILE | sed 's/vmlinuz-//').img"
	EFISTUB=/usr/lib/systemd/boot/efi/linuxx64.efi.stub
	BUILDDIR=/boot/_build_EFISTUB
	OUTIMG=/boot/EFI/Linux/Archlinux.efi
	CMDLINE=/etc/cmdline

	mkdir -p $BUILDDIR

	cat ${INITRAMFS} > ${BUILDDIR}/initramfs.img

	/usr/bin/objcopy \
		--add-section .osrel=/etc/os-release --change-section-vma .osrel=0x20000 \
		--add-section .cmdline=${CMDLINE} --change-section-vma .cmdline=0x30000 \
		--add-section .linux=${KERNEL} --change-section-vma .linux=0x40000 \
		--add-section .initrd=${BUILDDIR}/initramfs.img --change-section-vma .initrd=0x3000000 \
		${EFISTUB} ${BUILDDIR}/combined-boot.efi

	/usr/bin/sbsign --key ${CERTDIR}/DB.key --cert ${CERTDIR}/DB.crt --output ${BUILDDIR}/combined-boot-signed.efi ${BUILDDIR}/combined-boot.efi

	cp ${BUILDDIR}/combined-boot-signed.efi ${OUTIMG}

done
