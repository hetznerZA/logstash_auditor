#! /bin/bash

#gleaned from
#https://jamielinux.com/docs/openssl-certificate-authority/create-the-intermediate-pair.html

PASSWORD=logstash

cd intermediate_ca

rm -rf certs crl csr newcerts private
rm -f serial* crlnumber index*
mkdir -p certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

#Create the intermediate key
openssl genrsa -passout pass:$PASSWORD -aes256 -out private/intermediate.ca.key.pem 4096
chmod 400 private/intermediate.ca.key.pem

#Create the intermediate certificate
#-passin pass:testing \
openssl req -config openssl.cnf -new -sha256 \
      -passin pass:$PASSWORD \
      -key private/intermediate.ca.key.pem \
      -subj "/C=ZA/ST=Western Cape/L=Durbanville/O=Hetzner/CN=soar.architecture.testing.intermediate.ca" \
      -out csr/intermediate.ca.csr.pem
chmod 444 csr/intermediate.ca.csr.pem

#verify intermediate certificate
openssl x509 -noout -text -in csr/intermediate.ca.csr.pem

#sign the intermediate certificate with the root certificate
cd ../root_ca
openssl ca -batch -config openssl.cnf -extensions v3_intermediate_ca \
      -passin pass:$PASSWORD \
      -days 3650 -notext -md sha256 \
      -in ../intermediate_ca/csr/intermediate.ca.csr.pem \
      -out ../intermediate_ca/certs/intermediate.ca.cert.pem

#verify the signed intermediate certificate
cd ../intermediate_ca
openssl x509 -noout -text -in certs/intermediate.ca.cert.pem

#create certificate chain file
cat certs/intermediate.ca.cert.pem \
      ../root_ca/certs/root.ca.cert.pem > certs/ca-chain.cert.pem
chmod 444 certs/ca-chain.cert.pem

#Covert to pkcs12 for use in java keystore
echo Converting to pkcs12
#openssl pkcs12 -export -passin pass:$PASSWORD -passout pass:$PASSWORD -nokeys -inkey private/intermediate.ca.key.pem  -in certs/intermediate.ca.cert.pem -cacerts -certfile certs/ca-chain.cert.pem -out certs/intermediate.ca.cert.pkcs12
cd ../
