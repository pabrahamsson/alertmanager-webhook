FROM quay.io/hummingbird/rust:1.99-builder@sha256:63752211b4a793e07b19afa72c5ea1c225a4caef2b3428b2412caf5b2c4f57a0 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:79e013e632ca2acd397fdcae10c3c89658e58b059ee0f4364296e7d197b5bc70
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
