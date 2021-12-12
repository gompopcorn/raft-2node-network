host1:
docker-compose -f docker-compose-host1.yaml up -d
Host2:
docker-compose -f docker-compose-host2.yaml up -d
Host3:
docker-compose -f docker-compose-host3.yaml up -d





create channel

org1:
# docker exec cli peer channel create -o orderer0.org1.example.com:7050 -c mychannel -f ./channel-artifacts/mychannel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/orderer0.org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


docker exec cli peer channel create -o orderer0.org1.example.com:7050 -c mychannel --ordererTLSHostnameOverride orderer0.org1.example.com -f ./channel-artifacts/mychannel.tx --outputBlock ./mychannel.block --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/orderer0.org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


docker exec cli peer channel join -b mychannel.block

docker exec -e CORE_PEER_ADDRESS=peer1.org1.example.com:8051 -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt cli peer channel join -b mychannel.block

host1:
docker cp cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block .

move mychannel.block from host1 to other hosts
scp mychannel.block ubuntu@185.235.40.72:/usr/local/go/src/github.com/hyperledger/fabric-samples/raft-2node
scp mychannel.block ubuntu@185.235.40.52:/usr/local/go/src/github.com/hyperledger/fabric-samples/raft-2node

host2 and host3:
docker cp mychannel.block cli:/opt/gopath/src/github.com/hyperledger/fabric/peer/



org2:
docker exec cli peer channel join -b mychannel.block


docker exec -e CORE_PEER_ADDRESS=peer1.org2.example.com:8051 -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt cli peer channel join -b mychannel.block


org3:
docker exec cli peer channel join -b mychannel.block


docker exec -e CORE_PEER_ADDRESS=peer1.org3.example.com:8051 -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt cli peer channel join -b mychannel.block


install chaincode

org1:
docker exec cli peer chaincode install -n fabcar -p /opt/gopath/src/github.com/chaincode/fabcar/go -v 1

org2:
docker exec cli peer chaincode install -n fabcar -p /opt/gopath/src/github.com/chaincode/fabcar/go -v 1

org3:
docker exec cli peer chaincode install -n fabcar -p /opt/gopath/src/github.com/chaincode/fabcar/go -v 1


org1:
docker exec cli peer chaincode instantiate -o orderer0.org1.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/orderer0.org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar -v 1 -c '{"Args": []}' -P "OR('Org1MSP.member','Org2MSP.member','Org3MSP.member')"


org1:
docker exec cli peer chaincode invoke -o orderer1.org1.example.com:8050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/orderer1.org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar -c '{"Args":["initLedger"]}'


org1:
docker exec cli peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryCar","CAR0"]}'


org2:
docker exec cli peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryCar","CAR0"]}'


org3:
docker exec cli peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryCar","CAR0"]}'


org2:
docker exec cli peer chaincode invoke -o orderer0.org2.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/orderer0.org2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar -c '{"Args":["changeCarOwner","CAR0","KC"]}'


org3:
docker exec cli peer chaincode invoke -o orderer0.org2.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/orderer0.org2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar -c '{"Args":["changeCarOwner","CAR0","Mehdi"]}'









