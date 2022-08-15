#!/bin/bash
if [ -f .env ]; then
	source .env
fi

if [ ! -f templates/config.yaml ]; then
	echo "Failed to find templates/config.yaml, exitting"
	exit 1
fi

if [ ! -f templates/00-init-zitadel.sql ]; then
	echo "Failed to find templates/00-init-zitadel.sql, exitting"
	exit 2
fi

if [ ! -d config ]; then
	mkdir config
	echo "config not found, creating"
fi

if [ ! -d config/zitadel ]; then
	mkdir config/zitadel
	echo "config/zitadel not found, creating"
fi
	
if [ -z $DATABASE_PASSWORD ]; then
	# Create 32 character key
	DATABASE_PASSWORD="$(openssl rand -base64 24)"
fi

if [ ! -f config/zitadel/config.yaml ]; then
	cp templates/config.yaml config/zitadel/config.yaml

	sed -i "s/$${DATABASE_PASSWORD}/${DATABASE_PASSWORD}/g" config/zitadel/config.yaml
	sed -i "s/$${DOMAIN}/${DOMAIN}/g"                       config/zitadel/config.yaml

	echo "Created config/zitadel/config.yaml from templates/config.yaml"
else
	echo "config/zitadel/confing.yaml exists, skipping bootstrap"
fi

if [ ! -d scripts ]; then
	mkdir scripts
	echo "scripts not found, creating"
fi

if [ ! -d scripts/database ]; then
	mkdir scripts/database
	echo "scripts/database not found, creating"
fi

if [ ! -f scripts/database/00-init-zitadel.sql ]; then
	cp templates/00-init-zitadel.sql scripts/database/00-init-zitadel.sql

	sed -i "s/$${DATABASE_PASSWORD}/${DATABASE_PASSWORD}/g" scripts/database/00-init-zitadel.sql
	
	echo "Created scripts/database/00-init-zitadel.sql from templates/00-init-zitadel.sql"
else
	echo "scripts/database/00-init-zitadel.sql"
fi
