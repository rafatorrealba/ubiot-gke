#Docker file for setting up the org1
FROM hyperledger/fabric-peer:2.2.1

#1. Create the folder for configurations
RUN mkdir -p /var/hyperledger/config
RUN mkdir -p /var/hyperledger/chaincode
RUN mkdir -p /var/hyperledger/scripts

#2. Copy the crypto for peer crypto
COPY ./ubiot-gke/gke-fabric/organizations /var/hyperledger/config
COPY ./ubiot-gke/gke-fabric/channel-artifacts /var/hyperledger/config
COPY ./ubiot-gke/gke-fabric/chaincode /var/hyperledger/chaincode



##### Copy the core.yaml file that is used by Peer #####
#3. Copy the core YAML
COPY ./ubiot-gke/gke-fabric/dockerfiles/org1/core.yaml /var/hyperledger/config

##### Copy the utility scripts #####
#4. Copy the bins
COPY ./ubiot-gke/gke-fabric/scripts/ /var/hyperledger/scripts/

##### Setup the environment for executing peer commands #####
#5. Set the working dir
RUN  echo "cd /var/hyperledger/scripts" >> $HOME/.bashrc

#6. Set the context for Admin user
RUN echo ". /var/hyperledger/scripts/set-context.sh" >> $HOME/.bashrc

#7. Launch the peer
CMD peer node start
