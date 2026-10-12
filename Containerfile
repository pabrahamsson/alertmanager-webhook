FROM quay.io/hummingbird/rust:1.98-builder@sha256:d0f1bc961cf97407172c3cf92f2dda92ee0863379a87a30b6c0a81beecf5f603 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:3c8ae34f0e9d7cb41839e4f64f753934820d1f1eabf83216b310cfca7c19c07b
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
