#!/bin/bash

# Configuration for the CSR
COUNTRY="HKG"
STATE="Hong Kong"
LOCALITY="TKO"
ORGANIZATION="HKEX"
ORGANIZATIONAL_UNIT="IT Department"
COMMON_NAME="your_domain.com" # This should be your server's hostname or domain name
EMAIL="admin@your_domain.com"

# Subject Alternative Names (SANs) - important for modern web servers
# Add any additional hostnames or IP addresses here
SAN_DNS_1="www.your_domain.com"
SAN_DNS_2="another.your_domain.com"
SAN_IP_1="192.168.1.100"

# Output file names
KEY_FILE="server.key"
CSR_FILE="server.csr"

# Key parameters
KEY_TYPE="p384" # Can be 'rsa', 'p256', or 'p384'
KEY_BITS=2048
DIGEST_ALGORITHM="sha256"

# Generate the private key based on the selected key type
if [ "$KEY_TYPE" = "rsa" ]; then
    openssl genrsa -out $KEY_FILE $KEY_BITS
elif [ "$KEY_TYPE" = "p256" ]; then
    openssl ecparam -name prime256v1 -genkey -noout -out $KEY_FILE
elif [ "$KEY_TYPE" = "p384" ]; then
    openssl ecparam -name secp384r1 -genkey -noout -out $KEY_FILE
else
    echo "Invalid KEY_TYPE specified. Please choose 'rsa', 'p256', or 'p384'."
    exit 1
fi

# Create the OpenSSL configuration file for the CSR
cat > openssl.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = $COUNTRY
ST = $STATE
L = $LOCALITY
O = $ORGANIZATION
OU = $ORGANIZATIONAL_UNIT
CN = $COMMON_NAME
emailAddress = $EMAIL

[v3_req]
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $COMMON_NAME
DNS.2 = $SAN_DNS_1
DNS.3 = $SAN_DNS_2
IP.1 = $SAN_IP_1
EOF

# Generate the CSR using the private key and the configuration file
openssl req -new -key $KEY_FILE -sha256 -out $CSR_FILE -config openssl.cnf

echo "CSR and private key generated:"
echo "Private Key: $KEY_FILE"
echo "CSR: $CSR_FILE"

# Clean up the temporary OpenSSL configuration file
rm openssl.cnf



