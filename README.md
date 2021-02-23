# ubiot-gke
Ubiot network in kubernetes engine

Prerrequisites:

1) access to a gcp project and permissions of gke.
2) kubectl command line, you can check the steps of install in this [link](https://kubernetes.io/es/docs/tasks/tools/install-kubectl/)



# Steps For Deploy Twinbiot-Network.

1) Create GKE cluster.


```
gcloud beta container --project "guminator" clusters create "twinbiot-cluster-test" --zone "us-central1-c" --no-enable-basic-auth --cluster-version "1.17.15-gke.800" --machine-type "e2-small" --image-type "cos_containerd" --disk-type "pd-standard" --disk-size "20" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --preemptible --num-nodes "3" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/guminator/global/networks/default" --subnetwork "projects/guminator/regions/us-central1/subnetworks/default" --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0

# if you want to create cluster in other zone you can change the "zone" flag in the shell command

```


2) Deploy NFS Server.

```

2.1- Create Compute engine disk

# this is for use the share volume in any pods of fabric.
# you must make sure that it is in the same zone of the cluster that you created in step one.

gcloud compute disks create --size=10GB --zone=us-central1-c gce-nfs-disk

2.2- create nfs server.

# clone the repository.

git clone https://github.com/rafatorrealba/ubiot-gke.git

# go to the workdir 

 cd ubiot-gke/gke-fabric/deployments

# deploy the nfs-server.

 kubectl apply -f nfs-server/
 
 # You can verify the pod with the "kubectl get pods" command, if the service is running it was created correctly.
 
```

3) Create Persistent Volume and Volume Claim
 
 ```
 # in the same file with you deploy nfs-server.
 # create the volume that the pods going to connect
 
 kubectl apply -f volume-claim/
 
 # The volume is connected to the nfs server to use readwritemany access,
 # which allows pods to share the same directory.
 ```
 
4) Deploy Fabric-tools helper

```
# it's a tool that help to create de fabric-structure.

kubectl apply -f tools.yaml

# note: this pod may show the state crashlookback or error
# if this  happens only happens just delete it and recreate it

kubectl delete -f tools.yaml
kubectl apply -f tools.yaml

# this not generate problem with network because only use de tool 
# for generate data in a persistent volume.

# Copy the fabric data to /fabric/config
# for build the network it's necessary to have any files.
# this file exist inside a folder in pod fabric-tools.

kubectl exec -it fabric-tools -- bash
./fabric-config.sh
exit
# the script copy the files into /fabric/config folder that it's sharing for any pods.
```

 5) Deploy fabric-CA
 
 ```
 kubectl apply -f fabric-ca/
 
# this command deploy ca-server for orderer and organizations
# you must always verify that pods ar running with "kubectl get pods"
# if you want to get more info about a pod you can use "kubectl describe pod name-of-pod"
```

6) Generate certificates of organizations use the fabric-ca.

```

#these scripts run the process to re
# for ca-org1

kubectl exec -it ca-org1-0 -- bash

cd /fabric/config

# copy these commands

  mkdir -p organizations/peerOrganizations/org1.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.example.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@ca-org1:7054 --caname ca-org1 --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca-org1-7054-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca-org1-7054-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca-org1-7054-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca-org1-7054-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/org1.example.com/peers
  mkdir -p organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@ca-org1:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp --csr.hosts peer0-org1-example-com --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@ca-org1:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls --enrollment.profile tls --csr.hosts peer0-org1-example-com --csr.hosts ca-org1 --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/tlsca/tlsca.org1.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/org1.example.com/users
  mkdir -p organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@ca-org1:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org1admin:org1adminpw@ca-org1:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/config.yaml


exit



# for ca-org2

kubectl exec -it ca-org2-0 -- bash

cd /fabric/config

# copy these commands

  mkdir -p organizations/peerOrganizations/org2.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.example.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@ca-org2:8054 --caname ca-org2 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca-org2-8054-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca-org2-8054-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca-org2-8054-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca-org2-8054-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/org2.example.com/peers
  mkdir -p organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@ca-org2:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp --csr.hosts peer0-org2-example-com --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@ca-org2:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls --enrollment.profile tls --csr.hosts peer0-org2-example-com --csr.hosts ca-org2 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/tlsca/tlsca.org2.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.example.com/ca/ca.org2.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/org2.example.com/users
  mkdir -p organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@ca-org2:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org2admin:org2adminpw@ca-org2:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/config.yaml



exit

# for ca-orderer

kubectl exec -it ca-orderer-0 -- bash

cd /fabric/config

# copy these commands

mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@ca-orderer:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca-orderer-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca-orderer-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca-orderer-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca-orderer-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml

  infoln "Register orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/ordererOrganizations/example.com/orderers
  mkdir -p organizations/ordererOrganizations/example.com/orderers/example.com

  mkdir -p organizations/ordererOrganizations/example.com/orderers/orderer.example.com

  infoln "Generate the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@ca-orderer:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer-example-com --csr.hosts ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  infoln "Generate the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@ca-orderer:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer-example-com --csr.hosts ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p organizations/ordererOrganizations/example.com/users
  mkdir -p organizations/ordererOrganizations/example.com/users/Admin@example.com

  infoln "Generate the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@ca-orderer:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml




exit

```


