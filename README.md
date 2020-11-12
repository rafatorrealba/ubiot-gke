# ubiot-network

# prerequisites:

kubectl tools installed in vm or google shell


# 1) Create gke cluster in gcp.

# Ubiot cluster deployment


gcloud beta container --project "guminator" clusters create "twinbiot-cluster" --zone "us-central1-c" --no-enable-basic-auth --cluster-version "1.16.13-gke.401" --machine-type "e2-medium" --image-type "COS" --disk-type "pd-standard" --disk-size "30" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --preemptible --num-nodes "2" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/guminator/global/networks/default" --subnetwork "projects/guminator/regions/us-central1/subnetworks/default" --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --shielded-secure-boot


# 2) create nfs disk for gke persistent volumes 


gcloud compute disks create --size=2GB --zone=us-central-c nfs-disk


# 3) Create nfs-server for share artifacts from every fabric pods.


cd gke/fabric-gke

kubectl apply -f nfs-server/

# 4) create persistent volume claim

cd gke/fabric-gke
kubectl apply -f volume-claim/

# 5) Create cli pod to interact with fabric-net.


cd gke/fabric-gke
kubectl apply -f tools/

# 6)  generate artifacts in test-network

cd ubiot-gke/test-network
./network.sh up createChannel -ca

# 7) Copy artifacts in fabric-tools pod

cd ubiot-gke
kubectl exec -it fabric-tools -- mkdir /fabric/config
sudo chmod a+rx test-network/* -R
kubectl cp test-network fabric-tools:/fabric/config
kubectl exec -it fabric-tools -- sh
cd /fabric/config
mv test-network/* /fabric/config
rm -rf test-network
exit

# 8) Create orderer, org1 and org2 deployment

cd ubiot-gke/gke 
kubectl apply -f orderer-server/
kubectl apply -f org1-server/
kubectl apply -f org2-server/


# 9) create channel and join

comming soon
