FROM quay.io/hummingbird/rust:1.99-builder@sha256:37ade0ed12e36eccd5d782bfe6ecd2edcff37a58a0c40a33f542df9c7c96e4a7 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:5310dc2962780574bdb0b2a8a0c8c0274a0a55db089baa0bd5cd59da50c3923b
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
