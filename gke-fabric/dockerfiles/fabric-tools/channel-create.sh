#!/bin/bash

# check peer conection
peer channel list
# create channel command

peer channel create -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com  -c mychannel -f /fabric/config/channel-artifacts/mychannel.tx --tls --cafile /fabric/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
