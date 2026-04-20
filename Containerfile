FROM quay.io/hummingbird/rust:1.95-builder@sha256:52ca97edc02b048149918e673d5bc290ef9a099aa74f40ad5de2ad3f31ca56c8 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:f1796c60b2c28225fb537671b1d98efdf258ca2e5869694dbdd0c2289dcba781
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
