FROM quay.io/hummingbird/rust:1.99-builder@sha256:0d21efa39a1a1c2a4a5fd383e7f4a70bda70c7d0c3ec17d2462a3100f7d2cdc7 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:c50e5da981b75c05b10ebb9ca9775481ad2822e28c9b8b4222de285098d529b2
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
