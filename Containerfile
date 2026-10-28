FROM quay.io/hummingbird/rust:1.99-builder@sha256:37ade0ed12e36eccd5d782bfe6ecd2edcff37a58a0c40a33f542df9c7c96e4a7 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:79e013e632ca2acd397fdcae10c3c89658e58b059ee0f4364296e7d197b5bc70
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
