
# ubiot-network

# prerequisites:

kubectl tools installed in vm or google shell


# 1) Create gke cluster in gcp.

# Ubiot cluster deployment


gcloud beta container --project "guminator" clusters create "twinbiot-cluster" --zone "us-central1-c" --no-enable-basic-auth --cluster-version "1.16.13-gke.401" --machine-type "e2-medium" --image-type "COS" --disk-type "pd-standard" --disk-size "30" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --preemptible --num-nodes "2" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/guminator/global/networks/default" --subnetwork "projects/guminator/regions/us-central1/subnetworks/default" --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --shielded-secure-boot


# optional create images 

1)  generate artifacts in test-network

cd ubiot-gke/test-network
./network.sh up createChannel -ca

2) build and push to container registry:

orderer:

docker build -t  gcr.io/"PROJECT"/ANY-NAME -f  /home/"your-user"/ubiot-gke/gke/docker-images/orderer/Dockerfile
docker push gcr.io/"PROJECT"/ANY-NAME

Peer0: 

docker build -t  gcr.io/"PROJECT"/ANY-NAME -f  /home/"your-user"/ubiot-gke/gke/docker-images/peer0/Dockerfile
docker push gcr.io/"PROJECT"/ANY-NAME

# 2) Create orderer, org1 and org2 deployment

cd ubiot-gke/gke/docker-images 
kubectl apply -f orderer/
kubectl apply -f org1/
kubectl apply -f org2/


# 3)  join-channel

comming soon

