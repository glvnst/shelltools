#!/bin/sh

yubi_piv_print_pubkey() {
  for pkcslib in \
    /Library/OpenSC/lib/opensc-pkcs11.so \
    /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so \
    /usr/lib/x86-linux-gnu/opensc-pkcs11.so \
    /usr/lib64/pkcs11/opensc-pkcs11.so \
    /usr/local/lib/opensc-pkcs11.so \
    /usr/local/opt/opensc/lib/pkcs11/opensc-pkcs11.so \
    /usr/local/lib/libykcs11.dylib \
    "${PKCS11_LIBRARY:-opensc-pkcs11.so}" \
  ; do
    if [ -f "$pkcslib" ]; then
      # echo "$pkcslib"
      ssh-keygen -D "$pkcslib" "$@"
      return
    fi
  done

  printf 'FATAL: Unable to locate pkcs11 library\n' >&2
  false
}

main() {
  yubi_piv_print_pubkey "$@"
  exit
}

[ -n "$IMPORT" ] || main "$@"
