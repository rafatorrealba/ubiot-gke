#!/bin/bash

# check peer conection
peer channel list

# join org1 to channel
peer channel join -b  mychannel.block

# update channel in org2
peer channel update -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com  -c mychannel -f /fabric/config/channel-artifacts/Org2MSPanchors.tx --tls --cafile /fabric/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
