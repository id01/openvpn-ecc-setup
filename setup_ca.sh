#!/bin/bash

CURVE=secp521r1

# Generate CA ECC key and certificate (lasting 10 years)
mkdir ca
openssl ecparam -out ca.key -name $CURVE -genkey
openssl req -new -key ca.key -x509 -nodes -days 3650 -out ca.crt
mv ca.key ca
mv ca.crt ca

# Create other CA folders
mkdir ca/ca.db.certs
touch ca/ca.db.index
echo "0000000000000000" > ca/ca.db.serial

# Create key directory
mkdir keys

generateEllipticCert() {
	openssl ecparam -genkey -name $CURVE -out "keys/$1.key"
	openssl req -new -sha256 -key "keys/$1.key" -out "keys/$1.csr" # Certificate signing request (will be deleted later)
	if [ "$2" == "" ]; then
		openssl ca -config ca.conf -out "keys/$1.crt" -infiles "keys/$1.csr" # Regular client cert
	else
		openssl ca -config ca.conf -extensions "$2" -out "keys/$1.crt" -infiles "keys/$1.csr" # $2 is server_cert if this is a server cert
	fi
	rm "keys/$1.csr"
}

# Generate Server ECC key and certificate (lasting 10 years)
generateEllipticCert server server_cert

# Generate Client ECC key and certificate
generateEllipticCert client1

# Generate Server OVPN file and Client OVPN file
(cat server_template.ovpn; echo "<ca>"; cat ca/ca.crt; echo -e "</ca>\n<cert>"; cat keys/server.crt; echo -e "</cert>\n<key>"; cat keys/server.key; echo "</key>") > server.conf
(cat client_template.ovpn; echo "<ca>"; cat ca/ca.crt; echo -e "</ca>\n<cert>"; cat keys/client1.crt; echo -e "</cert>\n<key>"; cat keys/client1.key; echo "</key>") > client1.ovpn
