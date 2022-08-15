#!/bin/sh

if [ ! -d /certs/database ]; then
	echo "/certs/database not found, creating"
	mkdir -p /certs/database
fi

if [ ! -d /certs/service ]; then
	echo "/certs/service not found, creating"
	mkdir -p /certs/service
fi

echo "===== Finding Service Certificate ====="
CERT_DOMAIN="${DOMAIN}"
while [ -n "${CERT_DOMAIN}" ]; do
	if [ ! -d "/certs-service/live/${CERT_DOMAIN}" ] && [ ! -d "/certs-service/live/${CERT_DOMAIN}_ecc" ]; then
		echo "Failed to find Service Certificate for \"${CERT_DOMAIN}\""
		CERT_DOMAIN="${CERT_DOMAIN#*.}"
	else
		echo "Found Service Certificate for \"${CERT_DOMAIN}\""
		break
	fi
done

if [ -z "${CERT_DOMAIN}" ]; then
	echo "Failed to find Service Certificate for \"${CERT_DOMAIN}\""
	exit 1
fi

if [ -d "/certs-sercice/live/${CERT_DOMAIN}_ecc" ]; then
	CERT_PATH="/certs-service/live/${CERT_DOMAIN}_ecc"
else
	CERT_PATH="/certs-service/live/${CERT_DOMAIN}"
fi

echo "Found Service Certificates in ${CERT_DOMAIN}"

echo "===== Generating Certificates ====="
if [ ! -f /keys/ca.crt ] || [ ! -f /keys/ca.key ]; then
	echo "Failed to find CA Certificate and Key"
	echo "Regenerating CA Certificate and Key"

	rm -v /keys/ca*
	cockroach cert create-ca --certs-dir=/keys --ca-key=/keys/ca.key

	echo "Removing Node and Client Certificates since CA Certificate is Regenerated"
	rm -v /keys/node* /keys/client*
else
	echo "Found CA Certificates and Key"
fi

if [ ! -f /keys/node.crt ] || [ ! -f /keys/node.key ]; then
	echo "Failed to find Node Certificate and Key"
	echo "Regenerating Node Certificate and Key"

	rm -v /keys/node*
	cockroach cert create-node --certs-dir=/keys --ca-key=/keys/ca.key database "${DOMAIN}"
else
	echo "Found Node Certificate and Key"
fi

if [ ! -f /keys/client.root.crt ] || [ ! -f /keys/client.root.key ]; then
	echo "Failed to find Client Certificate and Key for root"
	echo "Regenerating Client Certificate and Key for root"

	rm -v /keys/client.root*
	cockroach cert create-client --certs-dir=/keys --ca-key=/keys/ca.key root
else
	echo "Found Client Certificate and Key for root"
fi

if [ ! -f /keys/client.zitadel.crt ] || [ ! -f /keys/client.zitadel.key ]; then
	echo "Failed to find Client Certificate and Key for zitadel"
	echo "Regenerating Client Certificate and Key for zitadel"

	rm -v /keys/client.zitadel*
	cockroach cert create-client --certs-dir=/keys --ca-key=/keys/ca.key zitadel
else
	echo "Found Client Certificate and Key for zitadel"
fi

echo "===== Checking Certificates ====="
cockroach cert list --certs-dir=/keys

echo "===== Copying Certificates ====="
cp -v /keys/ca.crt   /certs-database/
cp -v /keys/node.crt /certs-database/
cp -v /keys/node.key /certs-database/

cp -v /keys/ca.crt          /certs/database/
cp -v /keys/client.root.crt /certs/database/
cp -v /keys/client.root.key /certs/database/

cp -v "${CERT_PATH}/fullchain.pem" /certs/service/
cp -v "${CERT_PATH}/privkey.pem"   /certs/service/

echo "===== Changing Certificate Permission ====="
chown 1000:1000 /certs/* -R
