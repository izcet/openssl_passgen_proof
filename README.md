## OpenSSL generates keys from passphrase insecurely with MD5

While trying to find a solution to 
[this](https://stackoverflow.com/questions/49228647/how-is-a-des-key-generated-from-passphrase-in-c)
problem, I found 
[this](https://security.stackexchange.com/questions/29106/openssl-recover-key-and-iv-by-passphrase)
answer.

### The Claim:
- OpenSSL generates `key` (and `iv`) by concatenating the user-input `password` 
with 8 bytes of random data `salt` and hashing them with `MD5`.
(`||` denotes concatenation, `[]` denotes optional params)
```
key[||iv] = MD5(password||salt)
```

### The Proof:
- I used `des` because the `key` and `iv` are both 8 bytes and fit neatly into the md5 hash.
- I perform the necessary string manipulations for the comparison with `grep` `cut` `sed` `xxd` `awk` 
and `echo` for output and string manipulation chaining.
