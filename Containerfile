FROM quay.io/hummingbird/rust:1.99-builder@sha256:7f7e339bc1bd77bbda30b68d12de565280820082b02a1532c7fa3275f24e64a9 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:3c8ae34f0e9d7cb41839e4f64f753934820d1f1eabf83216b310cfca7c19c07b
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
