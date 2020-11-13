#1. Docker file for setting up the Orderer
FROM hyperledger/fabric-orderer:2.2.1


#2. Create the folder for configurations
RUN mkdir -p /fabric/config

#3. Copy the crypto for orderer
COPY ./ubiot-gke/test-network  /fabric/config

