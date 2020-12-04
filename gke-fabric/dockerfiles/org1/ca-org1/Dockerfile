FROM gcr.io/guminator/twinbiot-orgs:1.7 AS CA

FROM hyperledger/fabric-ca:1.4.9 

RUN mkdir -p /var/hyperledger/config
COPY --from=CA var/hyperledger/config/  /var/hyperledger/config

WORKDIR /var/hyperledger/config
