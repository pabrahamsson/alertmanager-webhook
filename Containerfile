FROM quay.io/hummingbird/rust:1.99-builder@sha256:0d21efa39a1a1c2a4a5fd383e7f4a70bda70c7d0c3ec17d2462a3100f7d2cdc7 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:63f4a40bec465bffd8360c7e10006e363a1d45a833b65a1d9c631dc4a8366f30
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
