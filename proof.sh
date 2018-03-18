#!/bin/bash

# This script aims to prove that OpenSSL's password generation (at the very least for DES)
# is as follows
#
#     MD5(password||salt)
#
# as said in https://security.stackexchange.com/questions/29106/openssl-recover-key-and-iv-by-passphrase

PASSWORD="password"
SSL_OUT=openssl_command_output

echo ""

openssl des -P -pass pass:$PASSWORD > $SSL_OUT

cat $SSL_OUT

echo ""

SSL_SALT=$( cat $SSL_OUT | grep "^salt=" | cut -c6- )
HEX_SALT=$( echo $SSL_SALT | sed -E 's/(..)/0x\1 /g' )
RAW_SALT=$( echo $HEX_SALT | xxd -r )

echo $SSL_SALT $HEX_SALT $RAW_SALT

echo ""

MD5=$( md5 -q -s "$PASSWORD$RAW_SALT" )

echo $MD5
