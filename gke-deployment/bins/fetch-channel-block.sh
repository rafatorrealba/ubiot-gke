#!/bin/sh
peer channel fetch 0 ../config/airlinechannel.block -o $ORDERER_ADDRESS -c airlinechannel


peer channel fetch 0 mychannel.block -o orderer:7050 -c mychannel  --tls  --cafile /var/hyperledger/config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


peer channel fetch 0 -c mychannel -o orderer:7050 --tls  --cafile
