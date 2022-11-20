#!/bin/bash
PROJ_DIR=./wabinar
VAULT_KEY_FILE=./vault-secrets/keys

source ${VAULT_KEY_FILE}

pm2 kill

# install project and package
cd ${PROJ_DIR}
git pull
npm ci

#
# server
#

echo "For server..."
cd server

# fetch environment variables for server
npx dotenv-vault login ${VAULT_CLIENT_KEY} > /dev/null
npx dotenv-vault pull production .env
cp .env dist/server/

# build server
npm run build

# turn on server
cd dist/server
pm2 start index.js --name=server --time

#
# client
#

echo "For client..."
cd ../../../client

# fetch environment variables for client
npx dotenv-vault login ${VAULT_SERVER_KEY} > /dev/null
npx dotenv-vault pull production .env

# build client server
npm run build

# serve static files
authbind --deep pm2 serve dist 80 --spa --name=client --time
