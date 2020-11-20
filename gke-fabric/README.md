# Working directory:

1) dockerfiles for orderer, org1, org2 docker images.

2) deployments for orderer, org1, org2 gke pods.


note: you must have gke cluster deployed

# Generate artifacts

cd ubiot-network/test-network

./network.sh up createChannel -ca
docker rm -f $(docker ps -aq)

​

docker volume prune -f

# Create docker images

1) orderer:

docker build -t gcr.io/guminator/twinbiot-orderer:1.0 /home/user/ubiot-network/gke-fabric/dockerfiles/orderer/Dockerfile
docker push gcr.io/guminator/twinbiot-orderer:1.0

2) org1 and org2

docker build -t gcr.io/guminator/twinbiot-org1:1.0  /home/user/ubiot-network/gke-fabric/dockerfiles/org1/Dockerfile

docker build -t gcr.io/guminator/twinbiot-org2:1.0  /home/user/ubiot-network/gke-fabric/dockerfiles/org2/Dockerfile$

docker push  gcr.io/guminator/twinbiot-org1:1.0 

docker push  gcr.io/guminator/twinbiot-org2:1.0 



# Create gke deployment

cd deployments

kubectl apply -f orderer/

kubectl apply -f org1/

kubectl apply -f org2/


# Delete gke deployments

kubectl delete -f orderer/

kubectl delete -f org1/

kubectl delete -f org2/

