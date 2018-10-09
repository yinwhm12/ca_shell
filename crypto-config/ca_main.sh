#!/bin/bash
# 程序开始

. ./mkdir.sh
. ./conf.sh
. ./createClientConfig.sh

function copyMSPDone() {
  #删除 msp tls
  pName=$1
  admin_Name=$2
  echo "------------ copyMSPDone-------  $pName "
  rm -rf ./$pName/msp
  rm -rf ./$pName/tls
  #并接 msp 以及tls
  #创建对应的文件夹
  cp -rf ./$pName/mspdata/msp ./$pName #复制整个msp
  mkdir -p ./$pName/msp/admincerts #创建 admincerts 文件夹
  if [ -z $admin_Name ]; then
	admin_Name=$pName
  fi
  cp -rf ./$admin_Name/mspdata/msp/signcerts/* ./$pName/msp/admincerts/ #复制keystore的私钥
  mkdir -p ./$pName/tls #创建tls
}

function tlsDOne() {
     # 装载对应的msp tls
  dirName=$1   
  echo "------------ copyTLSDone-------  $dirName "   
  if [ -d "./$dirName/msp" ]; then
    cp -rf ./$dirName/tlsdata/msp/tlscacerts/ ./$dirName/msp
    cp -rf ./$dirName/tlsdata/msp/tlsintermediatecerts/ ./$dirName/msp
  fi
  if [ -d "./$dirName/tls" ]; then
    cp -rf ./$dirName/tlsdata/msp/tlscacerts/* ./$dirName/tls/ca.crt
    cp -rf ./$dirName/tlsdata/msp/signcerts/* ./$dirName/tls/server.crt
    cp -rf ./$dirName/tlsdata/msp/keystore/* ./$dirName/tls/server.key
  fi
}
#admin 注册登录
function registerMsp(){
    name=$1
    FileName=$2
    outfilename=$3
    cName=$4
    cPwd=$5
    admin_Name=$6
    echo " ----------------Register msp/tls ------------------"
    fabric-ca-client enroll -u http://$cName:$cPwd@$msp_server_url:$msp_server_port -H ./$FileName/mspdata
    fabric-ca-client register -H ./$FileName/mspdata --id.secret=$commonPwd
    rm -rf ./$FileName/mspdata/msp/keystore/*
    fabric-ca-client enroll -u http://$name:$commonPwd@$msp_server_url:$msp_server_port -c ./$FileName/mspdata/$outfilename

    copyMSPDone $FileName $admin_Name

    fabric-ca-client enroll -u http://$cName:$cPwd@$tls_server_url:$tls_server_port -H ./$FileName/tlsdata/
    fabric-ca-client register -H ./$FileName/tlsdata/ --id.secret=$commonPwd
    rm -rf ./$FileName/tlsdata/msp/keystore/*
    fabric-ca-client enroll -d --enrollment.profile tls -u http://$name:$commonPwd@$tls_server_url:$tls_server_port -c ./$FileName/tlsdata/$outfilename

    tlsDOne $FileName
}


#删除 所以的 目录
function clear(){
    clearPwdDir $1
}

#生成 org 的目录
#包括msp tls的
function createOrgsDir(){
    createDir $1
}
# 生成 org 的yaml
#包括 msp tls的
function createOrgFile(){
    createOrgAdminClientConfig $1 $2 $3 $4 $5 $6 $7
}

# org admin
function createOrg(){
    outfilename=fabric-ca-client-config.yaml
    mspFlag=$1 #是否请求server 产生对应的msp/tls
    for i in ${org_n[@]}; do
      org_personal_name=$org_pre_name$i
      fileName=$org_personal_name.$common_dns #org1.example.com
      orgN=$org_pre_name$i
      createOrgsDir $fileName/mspdata
      createOrgsDir $fileName/tlsdata
      echo " mkdir $fileName/mspdata and $fileName/tlsdata --- done ---"
      host=$org_personal_name.$common_dns
      name=$org_common_admin_name$host
      affiliation=$common_dns_last.$org_personal_name
 #     outfilename=fabric-ca-client-config.yaml
      createOrgFile $name $host $affiliation $fileName/mspdata/$outfilename $msp_url_port $orgN $host
      createOrgFile $name $host $affiliation $fileName/tlsdata/$outfilename $tls_url_port $orgN $host
      echo " mk file $fileName/mspdata/$outfilename and $fileName/tlsdata/$outfilename -----done------"

      if [ $mspFlag == true ]; then
        registerMsp $name $fileName $outfilename $caName $caPwd ""
      fi
    done
}

# 生成 peer 的目录
#包括msp tls的
function createPeersDir(){
    createDir $1
}
#生成 peer 的yaml
#包括 msp tls 的
function createPeerFile(){
    createPeerContent $1 $2 $3 $4 $5 $6 $7
}

#peer 注册登录
function createPeer(){
   outfilename=fabric-ca-client-config.yaml
   mspFlag=$1 #是否请求server 产生对应的msp/tls
   for i in ${org_n[@]}; do
    org_admin_name=$org_common_admin_name$org_pre_name$i.$common_dns
    org_name=$org_pre_name$i.$common_dns
    orgN=$org_pre_name$i
    affiliation=$common_dns_last.$org_pre_name$i
    for pi in ${peer_n[@]}; do
        peer_personal_name=$peer_pre_name$pi 
        peerFileName=$peer_personal_name.$org_name
        createPeersDir $peerFileName/mspdata
        createPeersDir $peerFileName/tlsdata
        echo " mkdir $peerFileName/mspdata and $peerFileName/tlsdata ------done-----"
        host=$peer_personal_name.$org_name
        name=$peer_personal_name.$org_name
        createPeerFile $name $host $affiliation $peerFileName/mspdata/$outfilename $msp_url_port $orgN $name
        createPeerFile $name $host $affiliation $peerFileName/tlsdata/$outfilename $tls_url_port $orgN $name
        echo " mk file $peerFileName/mspdata/$outfilename and $peerFileName/tlsdata/$outfilename ------done-----"
        if [ $mspFlag == true ]; then
            registerMsp $name $peerFileName $outfilename $org_admin_name $org_pwd $org_name
        fi
    done
   done  
}

# 生成 orderer 的目录
#包括msp tls的
function createOrderersDir(){
    createDir $1
}
#生成 orderer 的yaml
#包括 msp tls 的
function createOrdererFile(){
    createOrdererContent $1 $2 $3 $4 $5 $6 $7
}
# orderer 注册登录
function createOrderer(){
   outfilename=fabric-ca-client-config.yaml
   mspFlag=$1 #是否请求server 产生对应的msp/tls
   for i in ${orderer_n[@]}; do
    orderer_name=$orderer_pre_name$i.$common_dns
    ordererN=$orderer_pre_name$i
    affiliation=$common_dns_last
   # for pi in ${peer_n[@]}; do
        #orderer_personal_name=$orderer_pre_name$i 
        ordererFileName=$orderer_name
        createOrderersDir $ordererFileName/mspdata
        createOrderersDir $ordererFileName/tlsdata
        echo " mkdir $ordererFileName/mspdata and $ordererFileName/tlsdata ------done-----"
        host=$orderer_name
        name=$orderer_name
        createOrdererFile $name $host $affiliation $ordererFileName/mspdata/$outfilename $msp_url_port $ordererN $name
        createOrdererFile $name $host $affiliation $ordererFileName/tlsdata/$outfilename $tls_url_port $ordererN $name
        echo " mk file $ordererFileName/mspdata/outfilename and $ordererFileName/tlsdata/outfilename -----done------"

        if [ $mspFlag == true ]; then
            registerMsp $name $ordererFileName $outfilename $orderer_admin_name$common_dns $orderer_admin_pwd $orderer_name
        fi
   # done
   done  
}

### orderer的管理员 只有一个

# 生成 orderer的管理员证书 top 的目录
#包括msp tls的
function createTopDir(){
    createDir $1
}
#生成 orderer的管理员证书 的yaml
#包括 msp tls 的
function createTopFile(){
    createTopConfig $1 $2 $3 $4 $5
}

#orderer的管理员证书 函数弄成了 多个orderer管理员 根据orderer而定了
#有问题的...
function createTop(){
   ordererNum=${#orderer_n[@]} 
   topNum=${#top_n[@]}
   if [ ordererNum -ne topNum ]; then 
    echo "Error: can not generate orderer's admin cert; ordererNum not equal topNum!!!"
    return
   fi
   mspFlag=$1 #是否请求server 产生对应的msp/tls
   outfilename=fabric-ca-client-config.yaml
   for ((i=0;i<topNum;i++))
   {
        ordererIndex=${orderer_n[i]}
        topIndex=${top_n[i]}
        ordererFName=$orderer_pre_name$ordererIndex
        top_name=$top_pre_name$topIndex@$common_dns
        topN=$top_pre_name$topIndex
        affiliation=$common_dns_last
        topFileName=$top_name
        createTopDir $topFileName/mspdata
        createTopDir $topFileName/tlsdata
        echo " mkdir $topFileName/mspdata and $topFileName/tlsdata -----done------"
        host=$ordererFName.$common_dns
        name=$topFileName
        createTopFile $name $host $affiliation $topFileName/mspdata/$outfilename $msp_url_port 
        createTopFile $name $host $affiliation $topFileName/tlsdata/$outfilename $tls_url_port 
        echo " mk file $topFileName/mspdata/$outfilename and $topFileName/tlsdata/$outfilename ------done-----"

        if [ $mspFlag == true ]; then
            registerMsp $name $topFileName $outfilename $caName $caPwd ""
        fi
   }

}

# 正确的一个 orderer管理员 注册登录
function createOrdererAdmin(){
    mspFlag=$1 #是否请求server 产生对应的msp/tls
    outfilename=fabric-ca-client-config.yaml
    affiliation=$common_dns_last
    ordererAdminName=$orderer_admin_name$common_dns
    topFileName=$ordererAdminName
    createTopDir $topFileName/mspdata
    createTopDir $topFileName/tlsdata
    echo " mkdir $topFileName/mspdata and $topFileName/tlsdata -----done------"
    host=$orderer_admin_host
    name=$topFileName
    createTopFile $name $host $affiliation $topFileName/mspdata/$outfilename $msp_url_port 
    createTopFile $name $host $affiliation $topFileName/tlsdata/$outfilename $tls_url_port 
    echo " mk file $topFileName/mspdata/$outfilename and $topFileName/tlsdata/$outfilename ------done-----"

    if [ $mspFlag == true ]; then
        registerMsp $name $topFileName $outfilename $caName $caPwd ""
    fi
}


# 可以单独产生 执行各各部分
# 参数2 为是否产生对应的msp/tls证书
# createOrg
if [ ! -n "$1" ]; then
    echo "should input clear/org/orderer/peer/all,one of them"
    exit
fi
askFlag=false
if [ -n "$2" ]; then
    if [ $2 ]; then
        askFlag=true
    fi
fi
echo "---------------is $askFlag -----------"
if [ $1 == "clear" ]; then
    clear ./
elif [ $1 == "org" ]; then
    createOrg $askFlag
elif [ $1 == "orderer" ]; then
    createOrderer $askFlag
elif [ $1 == "peer" ]; then 
    createPeer $askFlag
elif [ $1 == "top" ]; then
    createTop $askFlag
elif [ $1 == "all" ]; then
    clear ./
    createOrdererAdmin $askFlag
    createOrg $askFlag
    createOrderer $askFlag
    createPeer $askFlag
elif [ $1 == "admin" ]; then
    createOrdererAdmin $askFlag
else
    echo "not equal any command"
fi
