.PHONY: all clean test

all:
	make -C grpc all

clean:
	make -C grpc clean

test:
	go test ./...