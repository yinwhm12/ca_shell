## 脚本生成对应的ca证书

### 启动
#### 1. 产生对应的证书
    首先先执行目录crypto-config/ca_main.sh生成一系列的证书,conf.sh为注册登录ca成员的配置文件以及多少个组织；执行命令为:
        ./ca_main.sh all true
    以上命令是请求ca-server并组装对应的msp tls; false表示仅仅产生对应的fabric-ca-client.yaml文件，没有进行任何服务请求。(不进行脚本解读，如需跟作者进行交流即可)

    如产生过程出错可以执行:
        ./ca_main.sh clear
    将删除当前所有的文件夹

#### 2. 产生创始数据 通道数据文件 锚点文件
    执行跟目录下的genconfigtx.sh,命令：
        ./genconfigtx.sh
    就会在文件夹channel-artifacts下产生对应的文件夹

#### 3. 启动网络
    执行跟目录下的start.yaml文件，使用docker-compose工具启动即可。注:如需改动启动的节点，摸索一下该start.yaml文件，就能操作了；如有困难，可以跟作者进一步交流。

#### 4. fabric网络操作
    产生 channel

    ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/orderer.example.com/msp/tlscacerts/tls-localhost-7055.pem

    peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls true --cafile $ORDERER_CA

    加入 另外的Peers
    peer1.org1加入
    CORE_PEER_LOCALMSPID="Org1MSP" 
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer1.org1.example.com/tls/ca.crt 
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/org1.example.com/msp 
    CORE_PEER_ADDRESS=peer1.org1.example.com:7051

    peer channel join -b mychannel.block

    peer0.org2加入
    CORE_PEER_LOCALMSPID="Org2MSP" 
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org2.example.com/tls/ca.crt 
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/org2.example.com/msp 
    CORE_PEER_ADDRESS=peer0.org2.example.com:7051

    peer channel join -b mychannel.block

    peer1.org2加入
    CORE_PEER_LOCALMSPID="Org2MSP" 
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer1.org2.example.com/tls/ca.crt 
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/org2.example.com/msp 
    CORE_PEER_ADDRESS=peer1.org2.example.com:7051

    peer channel join -b mychannel.block

    更新锚节点
    CORE_PEER_LOCALMSPID="Org1MSP" 
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org1.example.com/tls/ca.crt 
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/org1.example.com/msp 
    CORE_PEER_ADDRESS=peer0.org1.example.com:7051

    peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls true --cafile $ORDERER_CA


    CORE_PEER_LOCALMSPID="Org2MSP" 
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org2.example.com/tls/ca.crt 
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/org2.example.com/msp 
    CORE_PEER_ADDRESS=peer0.org2.example.com:7051

    peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls true --cafile $ORDERER_CA

    切换到peer0.org1
    CORE_PEER_LOCALMSPID="Org1MSP" 
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer0.org1.example.com/tls/ca.crt 
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/org1.example.com/msp 
    CORE_PEER_ADDRESS=peer0.org1.example.com:7051

    安装 实例化链码
    peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02

    peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA -C mychannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"

    查询
    peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'

    invoke操作
    peer chaincode invoke -o orderer.example.com:7050  --tls true --cafile $ORDERER_CA -C mychannel -n mycc -c '{"Args":["invoke","a","b","10"]}'

### fabric-ca-server简述
本实例的操作都是跟 fabric-ca-server进行 连接的，包括基本的Msp tls服务以及对应的证书；下面简单的说一下启动msp-server以及tls-server服务:

    1. msp-server服务启动
        在目录fabric-ca-mspserver下的启动文件:
        fabric-ca-server start -c fabric-ca-server-config.yaml
    2. tls-server服务启动
        在目录fabric-ca-tlsserver下的启动文件:
        fabric-ca-server start -c fabric-ca-server-config.yaml
他们(msp tls)的启动基本没有什么区别，主要是若是在同一台机器上，需端口进行区别启动；当，登录tls时 多加入几个参数即可:

     -d --enrollment.profile tls
即在登录时加入。
如：

    fabric-ca-client enroll -d --enrollment.profile tls -u http://orderer:orderer-password@localhost:8054 -c fabric-ca-client-config.yaml 

### 注
- 跟目录下的configtxgen是1.1.0版本的，如需其他的版本只需编译好后替换即可。
- 以上操作仅仅针对 1 orderer + 2 org + 4 peer 进行的；
- 本现成的实例完全可以执行，但是注意镜像版本原因带来的错误；且本实例主要目的是为了 理解，在理解的基础上进行对应的改动即可。