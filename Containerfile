FROM quay.io/hummingbird/rust:1.95-builder@sha256:52ca97edc02b048149918e673d5bc290ef9a099aa74f40ad5de2ad3f31ca56c8 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:da76fb15630dae70a3d04f2d88686f544cc1a21156a2457cb7a6a94ea323c051
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
