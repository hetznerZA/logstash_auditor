#! /bin/bash

BASE_FOLDER=$(pwd)

#create the self signed client certificates that we will use to authenticate ourselves
#with the ELK stack
cd $BASE_FOLDER/spec/support/certificates/selfsigned
./create_self_signed_certificate.sh

#import the certificates to the keystore
cd $BASE_FOLDER/spec/support/certificates
./import_to_server_keystore.sh

cd $BASE_FOLDER
