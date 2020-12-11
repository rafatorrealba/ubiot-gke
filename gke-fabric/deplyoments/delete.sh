#!/bin/bash

kubectl delete -f fabric-network/

kubectl delete -f fabric-ca/

kubectl delete -f .

kubectl delete -f twinbiot-app

kubectl delete -f nfs-server/


gcloud compute disks delete --zone=us-central1-c gce-nfs-disk
