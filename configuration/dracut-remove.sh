#!/usr/bin/env bash

while read -r line; do
	if [[ "$line" == 'usr/lib/modules/'+([^/])'/pkgbase' ]]; then
		read -r pkgbase < "/${line}"
		rm -f "/boot/vmlinuz-${pkgbase}"
		rm -f "/boot/efi/EFI/Linux/archlinux.efi" "/boot/efi/EFI/Linux/archlinux-fallback.efi"
	fi
done
