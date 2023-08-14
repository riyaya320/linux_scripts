#!/bin/bash

mkdir sysA
mkdir sysB

openssl genpkey -algorithm RSA -out a_private.pem
openssl rsa -pubout -in a_private.pem -out a_public.pem
openssl genpkey -algorithm RSA -out b_private.pem
openssl rsa -pubout -in b_private.pem -out b_public.pem

dataA="Hello I'm sysA"
dataB="Hello I'm sysB"
symmetrickeys="kali"

echo "$dataA" > plaintextA.txt
echo "$dataB" > plaintextB.txt

echo "$symmetrickeys" > symmetric_key.txt

openssl enc -aes-256-cbc -salt -in plaintextA.txt -out encA.enc -pass file:symmetric_key.txt
openssl enc -aes-256-cbc -salt -in plaintextB.txt -out encB.enc -pass file:symmetric_key.txt

cp b_public.pem sysA/
cp a_public.pem sysB/

openssl dgst -sha256 -sign a_private.pem -out signA.sha plaintextA.txt
openssl dgst -sha256 -sign b_private.pem -out signB.sha plaintextB.txt

openssl enc -aes-256-cbc -d -in encB.enc -out decryptB.txt -pass file:symmetric_key.txt
openssl dgst -sha256 -verify b_public.pem -signature signB.sha plaintextB.txt

openssl enc -aes-256-cbc -d -in encA.enc -out decryptA.txt -pass file:symmetric_key.txt
openssl dgst -sha256 -verify a_public.pem -signature signA.sha plaintextA.txt

echo "Decrypted data from A: $(cat decryptA.txt)"
echo "Decrypted data from B: $(cat decryptB.txt)"

