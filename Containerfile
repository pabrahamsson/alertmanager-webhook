FROM quay.io/hummingbird/rust:1.96-builder@sha256:e1af43bcaf589c02c34b79f4a407afa5f19dc9d9a60ea243ea7267e6513d270a AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:c1776a83747321d49907284e8d6161f9ca0e7c3e025bb7bddb1197a5b4bc9286
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
