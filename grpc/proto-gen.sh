#!/bin/bash

#
# protobuf codegen
#
INC=" -I/usr/local/include "
INC+=" -I. "
INC+=-I"$GOPATH/src "
INC+=-I"$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis " 

# generate go
function go_gen {
  protoc  --go_out=plugins=grpc:. $1
}

# generate gateway
function gw_gen {
  protoc  --grpc-gateway_out=logtostderr=true:. $1
}

# generate swagger
function sw_gen {
  protoc  --swagger_out=logtostderr=true:. $1
}

go_gen $1
gw_gen $1
sw_gen $1
