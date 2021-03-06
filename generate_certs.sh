#!/bin/bash

pushd /etc/openvpn/

rm -r easy-rsa
mkdir easy-rsa
cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0/* easy-rsa/
sed -i -e 's/export KEY_COUNTRY=.*/export KEY_COUNTRY="RU"/
s/export KEY_PROVINCE=.*/export KEY_PROVINCE="SP"/
s/export KEY_CITY=.*/export KEY_CITY="St.Petersburg"/
s/export KEY_ORG=.*/export KEY_ORG="Nevskiy Prostor"/
s/export KEY_CN=.*/export KEY_CN="server"/
s/export KEY_OU=.*/export KEY_OU="central"/
s/export KEY_NAME=.*/export KEY_NAME="Nevskiy Prostor"/
s/export KEY_EMAIL=.*/export KEY_EMAIL="kolesov@3253838.ru"/' easy-rsa/vars

pushd easy-rsa

rm openssl.cnf
ln -s /etc/openvpn/easy-rsa/openssl-1.0.0.cnf ./openssl.cnf

source vars
./clean-all
./build-ca
./build-key-server server
./build-dh
openvpn --genkey --secret ta.key
cp ta.key /etc/openvpn

pushd keys
cp server.crt server.key ca.crt dh1024.pem /etc/openvpn
popd

popd

popd
