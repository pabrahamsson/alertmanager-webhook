FROM quay.io/hummingbird/rust:1.95-builder@sha256:1523bdd323e7f369431431517c654d0f8ce9bfbd92a0e9f5da3798be2d07b4b0 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:da76fb15630dae70a3d04f2d88686f544cc1a21156a2457cb7a6a94ea323c051
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
