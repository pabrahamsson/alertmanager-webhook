FROM quay.io/hummingbird/rust:1.97-builder@sha256:ede93fa94099c45a97d5ff84655857ac80e733b19e1d21c65eddaa850b2531cd AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:b154dd97b580c74d63c5c790ef734537ef58dd1e9f5f279207221fc1a53867d0
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
