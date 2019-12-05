
.PHONY: all
.DEFAULT_GOAL:=all	
all:
	./proto-gen.sh myservice/myservice.proto 
	./proto-gen.sh myvault/myvault.proto 

.PHONY: clean
clean:
	fd -e pb.go -e pb.gw.go -e swagger.json | xargs rm
