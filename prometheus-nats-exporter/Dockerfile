# Golang binary building stage
FROM golang:1.12

# download the source
WORKDIR /go/src/github.com/nats-io/prometheus-nats-exporter
COPY archtester.sh /
RUN git clone --branch v0.4.0 https://github.com/nats-io/prometheus-nats-exporter.git .

# build
RUN /archtester.sh

# Final docker image building stage
FROM scratch
COPY --from=0 /go/src/github.com/nats-io/prometheus-nats-exporter/prometheus-nats-exporter \
/prometheus-nats-exporter
EXPOSE 7777
ENTRYPOINT ["/prometheus-nats-exporter"]
CMD ["--help"]
