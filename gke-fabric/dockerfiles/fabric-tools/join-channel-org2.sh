#!/bin/bash


export CORE_PEER_MSPCONFIGPATH=/fabric/config/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp


# check peer conection
peer channel list
# create channel command

peer channel create -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com  -c mychannel -f /fabric/config/channel-artifacts/mychannel.tx --tls --cafile /fabric/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# join org1 to channel
peer channel join -b  mychannel.block

# update channel in org1
peer channel update -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com  -c mychannel -f /fabric/config/channel-artifacts/Org1MSPanchors.tx --tls --cafile /fabric/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
