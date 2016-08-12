#! /bin/bash

#gleaned from
#https://jamielinux.com/docs/openssl-certificate-authority/create-the-intermediate-pair.html

NAME=architecture.test.client

rm -rf client
mkdir -p client
cd client

#create client private key
openssl genrsa -passout pass:testing -aes256 -out $NAME.private.pem 4096
chmod 400 $NAME.private.pem

#Create signing request
openssl req -batch -config ../ca/intermediate/openssl.cnf \
      -passin pass:testing \
      -key $NAME.private.pem \
      -subj "/C=ZA/ST=Western Cape/L=Durbanville/O=Hetzner/CN=$NAME" \
      -new -sha256 -out $NAME.csr.pem

#Sign with intermediate ca
cd ..
openssl ca -batch -config ca/intermediate/openssl.cnf \
      -passin pass:testing \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in client/$NAME.csr.pem \
      -out client/$NAME.cert.pem
 chmod 444 client/$NAME.cert.pem

#Verify the certificate
cd client
openssl x509 -noout -text -in $NAME.cert.pem

cd ..
