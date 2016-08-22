#! /bin/bash

rm -f serverkeystore.jks
keytool -import -noprompt -storepass logstash -keystore serverkeystore.jks -file root_ca/certs/root.ca.cert.pem -alias root_ca
keytool -import -noprompt -storepass logstash -keystore serverkeystore.jks -file intermediate_ca/certs/intermediate.ca.cert.pem -alias intermediate_ca
keytool -import -noprompt -storepass logstash -keystore serverkeystore.jks -file client/server.cert.pem -alias logstash_server
keytool -list -storepass logstash -keystore serverkeystore.jks
