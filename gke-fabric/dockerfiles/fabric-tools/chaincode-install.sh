#!/bin/bash


# install chaincode with org
peer lifecycle chaincode install chaincode/basic.tar.gz

# approve chaincode with org
peer lifecycle chaincode approveformyorg -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com --channelID mychannel --name basic --version 1.0 --package-id basic_1.0:f5c61f533f814f850ddefe8a1d570529288b3a210f6ccb074d102437ae376178  --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
