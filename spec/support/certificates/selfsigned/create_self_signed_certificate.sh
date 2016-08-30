#! /bin/bash
PASSWORD=logstash
openssl req -x509 -config openssl.cnf -passout pass:$PASSWORD -newkey rsa:4096 -keyout selfsigned_registered.private.pem   -out selfsigned_registered.cert.pem   -days 365 -subj "/C=ZA/ST=Western Cape/L=Durbanville/O=Hetzner/CN=soar.architecture.testing.client_registered"
openssl req -x509 -config openssl.cnf -passout pass:$PASSWORD -newkey rsa:4096 -keyout selfsigned_unregistered.private.pem -out selfsigned_unregistered.cert.pem -days 365 -subj "/C=ZA/ST=Western Cape/L=Durbanville/O=Hetzner/CN=soar.architecture.testing.client_unregistered"

openssl rsa -passin pass:$PASSWORD -in selfsigned_registered.private.pem   -out selfsigned_registered.private.nopass.pem
openssl rsa -passin pass:$PASSWORD -in selfsigned_unregistered.private.pem -out selfsigned_unregistered.private.nopass.pem

#curl -iv -E ./selfsigned_registered.cert.pem --key ./selfsigned_registered.private.nopass.pem https://localhost:8081 -d "message=soar_sc_logstash_test" --insecure
#curl -iv -E ./selfsigned_unregistered.cert.pem --key ./selfsigned_unregistered.private.nopass.pem https://localhost:8081 -d "message=soar_sc_logstash_test" --insecur
