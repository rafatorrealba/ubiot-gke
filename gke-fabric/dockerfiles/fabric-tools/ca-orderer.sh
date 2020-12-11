#!/bin/bash

infoln "Enroll the CA admin"
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
