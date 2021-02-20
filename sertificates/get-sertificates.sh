#!/bin/bash
echo "This script generated seritficates in your current folder"
echo "If you chose other folder please press Ctrl-C and go to the other folder"
echo "Otherwise press Enter"
read

echo -n "Enter a Common Name to embed in the keys: "
read NAME

GUID="$(python -c 'import uuid; print(str(uuid.uuid1()))')"
echo $GUID > myGUID.txt

# PK
openssl req -newkey rsa:4096 -nodes -keyout PK.key -new -x509 -sha256 -days 3650 -subj "/CN=$NAME Platform key/" -out PK.crt
openssl x509 -outform DER -in PK.crt -out PK.cer
cert-to-efi-sig-list -g $GUID PK.crt PK.esl
sign-efi-sig-list -g $GUID -k PK.key -c PK.crt PK PK.esl PK.auth

sign-efi-sig-list -g $GUID -c PK.crt -k PK.key PK /dev/null rm_PK.auth
# end PK

#KEK
openssl req -newkey rsa:4096 -nodes -keyout KEK.key -new -x509 -sha256 -days 3650 -subj "/CN=$NAME Key Exchange Key/" -out KEK.crt
openssl x509 -outform DER -in KEK.crt -out KEK.cer
cert-to-efi-sig-list -g $GUID KEK.crt KEK.esl
sign-efi-sig-list -g $GUID -k PK.key -c PK.crt KEK KEK.esl KEK.auth
#end KEK

#DB
openssl req -newkey rsa:4096 -nodes -keyout db.key -new -x509 -sha256 -days 3650 -subj "/CN=$NAME Signature Database/" -out db.crt
openssl x509 -outform DER -in db.crt -out db.cer
cert-to-efi-sig-list -g $GUID db.crt db.esl
sign-efi-sig-list -g $GUID -k KEK.key -c KEK.crt db db.esl db.auth
#end DB

chmod 0600 *.key
