FROM quay.io/hummingbird/rust:1.95-builder@sha256:1bf97014f457f7ff55e6e8bbd095f8ce5ea886c0c6c884de37fcc07339bb22ca AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:31a290cd6d5214600682268711a67198b11b7feee699c5eb5cf6b8f2151af24b
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
