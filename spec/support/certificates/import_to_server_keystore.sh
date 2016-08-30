#! /bin/bash

PASSWORD=logstash

rm -f serverkeystore.jks
keytool -import -noprompt -storepass $PASSWORD -keystore serverkeystore.jks -file root_ca/certs/root.ca.cert.pem                 -alias root_ca
keytool -import -noprompt -storepass $PASSWORD -keystore serverkeystore.jks -file intermediate_ca/certs/intermediate.ca.cert.pem -alias intermediate_ca
keytool -import -noprompt -storepass $PASSWORD -keystore serverkeystore.jks -file selfsigned/selfsigned.cert.pem                 -alias logstash_client_manual
keytool -import -noprompt -storepass $PASSWORD -keystore serverkeystore.jks -file selfsigned/selfsigned_registered.cert.pem      -alias logstash_client_registered

#Generate and import selfsigned server keypair
keytool -genkey -keyalg RSA -alias logstash_server -storepass $PASSWORD -keypass $PASSWORD -keystore serverkeystore.jks -validity 365 -keysize 4096 -dname "CN=localhost, OU=Hetzner, O=Hetzner, L=Durbanville, S=Western Cape , C=ZA"


keytool -list -storepass $PASSWORD -keystore serverkeystore.jks
