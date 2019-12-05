

#INC= -I. 

INC=" -I/usr/local/include "
INC+=" -I. "
INC+=-I"$GOPATH/src "
INC+=-I"$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis" 

function go_gen {
  protoc  --go_out=plugins=grpc:. $1
}

function gw_gen {
  protoc  --grpc-gateway_out=logtostderr=true:. $1
}

function sw_gen {
  protoc  --swagger_out=logtostderr=true:. $1
}

P=myservice/myservice.proto 

go_gen $P
gw_gen $P
sw_gen $P

# # echo generate gateway

# protoc -I/usr/local/include -I. \
#   -I"$GOPATH/src" \
#   -I"$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis" \
#   --grpc-gateway_out=logtostderr=true:. \
#   myservice/myservice.proto

# protoc -I/usr/local/include -I. \
#   -I"$GOPATH/src" \
#   -I"$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis" \
#   --swagger_out=logtostderr=true:. \
#   myservice/myservice.proto

