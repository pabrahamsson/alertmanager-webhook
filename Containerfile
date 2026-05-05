FROM quay.io/hummingbird/rust:1.95-builder@sha256:7207c864f676b7c59a1d3850aeb311fe6f5fc9dd7660094e12d6a764804b0b03 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:18defe33ba9ff7ddee8c6790d3f9319bc706ed1e34b22c27b105fefbb462d119
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
