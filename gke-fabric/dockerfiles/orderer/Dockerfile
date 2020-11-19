#1. Docker file for setting up the Orderer
FROM hyperledger/fabric-orderer:2.2.1

#1.1. Install nano editor 

#RUN apt update && install nano -y

#2. Create the folder for configurations
RUN mkdir -p /var/hyperledger/config

#3. Copy the crypto for orderer
COPY ./ubiot-network/test-network/ /var/hyperledger/config/


#4. Copy the orderer YAML
COPY ./ubiot-network/gke-fabric/dockerfiles/orderer/orderer.yaml /var/hyperledger/config

#5. Launch the Orderer
CMD orderer

