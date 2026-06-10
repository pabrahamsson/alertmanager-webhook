FROM quay.io/hummingbird/rust:1.96-builder@sha256:e1af43bcaf589c02c34b79f4a407afa5f19dc9d9a60ea243ea7267e6513d270a AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:312527c9348a4ce52869a8852eb7d924df9475e12dfd735fe59a14bdd506a789
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
