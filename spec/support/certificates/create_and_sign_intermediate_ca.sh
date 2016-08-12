#! /bin/bash

#gleaned from
#https://jamielinux.com/docs/openssl-certificate-authority/create-the-intermediate-pair.html

cd ca/intermediate

rm -rf certs crl csr newcerts private
rm -f serial* crlnumber index*
mkdir -p certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

#Create the intermediate key
openssl genrsa -passout pass:testing -aes256 -out private/intermediate.ca.key.pem 4096
chmod 400 private/intermediate.ca.key.pem

#Create the intermediate certificate
#-passin pass:testing \
openssl req -config openssl.cnf -new -sha256 \
      -passin pass:testing \
      -key private/intermediate.ca.key.pem \
      -subj "/C=ZA/ST=Western Cape/L=Durbanville/O=Hetzner/CN=soar.architecture.testing.intermediate.ca" \
      -out csr/intermediate.ca.csr.pem
chmod 444 csr/intermediate.ca.csr.pem

#verify intermediate certificate
openssl x509 -noout -text -in csr/intermediate.ca.csr.pem

#sign the intermediate certificate with the root certificate
cd ../
openssl ca -batch -config openssl.cnf -extensions v3_intermediate_ca \
      -passin pass:testing \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.ca.csr.pem \
      -out intermediate/certs/intermediate.ca.cert.pem

#verify the signed intermediate certificate
openssl x509 -noout -text -in intermediate/certs/intermediate.ca.cert.pem

cd ../
