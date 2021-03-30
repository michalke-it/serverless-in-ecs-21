ARCH=$(uname -m)
case "${ARCH}" in
    x86_64*)
        machine=amd64
        CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -a -tags netgo \
	-installsuffix netgo -ldflags "-s -w"
    ;;
    aarch64*)
        machine=arm64
        CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -v -a -tags netgo \
	-installsuffix netgo -ldflags "-s -w"
    ;;
    *)          exit $ARCH
esac
