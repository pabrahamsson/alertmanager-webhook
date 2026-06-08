FROM quay.io/hummingbird/rust:1.96-builder@sha256:72eee71352cab79d579ee9b5accf0afb763334131157eb242aba4d0970fc3500 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:312527c9348a4ce52869a8852eb7d924df9475e12dfd735fe59a14bdd506a789
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
