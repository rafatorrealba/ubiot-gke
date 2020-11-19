#!/bin/bash

# export ORG_CONTEXT=$1
MSP_ID="$(tr '[:lower:]' '[:upper:]' <<< ${ORG_CONTEXT:0:1})${ORG_CONTEXT:1}"
export ORG_NAME=$MSP_ID

# Logging specifications
export FABRIC_LOGGING_SPEC=INFO

# Local MSP for the admin - Commands need to be executed as org admin
export CORE_PEER_MSPCONFIGPATH=$PWD/../config/organization/peerOrganizationsusers/$ORG_CONTEXT/Admin@$ORG_CONTEXT.com/msp

