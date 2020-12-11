
#!/bin/bash

set -e

PROJECT_DIR=$PWD

ARGS_NUMBER="$#"
COMMAND="$1"

function verifyArg() {

    if [ $ARGS_NUMBER -ne 1 ]; then
        echo "Useage: networkOps.sh start | status | clean | cli | peer"
        exit 1;
    fi
}

OS_ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
FABRIC_ROOT=$GOPATH/src/github.com/hyperledger/fabric

#function replacePrivateKey () {

#    echo # Replace key

        # ARCH=`uname -s | grep Darwin`
        # if [ "$ARCH" == "Darwin" ]; then
        #       OPTS="-it"
        # else
                #OPTS="-i"
        # fi

        # cp docker-compose-template.yaml docker-compose.yaml

    # CURRENT_DIR=$PWD
    # cd crypto-config/peerOrganizations/org1.example.com/ca/
    # PRIV_KEY=$(ls *_sk)
    # cd $CURRENT_DIR
    # sed $OPTS "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml
    # cd crypto-config/peerOrganizations/org2.example.com/ca/
    # PRIV_KEY=$(ls *_sk)
    # cd $CURRENT_DIR
    # sed $OPTS "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml
#}

function generateCerts(){

    echo
        echo "##########################################################"
        echo "##### Generate certificates using cryptogen tool #########"
        echo "##########################################################"
        if [ -d ./organizations ]; then
                rm -rf ./organizations
        fi

       cryptogen generate --config=cryptogen/crypto-config-orderer.yaml --output="organizations"
       cryptogen generate --config=cryptogen/crypto-config-org1.yaml --output="organizations"
       cryptogen generate --config=cryptogen/crypto-config-org2.yaml --output="organizations"
    echo
}


function generateChannelArtifacts(){

    if [ ! -d ./channel-artifacts ]; then
                mkdir channel-artifacts
        fi

    echo
        echo "#################################################################"
        echo "### Generating channel configuration transaction 'channel.tx' ###"
        echo "#################################################################"
        configtxgen -configPath configtx -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
        configtxgen -configPath configtx -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel


    echo
        echo "#################################################################"
        echo "#######    Generating anchor peer update for Org1MSP   ##########"
        echo "#################################################################"
        configtxgen -configPath configtx -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP



        echo "#################################################################"
        echo "#######    Generating anchor peer update for Org2MSP   ##########"
        echo "#################################################################"
        configtxgen -configPath configtx -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP

}

#function startNetwork() {

#    echo
#    echo "================================================="
#    echo "---------- Starting the network -----------------"
#    echo "================================================="
#    echo

#    cd $PROJECT_DIR
#    docker-compose -f docker-compose.yaml up -d
#}

function cleanNetwork() {
    cd $PROJECT_DIR

    if [ -d ./channel-artifacts ]; then
            rm -rf ./channel-artifacts
    fi

    if [ -d ./organizations ]; then
            rm -rf ./organizations
    fi

    if [ -d ./system-genesis-block ]; then
            rm -rf ./system-genesis-block/*
    fi


    # This operations removes all docker containers and images regardless
    #
    #docker rm -f $(docker ps -aq)
    #docker rmi -f $(docker images -q)

    # This removes containers used to support the running chaincode.
    #docker rm -f $(docker ps --filter "name=dev" --filter "name=peer0.org1.example.com" --filter "name=cli" --filter "name=orderer.example.com" -q)

    # This removes only images hosting a running chaincode, and in this
    # particular case has the prefix dev-*
    #docker rmi $(docker images | grep dev | xargs -n 1 docker images --format "{{.ID}}" | xargs -n 1 docker rmi -f)
}

# Network operations
verifyArg
case $COMMAND in
    "start")
        #generateCerts
        generateChannelArtifacts
        ;;
    "status")
        networkStatus
        ;;
    "clean")
        cleanNetwork
        ;;
    "cli")
        dockerCli
        ;;
    *)
        echo "Useage: networkOps.sh start | status | clean | cli "
        exit 1;
esac
