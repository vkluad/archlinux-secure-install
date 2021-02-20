#!/usr/bin/env bash

args=('--force' '--no-hostonly-cmdline')
while read -r line; do
	if [[ "$line" == 'usr/lib/modules/'+([^/])'/pkgbase' ]]; then
		read -r pkgbase < "/${line}"
		kver="${line#'usr/lib/modules/'}"
		kver="${kver%'/pkgbase'}"

		install -Dm0644 "/${line%'/pkgbase'}/vmlinuz" "/boot/vmlinuz-${pkgbase}"
		dracut "${args[@]}"  --hostonly "/boot/efi/EFI/Linux/archlinux.efi" --kver "$kver"
		dracut "${args[@]}" --no-hostonly "/boot/efi/EFI/Linux/archlinux-fallback.efi" --kver "$kver"
	fi
done
