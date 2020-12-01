#Docker file for setting up the peer
FROM hyperledger/fabric-peer:2.2.1

#1. Create the folder for configurations
RUN mkdir -p /var/hyperledger/config
RUN mkdir -p /var/hyperledger/chaincode
RUN mkdir -p /var/hyperledger/scripts

#2. Copy the crypto for peer crypto
COPY ./ubiot-gke/gke-fabric/organizations /var/hyperledger/config/organizations

#3 ##### Copy the core.yaml file that is used by Peer #####

# COPY ./ubiot-gke/gke-fabric/dockerfiles/org1/core.yaml /var/hyperledger/config
COPY ./ubiot-gke/gke-fabric/configtx /var/hyperledger/config/configtx
COPY ./ubiot-gke/gke-fabric/channel-artifacts /var/hyperledger/config/channel-artifacts
COPY ./ubiot-gke/gke-fabric/chaincode /var/hyperledger/chaincode


#7. Launch the peer
CMD peer node start
