.PHONY: run upx clean clean-db test docker

TARGET = bin/ohana

all: clean test $(TARGET) upx

$(TARGET): $(shell find . -name '*.go')
	mkdir -p bin
	GOOS=linux go build -tags osusergo,netgo \
		-ldflags " \
			-extldflags=-static \
			-X main.BuildTime=`date -uIs` \
			-X main.GitCommit=`git rev-parse HEAD 2>/dev/null` \
		" \
		-o $(TARGET) \
		cmd/ohana/main.go

upx: $(TARGET)
	-upx $(TARGET)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf $(TARGET)
	rm -rf coverage.*

test:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

docker:
	docker build -f ./.docker/Dockerfile -t ohana .
