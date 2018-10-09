#!/bin/bash

#生成 对应的目录

BOOLFLAG=false
#清除 所以的目录 pwd下的
# 可有可无 参数 参数为路径
function clearPwdDir(){
    dirPath=""
    if test -z $1 
    then 
        dirPath=$PWD
    else
        if [ ! -d $1 ]; then 
            echo "Error 路径有误!!!"
            return 
        fi   
        dirPath=$1
    fi    
    echo "------------删除路径 $dirPath 下的所以目录------------"
    dirs=$(ls -l $dirPath |awk '/^d/ {print $NF}')
    for i in $dirs
    do
        echo "--------- delete $dirPath $i ------"
        rm -r $dirPath/$i
    done
}

# 删除某个目录或者文件夹
function deleteDirOrFile(){
    delString=$1
    isZeroStr $delString
    if $BOOLFLAG ; then 
        echo "want to delete dir or file is empty!!!"
        return
    fi
    if [ -d $delString ]; then 
        echo "------------- delete $delString dir ---------"
        rm -rf $delString
        return
    fi
    if [ -f $delString ]; then
        echo "------------- delete $delString file ---------"
        rm -rf $delString
        return
    fi
    echo "Delete $delString Failed!!!"
}

#生成对应的文件夹
function createDir() {
    dir=$1
    isZeroStr $dir
    if $BOOLFLAG ;then
        return
    fi
    if [ ! -d $dir ]; then
        echo "--------- create new diretory $dir ------------"
        mkdir -p $dir
    else 
        echo "---------- $dir diretory existed ------------"
        return
    fi
}

#判断参数 是否为空
function isZeroStr() {
    param=$1
    if test -z $param; then
        echo "Error: param is 0 Length!!!"
        BOOLFLAG=true
    fi
    BOOLFLAG=false
}

# C means clear
# d means delete
# c means create
#while getopts ":C:d:c:" opts; do
#    case $opts in
#        C)
#            clearPwdDir $OPTARG
#        ;;
#        d)
#            deleteDirOrFile $OPTARG
#        ;;
#        c)
#            createDir $OPTARG
#        ;;
#        ?)
#            echo "Error: invalide params!!!"
#        ;;
#        :)
#           echo "Error:Option -$OPTARG requires an argument."
#        ;;
#        esac
#done
