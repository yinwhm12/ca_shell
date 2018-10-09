#!/bin/bash

## 生成对应的 fabric-ca-client-config.yaml (统一名字)

. ./conf.sh

#生成 admin类型的 client 配置
function createOrgAdminClientConfig(){
    Name=$1
    Host=$2
    Affiliation=$3
    Out=$4
    UrlAndPort=$5
    _o=$6 
    _cn=$7
    touch $Out # fabric-ca-client-config.yaml
    echo "
url: $UrlAndPort

mspdir: $mspdir

tls:
  certfiles:
  client:
    certfile:
    keyfile:

csr:
  cn: $_cn
  serialnumber:
  names:
    - C: $org_csr_c
      ST: $org_csr_st
      L: $org_csr_l
      O: $_o
      OU: $org_crs_ou
  hosts:
    - $Host

id:
   name: $Name
   type: $org_type
   affiliation: $Affiliation
   maxenrollments: 0
   attributes:
     - name: hf.Registrar.Roles
       value: client,orderer,peer,user
     - name: hf.Registrar.DelegateRoles
       value: client,orderer,peer,user
     - name: hf.Registrar.Attributes
       value: \"*\"
     - name: hf.GenCRL
       value: true
     - name: hf.Revoker
       value: true
     - name: hf.AffiliationMgr
       value: true
     - name: hf.IntermediateCA
       value: true
     - name: role
       value: admin
       ecert: true

enrollment:
  profile:
  label:

caname:

bccsp:
    default: SW
    sw:
        hash: SHA2
        security: 256
        filekeystore:
            keystore: msp/keystore" > $Out
}

#产生 peer 类型
function createPeerContent() {
    Name=$1
    Host=$2
    Affiliation=$3
    Out=$4
    UrlAndPort=$5
    _o=$6
    _cn=$7
    touch $Out
    echo "
url: $UrlAndPort


mspdir: $mspdir

tls:
  certfiles: $peer_tls_certfiles
  client:
    certfile: $peer_tls_client_certfile
    keyfile: $peer_tls_client_keyfile

csr:
  cn: $_cn
  serialnumber: $peer_csr_serialnumber
  names:
    - C: $peer_csr_c
      ST: $peer_csr_st
      L: $peer_csr_l
      O: $_o
      OU: $peer_csr_ou
  hosts:
    - $Host

id:
  name: $Name
  type: $peer_type
  affiliation: $Affiliation
  maxenrollments: 0
  attributes:
      - name: role
        value: $peer_type
        ecert: true

enrollment:
  profile: $peer_enrollment_profile
  label: $peer_enrollment_label

caname:

bccsp:
    default: $peer_bccsp_default
    sw:
        hash: $peer_bccsp_sw_hash
        security: $peer_bccsp_sw_security
        filekeystore:
            keystore: $peer_keystore" > $Out
}

#产生 orderer类型
function createOrdererContent() {
    Name=$1
    Host=$2
    Affiliation=$3
    Out=$4
    UrlAndPort=$5
    _o=$6
    _cn=$7
    touch $Out
    echo "
url: $UrlAndPort


mspdir: $mspdir

tls:
  certfiles: $orderer_tls_certfiles
  client:
    certfile: $orderer_tls_client_certfile
    keyfile: $orderer_tls_client_keyfile

csr:
  cn: $_cn
  serialnumber: $orderer_csr_serialnumber
  names:
    - C: $orderer_csr_c
      ST: $orderer_csr_st
      L: $orderer_csr_l
      O: $_o
      OU: $orderer_csr_ou
  hosts:
    - $Host

id:
  name: $Name
  type: $orderer_type
  affiliation: $Affiliation
  maxenrollments: 0
  attributes:
      - name: role
        value: $orderer_type
        ecert: true

enrollment:
  profile: $orderer_enrollment_profile
  label: $orderer_enrollment_label

caname:

bccsp:
    default: $orderer_bccsp_default
    sw:
        hash: $orderer_bccsp_sw_hash
        security: $orderer_bccsp_sw_security
        filekeystore:
            keystore: $orderer_keystore" > $Out
}

#生成 admin类型的 client 配置
function createTopConfig(){
    Name=$1
    Host=$2
    Affiliation=$3
    Out=$4
    UrlAndPort=$5
    touch $Out # fabric-ca-client-config.yaml
    echo "
url: $UrlAndPort


mspdir: $mspdir

tls:
  certfiles:
  client:
    certfile:
    keyfile:

csr:
  cn: $top_csr_cn
  serialnumber:
  names:
    - C: $top_csr_c
      ST: $top_csr_st
      L: $top_csr_l
      O: $top_csr_o
      OU: $top_crs_ou
  hosts:
    - $Host

id:
   name: $Name
   type: $top_type
   affiliation: $Affiliation
   maxenrollments: 0
   attributes:
     - name: hf.Registrar.Roles
       value: client,orderer,peer,user
     - name: hf.Registrar.DelegateRoles
       value: client,orderer,peer,user
     - name: hf.Registrar.Attributes
       value: \"*\"
     - name: hf.GenCRL
       value: true
     - name: hf.Revoker
       value: true
     - name: hf.AffiliationMgr
       value: true
     - name: hf.IntermediateCA
       value: true
     - name: role
       value: admin
       ecert: true

enrollment:
  profile:
  label:

caname:

bccsp:
    default: SW
    sw:
        hash: SHA2
        security: 256
        filekeystore:
            keystore: msp/keystore" > $Out
}

