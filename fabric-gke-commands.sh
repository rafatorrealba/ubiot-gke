
## Create Cluster ##

gcloud beta container --project "guminator" clusters create "twinbiot-cluster" --zone "us-central1-c" --no-enable-basic-auth --cluster-version "1.16.13-gke.401" --machine-type "e2-small" --image-type "COS" --disk-type "pd-standard" --disk-size "20" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --preemptible --num-nodes "2" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/guminator/global/networks/default" --subnetwork "projects/guminator/regions/us-central1/subnetworks/default" --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0


## Delete Cluster ##
gcloud beta container --project "guminator" clusters delete "twinbiot-cluster" --zone "us-central1-c"

## Generate Data##

./generate.sh start

## Create Docker images ##

# orderer
docker build -t gcr.io/guminator/twinbiot-orderer:1.7  -f ubiot-gke/gke-fabric/dockerfiles/orderer/Dockerfile .

docker push gcr.io/guminator/twinbiot-orderer:1.7

# org1 and org2

docker build -t gcr.io/guminator/twinbiot-orgs:1.7 -f ubiot-gke/gke-fabric/dockerfiles/org1/Dockerfile .

#docker build -t gcr.io/guminator/twinbiot-org2:1.7 ubiot-gke/gke-fabric/dockerfiles/org2/Dockerfile

docker push gcr.io/guminator/twinbiot-orgs:1.7




## Deploy Fabric network ##

kubectl  apply -f twinbiot-orderer
kubectl  apply -f twinbiot-org1
kubectl  apply -f twinbiot-org2

## Delete Fabric ##
kubectl  delete -f twinbiot-orderer
kubectl  delete -f twinbiot-org1
kubectl  delete -f twinbiot-org2



## Channel Create ##

##ORG1##

kubectl exec -it peer0-org1-example-com-0 -- /bin/sh

cd var/hyperledger/config/
# Org1 variables


#export CORE_PEER_LOCALMSPID="Org1MSP"
#export CORE_PEER_ADDRESS=peer0-org1-example-com:7051
#export CORE_PEER_TLS_ROOTCERT_FILE=/var/hyperledger/config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/config/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

# check peer conection
peer channel list
# create channel command

peer channel create -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com  -c mychannel -f /var/hyperledger/config/channel-artifacts/mychannel.tx --tls --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# join org1 to channel
peer channel join -b  mychannel.block

# update channel in org1
peer channel update -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com  -c mychannel -f /var/hyperledger/config/channel-artifacts/Org1MSPanchors.tx --tls --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


##ORG2##

kubectl exec -it peer0-org2-example-com-0 -- /bin/sh

cd var/hyperledger/config/


# Org2 variables

#export CORE_PEER_LOCALMSPID="Org2MSP"
#export CORE_PEER_ADDRESS=peer0-org2-example-com:9051
#export CORE_PEER_TLS_ROOTCERT_FILE=/var/hyperledger/config/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/config/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp




# check peer conection
peer channel list

# Channel fecth
peer channel fetch 0 mychannel.block -c mychannel -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com --tls  --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# join org2 to channel
peer channel join -b  mychannel.block

# channel update in org2
peer channel update -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com -c mychannel -f /var/hyperledger/config/channel-artifacts/Org2MSPanchors.tx --tls --cafile /var/hyperledger/config/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem




# Chaincode Install

##ORG1##

kubectl exec -it peer0-org2-example-com-0 -- /bin/sh

cd var/hyperledger/config/


#org1 variables

#export CORE_PEER_LOCALMSPID="Org1MSP"
#export CORE_PEER_ADDRESS=peer0-org1-example-com:7051
#export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/config/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
#export CORE_PEER_TLS_ROOTCERT_FILE=/var/hyperledger/config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt


# install chaincode with org1
peer lifecycle chaincode install /var/hyperledger/chaincode/basic.tar.gz

# approve chaincode with org1
peer lifecycle chaincode approveformyorg -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com --channelID mychannel --name basic --version 1.0 --package-id basic_1.0:f5c61f533f814f850ddefe8a1d570529288b3a210f6ccb074d102437ae376178  --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


##ORG2##

kubectl exec -it peer0-org2-example-com-0 -- /bin/sh

cd var/hyperledger/config/

#org2 variables

export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/config/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_ADDRESS=peer0-org2-example-com:9051
export CORE_PEER_TLS_ROOTCERT_FILE=/var/hyperledger/config/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

# install chaincode with org2
peer lifecycle chaincode install /var/hyperledger/chaincode/basic.tar.gz

# approve chaincode with org2
peer lifecycle chaincode approveformyorg -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com --channelID mychannel --name basic --version 1.0 --package-id basic_1.0:f5c61f533f814f850ddefe8a1d570529288b3a210f6ccb074d102437ae376178  --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


# check commit address
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

# commit chaincode with all orgs

peer lifecycle chaincode commit -o orderer-example-com:7050 --ordererTLSHostnameOverride orderer-example-com:7050 --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0-org1-example-com:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses  peer0-org2-example-com:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

# invoke smart-contract


# new machine

peer chaincode invoke -o orderer-example-com:7050  --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses peer0-org1-example-com:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0-org2-example-com:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["org.example.com.ComplexContract:NewMachine", "MACHINE3", "Alejandro", "1", "1", "1"]}'

 # get machine
peer chaincode invoke -o orderer-example-com:7050 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses peer0-org1-example-com:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0-org2-example-com:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["org.example.com.ComplexContract:GetMachine", "MACHINE1"]}'
