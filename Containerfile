FROM quay.io/hummingbird/rust:1.99-builder@sha256:6a1f42faec4b9e48a9d9e355e58a762f8fd0774364cd78c8b06404202ee1e6b9 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:ca112849205bb517e36da872657e63f9297f6d25fd30342e54517289a840a4af
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
