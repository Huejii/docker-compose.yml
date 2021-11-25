#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -ev

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

export CA1_KEY=$(ls crypto-config/peerOrganizations/org1.univercc.com/ca/ | grep _sk)
export CA2_KEY=$(ls crypto-config/peerOrganizations/org2.univercc.com/ca/ | grep _sk)
export CA3_KEY=$(ls crypto-config/peerOrganizations/org3.univercc.com/ca/ | grep _sk)

docker-compose -f docker-compose.yml down

# docker-compose -> 컨테이터수행 및 net_basic 네트워크 생성
docker-compose -f docker-compose.yml up -d ca.org1.univercc.com ca.org2.univercc.com ca.org3.univercc.com orderer.univercc.com peer0.org1.univercc.com peer1.org1.univercc.com peer2.org1.univercc.com peer0.org2.univercc.com peer0.org3.univercc.com couchdb1 couchdb11 couchdb12 couchdb2 couchdb3 cli
docker ps -a
docker network ls
# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel -> myuniv.block cli working dir 복사
docker exec cli peer channel create -o orderer.univercc.com:7050 -c myuniv -f /etc/hyperledger/configtx/channel.tx
# clie workding dir (/etc/hyperledger/configtx/) myuniv.block

# Join peer0.org1.univercc.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.univercc.com/msp" peer0.org1.univercc.com peer channel join -b /etc/hyperledger/configtx/myuniv.block

sleep 3

# Join peer1.org1.univercc.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.univercc.com/msp" peer1.org1.univercc.com peer channel join -b /etc/hyperledger/configtx/myuniv.block

sleep 3

# Join peer2.org1.univercc.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.univercc.com/msp" peer2.org1.univercc.com peer channel join -b /etc/hyperledger/configtx/myuniv.block

sleep 3

# Join peer0.org2.univercc.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.univercc.com/msp" peer0.org2.univercc.com peer channel join -b /etc/hyperledger/configtx/myuniv.block

sleep 3

# Join peer0.org3.univercc.com to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.univercc.com/msp" peer0.org3.univercc.com peer channel join -b /etc/hyperledger/configtx/myuniv.block

sleep 3

# anchor ORG1 myuniv update
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.univercc.com/msp" peer0.org1.univercc.com peer channel update -f /etc/hyperledger/configtx/Org1MSPanchors.tx -c myuniv -o orderer.univercc.com:7050
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.univercc.com/msp" peer1.org1.univercc.com peer channel update -f /etc/hyperledger/configtx/Org1MSPanchors.tx -c myuniv -o orderer.univercc.com:7050
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.univercc.com/msp" peer2.org1.univercc.com peer channel update -f /etc/hyperledger/configtx/Org1MSPanchors.tx -c myuniv -o orderer.univercc.com:7050
# anchor ORG2 myuniv update
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org2.univercc.com/msp" peer0.org2.univercc.com peer channel update -f /etc/hyperledger/configtx/Org2MSPanchors.tx -c myuniv -o orderer.univercc.com:7050
# anchor ORG3 myuniv update
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org3.univercc.com/msp" peer0.org3.univercc.com peer channel update -f /etc/hyperledger/configtx/Org3MSPanchors.tx -c myuniv -o orderer.univercc.com:7050
