FROM quay.io/hummingbird/rust:1.95-builder@sha256:95ae4531bf25dd8be5ebeed892bbea29a5c4499a70165c3f3a55a4cc2dfb9d2c AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:18defe33ba9ff7ddee8c6790d3f9319bc706ed1e34b22c27b105fefbb462d119
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
