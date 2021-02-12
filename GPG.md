## **Prepear installation :**
Before installation you must have SD card or Yubikey for saving gpg key.\
If you haven't gpg key, you can create key or using passphrase for encrypt you drive and for security.

### **GPG keys:**

#### **To view our public keys there is a command:**
```sh
gpg -k
```
`gpg --list-keys --keyid-format LONG` (Or we used this command for views keys.)

#### **In order to see the private keys there is a command:**
```sh
gpg -K
```
`gpg --list-secret-keys --keyid-format LONG`(Or we used this command for views keys.)

#### **For generation key you can to used:**
> Recomented key size is 4096 and you can used legal name.

```sh
gpg --full-generate-key
```
