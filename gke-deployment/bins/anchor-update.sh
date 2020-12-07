#!/bin/bash

peer channel update -f ../config/acme-peer-update.tx -c airlinechannel -o $ORDERER_ADDRESS

peer channel update -f /var/hyperledger/config/Org1Anchors.tx -c mychannel -o orderer:7050
