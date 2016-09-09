#! /bin/bash
PASSWORD=logstash
NAME=soar.logstash.production.client
openssl req -x509 -config openssl.cnf -passout pass:$PASSWORD -newkey rsa:4096 -keyout $NAME.private.pem -out $NAME.cert.pem -days 365 -subj "/C=ZA/ST=Western Cape/L=Durbanville/O=Hetzner/CN=$NAME"
openssl rsa -passin pass:$PASSWORD -in $NAME.private.pem -out $NAME.private.nopass.pem
openssl x509 -noout -text -in $NAME.cert.pem
