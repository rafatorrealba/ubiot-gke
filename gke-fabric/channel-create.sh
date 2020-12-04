
## Create Cluster ##

gcloud beta container --project "guminator" clusters create "twinbiot-cluster" --zone "us-central1-c" --no-enable-basic-auth --cluster-version "1.16.13-gke.401" --machine-type "e2-small" --image-type "COS" --disk-type "pd-standard" --disk-size "20" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --preemptible --num-nodes "2" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/guminator/global/networks/default" --subnetwork "projects/guminator/regions/us-central1/subnetworks/default" --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0


## Delete Cluster ##
gcloud beta container --project "guminator" clusters delete "twinbiot-cluster" --zone "us-central1-c"





## Channel Create ##


# Org1 variables

export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/config/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_ADDRESS=peer0-org1-example-com:7051
export CORE_PEER_TLS_ROOTCERT_FILE=/var/hyperledger/config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

# create channel command

peer channel create -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f /var/hyperledger/config/channel-artifacts/mychannel.tx --tls --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# join org1 to channel
peer channel join -b  mychannel.block

# update channel in org1
peer channel update -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f /var/hyperledger/config/channel-artifacts/Org1MSPanchors.tx --tls --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem





# Org2 variables

export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/config/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=peer0-org2-example-com:9051
export CORE_PEER_TLS_ROOTCERT_FILE=/var/hyperledger/config/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

# Channel fecth
peer channel fetch 0 mychannel.block -c mychannel -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer.example.com --tls  --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# join org2 to channel
peer channel join -b  mychannel.block

# channel update in org2
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
