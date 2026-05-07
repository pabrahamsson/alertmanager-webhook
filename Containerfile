FROM quay.io/hummingbird/rust:1.95-builder@sha256:bf98b38dab36dc549eb9b1201e59e30895580b5d4149a673d59d5028e7552e81 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:18defe33ba9ff7ddee8c6790d3f9319bc706ed1e34b22c27b105fefbb462d119
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
