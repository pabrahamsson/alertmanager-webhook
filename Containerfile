FROM quay.io/hummingbird/rust:1.95-builder@sha256:1bf97014f457f7ff55e6e8bbd095f8ce5ea886c0c6c884de37fcc07339bb22ca AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:b401f67b2924221a39766dfd0486ed391a7f700511182c879ed8541dee474112
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
