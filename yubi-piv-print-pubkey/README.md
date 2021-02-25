# yubi-piv-print-pubkey

prints the pubkey of the attached PKCS#11 token -- for example a yubikey in PIV mode

This script is just a wrapper around `ssh-keygen -D "$pkcslib"` that tries some common locations for `$pkcslib`.
