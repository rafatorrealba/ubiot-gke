#!/bin/bash

gcloud compute disks create --size=10GB --zone=us-central1-c gce-nfs-disk

kubectl apply -f nfs-server/

sleep 20

kubectl apply -f .

sleep 25

kubectl exec -it fabric-tools -- ./fabric-config
