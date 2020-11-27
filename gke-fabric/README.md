# Working directory:

1) dockerfiles for orderer, org1, org2 docker images.

2) deployments for orderer, org1, org2 gke pods.


note: you must have gke cluster deployed

# Generate artifacts

./generate.sh start

# Create docker images

1) orderer:

docker build -t gcr.io/guminator/twinbiot-orderer:1.0 /home/user/ubiot-network/gke-fabric/dockerfiles/orderer/Dockerfile
docker push gcr.io/guminator/twinbiot-orderer:1.0

2) org1 and org2

docker build -t gcr.io/guminator/twinbiot-org1:1.0  /home/user/ubiot-gke/gke-fabric/dockerfiles/org1/Dockerfile

docker build -t gcr.io/guminator/twinbiot-org2:1.0  /home/user/ubiot-gke/gke-fabric/dockerfiles/org2/Dockerfile

docker push  gcr.io/guminator/twinbiot-org1:1.0 

docker push  gcr.io/guminator/twinbiot-org2:1.0 



# Create gke deployment

cd deployments

kubectl apply -f  twinbiot-orderer.yaml

kubectl apply -f twinbiot-org1.yaml

kubectl apply -f twinbiot-org2.yaml


# Delete gke deployments

kubectl delete -f twinbiot-orderer.yaml

kubectl delete -f twinbiot-org2.yaml

kubectl delete -f twinbiot-org1.yaml

