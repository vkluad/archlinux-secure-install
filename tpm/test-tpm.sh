#! /bin/bash

test -c /dev/tpm0 && echo OK || echo FAIL
test -d /sys/firmware/efi && echo OK || echo FAIL
sudo -i
echo 'Fedora encryption test' | clevis encrypt tpm2 '{}' > test.jwe
cat test.jwe | clevis decrypt tpm2

echo "If you don't have FAIL and you see 'Fedora encryption test', then all Okay"
