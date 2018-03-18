#!/bin/bash

# This script aims to prove that OpenSSL's password generation (at the very least for DES)
# is as follows
#
#     MD5(password||salt)
#
# as said in https://security.stackexchange.com/questions/29106/openssl-recover-key-and-iv-by-passphrase

PASSWORD="password"
SSL_OUT=openssl_command_output

openssl des -P -pass pass:$PASSWORD > $SSL_OUT

echo -e "\nOPENSSL OUTPUT:"
cat $SSL_OUT


SSL_SALT=$( cat $SSL_OUT | grep "^salt=" | cut -c6- )
SSL_KEY=$(cat $SSL_OUT | grep "^key=" | cut -c5- )
SSL_IV=$(cat $SSL_OUT | grep "^iv =" | cut -c5- )

HEX_SALT=$( echo $SSL_SALT | sed -E 's/(..)/0x\1 /g' )
RAW_SALT=$( echo $HEX_SALT | xxd -r )

#echo -e $SSL_SALT $HEX_SALT $RAW_SALT
#echo -e ""


MD5=$( md5 -q -s "$PASSWORD$RAW_SALT" | awk '{print toupper($0)}' )


echo -e "\nMD5 of $PASSWORD concatenated with the raw value of $HEX_SALT:\n$MD5"

echo -e "\nLook for yourself:"

MD5_SPLIT=$( echo $MD5 | sed -E 's/(.{16})/\1  /' )

NEW_KEY=$( echo $MD5_SPLIT | cut -d' ' -f1 )
NEW_IV=$( echo $MD5_SPLIT | cut -d' ' -f2 )

echo -e "SSL key: $SSL_KEY\nNEW key: $NEW_KEY\n"
echo -e "SSL iv: $SSL_IV\nNEW iv: $NEW_IV\n"
