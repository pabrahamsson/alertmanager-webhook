FROM quay.io/hummingbird/rust:1.97-builder@sha256:aea6dc6cc564984488da79a98f1e1bbd82009535f0c304698b9c4e3b2ce35f21 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:ad1e14f51983a96c6fd86bec77f9f149686c415be28f3bb0d887b7bcd82b782e
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
