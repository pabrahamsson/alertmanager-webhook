FROM quay.io/hummingbird/rust:1.96-builder@sha256:a8be3f5e5d66917fd9670dd0e6dcd9ad3de156ab4862dea54959e29c3a62437b AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:a0b94b18a66a20827b3f06032f01ba8e96303aead479a9356b7fa4a6af9d89f0
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
