#!/bin/bash

# This script aims to prove that OpenSSL's password generation (at the very least for DES)
# is as follows
#
#     MD5(password||salt)
#
# as said in https://security.stackexchange.com/questions/29106/openssl-recover-key-and-iv-by-passphrase

PASSWORD="password"
SSL_OUT=openssl_command_output

function get_raw () {
	echo "$( echo -n "$1" | sed -E 's/(..)/0x\1 /g' | xxd -r )"
}

openssl des3 -P -pass pass:$PASSWORD > $SSL_OUT

echo -e "\nOPENSSL OUTPUT:"
cat $SSL_OUT

SSL_SALT=$( cat $SSL_OUT | grep "^salt=" | cut -c6- )
SSL_KEY=$( cat $SSL_OUT | grep "^key=" | cut -c5- | sed -E 's/(.{16})/\1 /g' )
SSL_IV=$( cat $SSL_OUT | grep "^iv =" | cut -c5- )

RAW_SALT="$( get_raw $SSL_SALT )"

MD5_OUT=$( md5 -q -s "$PASSWORD$RAW_SALT" ) 
MD5=$( echo $MD5_OUT | awk '{print toupper($0)}' )

NEXT=$(md5 -q -s "$( get_raw "$( echo "$MD5_OUT" )" )$PASSWORD$RAW_SALT" | awk '{print toupper($0)}' )

echo -e "\nIteration 0: $MD5"
echo -e "Iteration 1: $NEXT"

TOTAL=$( echo "$MD5$NEXT" | sed -E 's/(.{16})/\1 /g' )

echo -e "\nLook for yourself:"

NEW_KEY=$( echo $TOTAL | cut -d' ' -f1-3 )
NEW_IV=$( echo $TOTAL | cut -d' ' -f4 )

echo -e "SSL key: $SSL_KEY\nNEW key: $NEW_KEY\n"
echo -e "SSL iv: $SSL_IV\nNEW iv: $NEW_IV\n"

# There's a bug where sometimes a byte gets dropped somewhere.
# as a proof of concept this works the majority of the time, 
# but I haven't been able to narrow down the source of the problem
#
# Uncomment this line to test for yourself and see the output differ
#echo -e "$(echo "$( get_raw "$( echo "$MD5_OUT" )" )$PASSWORD$RAW_SALT" | wc -c )\n"
