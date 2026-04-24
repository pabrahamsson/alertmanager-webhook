FROM quay.io/hummingbird/rust:1.95-builder@sha256:1523bdd323e7f369431431517c654d0f8ce9bfbd92a0e9f5da3798be2d07b4b0 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:f1796c60b2c28225fb537671b1d98efdf258ca2e5869694dbdd0c2289dcba781
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
