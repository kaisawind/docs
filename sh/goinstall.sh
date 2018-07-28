#!/bin/bash

goPath=$GOPATH
goEnvPath=$(go env GOPATH)

echo "GOPATH = $goPath"
echo "go env path = $(go env GOPATH)"

if [ "$goPath" == "" ]; then
    if [ "$goEnvPath" != "" ]; then
        goPath=$goEnvPath
    fi
fi

if [ "$goPath" == "" ]; then
    echo "go path is null"
    exit 1
else
    echo "go path is $goPath"
fi

# if goPath is not exit, we will create it
if [ ! -d "$goPath" ]; then
    ehco "$goPath is not exist, we will make it"
    mkdir -p "$goPath/bin"
    mkdir -p "$goPath/pkg"
    mkdir -p "$goPath/src"
    mkdir -p "$goPath/src/github.com"
    mkdir -p "$goPath/src/golang.org"

else # if goPath is exist
    echo "$goPath is exist"
    if [ ! -d "$goPath/bin" ]; then
        mkdir -p "$goPath/bin"
    else
        echo "$goPath/bin is exist"
    fi
    if [ ! -d "$goPath/pkg" ]; then
        mkdir -p "$goPath/pkg"
    else
        echo "$goPath/pkg is exist"
    fi
    if [ ! -d "$goPath/src" ]; then
        mkdir -p "$goPath/src"
        mkdir -p "$goPath/src/github.com"
        mkdir -p "$goPath/src/golang.org"
    else
        if [ ! -d "$goPath/src/github.com" ]; then
            mkdir -p "$goPath/src/github.com"
        else
            echo "$goPath/src/github.com is exist"
        fi
        if [ ! -d "$goPath/src/golang.org" ]; then
            mkdir -p "$goPath/src/golang.org"
        else
            echo "$goPath/src/golang.org is exist"
        fi
    fi
fi

echo "***********************************************"
echo "git clone something and it will take some times"
echo "***********************************************"

echo "****************golang.org/x*******************"
if [ ! -d "$goPath/src/golang.org/x" ]; then
    mkdir -p "$goPath/src/golang.org/x"
fi

cd "$goPath/src/golang.org"
pwd

echo "****************golang.org/x/tools*************"
if [ ! -d "$goPath/src/golang.org/x/tools" ]; then
    git clone git@github.com:golang/tools.git
else
    cd "$goPath/src/golang.org/x/tools"
    git pull
    cd ..
fi

echo "****************golang.org/x/sys*************"
if [ ! -d "$goPath/src/golang.org/x/sys" ]; then
    git clone git@github.com:golang/sys.git
else
    cd "$goPath/src/golang.org/x/sys"
    git pull
    cd ..
fi

echo "****************golang.org/x/text*************"
if [ ! -d "$goPath/src/golang.org/x/text" ]; then
    git clone git@github.com:golang/text.git
else
    cd "$goPath/src/golang.org/x/text"
    git pull
    cd ..
fi

echo "****************golang.org/x/net*************"
if [ ! -d "$goPath/src/golang.org/x/net" ]; then
    git clone git@github.com:golang/net.git
else
    cd "$goPath/src/golang.org/x/net"
    git pull
    cd ..
fi

echo "****************golang.org/x/lint*************"
if [ ! -d "$goPath/src/golang.org/x/lint" ]; then
    git clone git@github.com:golang/lint.git
else
    cd "$goPath/src/golang.org/x/lint"
    git pull
    cd ..
fi


echo "***********************************************"
echo "go get something and it will take some times"
echo "***********************************************"

go get -u -v github.com/mdempsky/gocode

go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs

go get -u -v github.com/derekparker/delve/cmd/dlv

go get -u -v github.com/rogpeppe/godef

go get -u -v github.com/ramya-rao-a/go-outline

go get -u -v github.com/acroca/go-symbols

go get -u -v golang.org/x/tools/cmd/guru

go get -u -v golang.org/x/tools/cmd/gorename

go get -u -v golang.org/x/tools/cmd/godoc

go get -u -v github.com/sqs/goreturns

go get -u -v github.com/golang/lint/golint


