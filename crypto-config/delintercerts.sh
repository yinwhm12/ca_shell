#!/bin/bash

rm -rf Admin\@example.com/msp/intermediatecerts/ Admin\@example.com/msp/tlsintermediatecerts/

rm -rf orderer.example.com/msp/intermediatecerts/ orderer.example.com/msp/tlsintermediatecerts/

rm -rf org1.example.com/msp/intermediatecerts/ org1.example.com/msp/tlsintermediatecerts/ 
rm -rf org2.exmaple.com/msp/intermediatecerts/ org2.example.com/msp/tlsintermediatecerts/

rm -rf peer0.org1.example.com/msp/intermediatecerts/ peer0.org1.example.com/msp/tlsintermediatecerts/

rm -rf peer1.org1.example.com/msp/intermediatecerts/ peer1.org1.example.com/msp/tlsintermediatecerts/

rm -rf peer0.org2.example.com/msp/intermediatecerts/ peer0.org2.example.com/msp/tlsintermediatecerts/

rm -rf peer1.org2.example.com/msp/intermediatecerts/ peer1.org2.example.com/msp/tlsintermediatecerts/
echo "------delete  done -------------"


