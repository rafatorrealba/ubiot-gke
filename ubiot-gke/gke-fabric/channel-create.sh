

# Org1

export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/config/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=peer0-org1-example-com:7051
export CORE_PEER_TLS_ROOTCERT_FILE=/var/hyperledger/config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

peer channel create -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f /var/hyperledger/config/channel-artifacts/mychannel.tx --tls --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

peer channel join -b  mychannel.block

peer channel update -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f /var/hyperledger/config/channel-artifacts/Org1MSPanchors.tx --tls --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem





# Org2

export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/config/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=peer0-org2-example-com:9051
export CORE_PEER_TLS_ROOTCERT_FILE=/var/hyperledger/config/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt



peer channel fetch 0 mychannel.block -c mychannel -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com --tls  --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

peer channel join -b  mychannel.block

peer channel update -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f /var/hyperledger/config/channel-artifacts/Org2MSPanchors.tx --tls --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem



# Chaincode Install


#org1

export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/config/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=peer0-org1-example-com:7051
export CORE_PEER_TLS_ROOTCERT_FILE=/var/hyperledger/config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

peer lifecycle chaincode install /var/hyperledger/chaincode/basic.tar.gz

peer lifecycle chaincode approveformyorg -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id basic_1.0:f5c61f533f814f850ddefe8a1d570529288b3a210f6ccb074d102437ae376178  --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

#org2

export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/config/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=peer0-org2-example-com:9051
export CORE_PEER_TLS_ROOTCERT_FILE=/var/hyperledger/config/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

peer lifecycle chaincode install /var/hyperledger/chaincode/basic.tar.gz

peer lifecycle chaincode approveformyorg -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id basic_1.0:f5c61f533f814f850ddefe8a1d570529288b3a210f6ccb074d102437ae376178  --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json


peer lifecycle chaincode commit -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0-org1-example-com:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses  peer0-org2-example-com:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt


# invoke smart-contract

peer chaincode invoke -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses peer0-org1-example-com:7051 --tlsRootCertFiles /var/hyperledger/config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0-org2-example-com:9051 --tlsRootCertFiles /var/hyperledger/config/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["org.example.com.ComplexContract:NewMachine", "MACHINE1", "{\"company\": \"Ubiot\", \"lessor\": \"Rafael Torrealba\"}", "1000", "500", "40"]}'


peer chaincode invoke -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic  -c '{"Args":["org-example-com.ComplexContract:GetMachine", "MACHINE1"]}'
