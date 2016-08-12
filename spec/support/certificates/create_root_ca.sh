#! /bin/bash
cd ca

rm -rf certs crl newcerts private
rm -f serial* crlnumber index*
mkdir -p certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

#Create the root key
openssl genrsa -passout pass:testing -aes256 -out private/root.ca.key.pem 4096
chmod 400 private/root.ca.key.pem

#Create the root certificate
openssl req -config openssl.cnf \
      -passin pass:testing \
      -key private/root.ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -subj "/C=ZA/ST=Western Cape/L=Durbanville/O=Hetzner/CN=soar.architecture.testing.root.ca" \
      -out certs/root.ca.cert.pem
chmod 444 certs/root.ca.cert.pem

#verify root certificate
openssl x509 -noout -text -in certs/root.ca.cert.pem

cd ..
