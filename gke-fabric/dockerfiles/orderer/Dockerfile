#1. Docker file for setting up the Orderer
FROM hyperledger/fabric-orderer:2.2.1

#2. Create the folder for configurations
RUN mkdir -p /var/hyperledger/config

#3. Copy the crypto for orderer

COPY ./ubiot-gke/gke-fabric/organizations /var/hyperledger/config/organizations
COPY ./ubiot-gke/gke-fabric/configtx /var/hyperledger/config/configtx
COPY ./ubiot-gke/gke-fabric/system-genesis-block /var/hyperledger/config/system-genesis-block

#4. Copy the orderer YAML
#COPY ./ubiot-gke/gke-fabric/dockerfiles/orderer/orderer.yaml /var/hyperledger/config

#5. Launch the Orderer
CMD orderer
