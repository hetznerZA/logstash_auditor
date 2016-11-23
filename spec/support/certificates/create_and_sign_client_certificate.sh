#! /bin/bash

#gleaned from
#https://jamielinux.com/docs/openssl-certificate-authority/create-the-intermediate-pair.html

NAME=$1
PASSWORD=logstash
mkdir -p client
cd client

#create client private key
openssl genrsa -passout pass:$PASSWORD -aes256 -out $NAME.private.pem 4096
# chmod 400 $NAME.private.pem

#Create signing request
openssl req -batch -config ../intermediate_ca/openssl.cnf \
      -passin pass:$PASSWORD \
      -key $NAME.private.pem \
      -subj "/C=ZA/ST=Western Cape/L=Durbanville/O=Hetzner/CN=$NAME" \
      -new -sha256 -out $NAME.csr.pem

#Sign with intermediate ca
cd ../intermediate_ca
openssl ca -batch -config openssl.cnf \
      -passin pass:$PASSWORD \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in ../client/$NAME.csr.pem \
      -out ../client/$NAME.cert.pem
# chmod 444 ../client/$NAME.cert.pem

#Verify the certificate
cd ../client
openssl x509 -noout -text -in $NAME.cert.pem

#convert certificate and private key to pkcs12 for use in Java keystore
#note that the certificate trust chain is also included.
echo Converting to pkcs12
openssl pkcs12 -export -passin pass:$PASSWORD -passout pass:$PASSWORD -inkey $NAME.private.pem -certfile ../intermediate_ca/certs/ca-chain.cert.pem -in $NAME.cert.pem -out $NAME.cert.pkcs12

#Create copy of private key that is decrypted
openssl rsa -passin pass:$PASSWORD -in $NAME.private.pem -out $NAME.private.nopass.pem

cd ..
