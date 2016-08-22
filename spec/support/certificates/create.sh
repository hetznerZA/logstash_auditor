#! /bin/bash

./create_root_ca.sh
./create_and_sign_intermediate_ca.sh
./create_and_sign_client_certificate.sh client
./create_and_sign_client_certificate.sh server
./import_to_server_keystore.sh
