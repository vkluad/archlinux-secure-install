#!/bin/bash

dracut --uefi --uefi-stub /usr/lib/systemd/boot/efi/linuxx64.efi.stub \
--uefi-splash-image /usr/share/systemd/bootctl/splash-arch.bmp \
--kernel-image /boot/vmlinuz-linux -f \
--kernel-cmdline "root=UUID=86f74b2d-b214-4cde-854e-7f8cb32c2bbe rootfstype=btrfs rootflags=subvol=@
 quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0"\
  -o "brltty lvm qemu nvmf nfs iscsi busybox dash mksh bootchart terminfo usrmount kernel-network-modules
  rngd network-legacy network-wicked network dmraid biosdevname memstrack tpm2-totp
  clevis-pin-tang"