5) Generate channel artifacts, genesis.block and connection.yaml file

```
kubectl exec -it fabric-tools -- bash

cd /fabric/config

# this script generate the channel artifacts and genesis.block that we need to deploy
# the fabric network.

./generate.sh start

# this script generate the yaml file for connection between app and smart-contract

./ccp-generate.sh

exit

# the use of this pod finish here so you can delete with.

kubectl delete pod fabric-tools

```

6) Deploy fabric-network


```
kubectl apply -f fabric-network/

# this command deploy the basic structure of fabric
# in this case one orderer, and two peers.
# you must wait to pods are running.

```

7) Create Channel and join peers


```
# first we will create the channel use the peer0-org1-example-com-0 

kubectl exec -it peer0-org1-example-com-0 -- sh

cd /fabric/config

export CORE_PEER_MSPCONFIGPATH=/fabric/config/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

sh channel-create.sh

# now we will join peer into a channel and update.

sh join-channel-org1.sh

# verify if the peer are join to channel 

peer channel list.

# in the case of peer0-org2-example-0
# only join to channel is required
# open another terminal and run this command

kubectl exec -it peer0-org2-example-com-0 -- sh

cd /fabric/config

export CORE_PEER_MSPCONFIGPATH=/fabric/config/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

sh join-channel-org2.sh

# verify if peer are join to channel
peer channel list

# not close the connection with to peers.

```



8) Install chaincode 

```
# ORG1
# in the same terminal and folder run.

sh chaincode-intall.sh
# wait until finish the proccess

# ORG2
# in the same terminal and folder run.
sh chaincode-intall.sh

# wait until finish the proccess

```

9) commit chaincode

```
# in any of peer run

sh chaincode-commit.sh

# you can use this command to verify that chaincode was installed.

# create machine
peer chaincode invoke -o orderer-example-com:7050  --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses peer0-org1-example-com:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0-org2-example-com:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["org.example.com.ComplexContract:NewMachine", "MACHINE1", "Alejandro", "1", "1", "1"]}'

# get machine
peer chaincode invoke -o orderer-example-com:7050 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses peer0-org1-example-com:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0-org2-example-com:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["org.example.com.ComplexContract:GetMachine", "MACHINE1"]}'

# and with this it's have the basic structure of fabric-network

exit
# in peers


```
10)  Deploy the twinbiot app

```

# in the same folder gke-fabric/deployments run

kubectl apply -f twinbiot-app/

# this is for deploy the app that interact with fabric network.
# the app  will connect with the smart contract using the yaml file generate in the step 5.
# For connect to app you need to get the ip of the service.

kubectl get svc

# in the service name twinbiot-app you use the ip that tag with type Load Balancer.
# copy the ip and paste into a net browser and begin to interect with the app.
# note: the only functions avalible are getmachine and newmachine.
```


# Delete network

```
# Delete APP

kubectl delete -f twinbiot-app/


# Delete fabric-network

kubectl delete -f fabric-network/

# Delete CA-Server

kubectl delete -f fabric-ca/


# Delete Volume Claim

kubectl delete -f volume-claim/

# Delete nfs-server

kubectl delete -f nfs-server/

# Delete the disk.

gcloud compute disks delete --zone=us-central1-c gce-nfs-disk

# Delete cluster

gcloud beta container --project "guminator" clusters delete "twinbiot-cluster" --zone "us-central1-c"

```

















 
 

 


