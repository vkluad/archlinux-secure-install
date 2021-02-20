#!/bin/bashs
sudo clevis luks bind -k / -d /dev/sda2  tpm2 '{"pcr_ids":"1,7"}'
sudo clevis luks bind -k / -d /dev/nvme0n1p2  tpm2 '{"pcr_ids":"1,7"}'

sudo dracut -f

echo "Please after instalation run 'dracut -f' in sda or nvme loader"
