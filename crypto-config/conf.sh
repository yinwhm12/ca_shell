#!/bin/bash

# 参数变量

#common 公有的配置
common_dns=example.com #域名
msp_url_port=http://localhost:7054
mspdir=msp
tls_url_port=http://localhost:7055
common_dns_last=com.example

caName=admin
caPwd=adminpw
commonPwd=adminpw #统一用的密码
msp_server_url=localhost
msp_server_port=7054

tls_server_url=localhost
tls_server_port=7055

#org 组织配置
org_n=(1 2)
org_pre_name=org
org_affiliation=com.example.$org_pre_name #com.example.org1 com.example.org2
org_type=client
org_csr_cn=admin
org_csr_c=US
org_csr_st=North
org_csr_l=""
org_csr_o=Hyperledger
org_csr_ou="" #org1
#org_hosts={$org_pre_name}1.$common_dns #org1.example.com
org_common_admin_name=Admin@ # Admin@org1.example.com
org_pwd=adminpw


#peer 配置
peer_n=(0 1) 
peer_pre_name=peer
peer_affiliation=com.example
peer_type=peer
peer_csr_cn=admin
peer_csr_serialnumber=""
peer_csr_c=US
peer_csr_st=North
peer_csr_l=""
peer_csr_o=Hyperledger
peer_csr_ou=""
peer_tls_certfiles=""
peer_tls_client_certfile=""
peer_tls_client_keyfile=""
peer_enrollment_profile=""
peer_enrollment_label=""
peer_bccsp_default=SW
peer_bccsp_sw_hash=SHA2
peer_bccsp_sw_security=256
peer_keystore=msp/keystore
#peer_csr_ou={$org_pre_name}1 #org1

#orderer 配置
orderer_n=(orderer) 
orderer_pre_name=""
orderer_affiliation=com.example
orderer_type=orderer
orderer_csr_cn=admin
orderer_csr_serialnumber=""
orderer_csr_c=US
orderer_csr_st=North
orderer_csr_l=""
orderer_csr_o=Hyperledger
orderer_csr_ou=""
orderer_tls_certfiles=""
orderer_tls_client_certfile=""
orderer_tls_client_keyfile=""
orderer_enrollment_profile=""
orderer_enrollment_label=""
orderer_bccsp_default=SW
orderer_bccsp_sw_hash=SHA2
orderer_bccsp_sw_security=256
orderer_keystore=msp/keystore

#orderer admin top 配置
#如 example.com的admin 似乎只有一个
top_n=(1 2 3 4)
top_pre_name=Admin
top_type=client
top_csr_cn=example.com
top_csr_c=US
top_csr_st=North_Carolina
top_csr_l=""
top_csr_o=example.com
top_csr_ou="" #org1


#orderer 管理员 仅仅有一个
orderer_admin_name=Admin@
orderer_admin_host=localhost
orderer_admin_pwd=adminpw
