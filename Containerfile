FROM quay.io/hummingbird/rust:1.98-builder@sha256:d0f1bc961cf97407172c3cf92f2dda92ee0863379a87a30b6c0a81beecf5f603 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:f3e0afd0eb63bcd0a3a25e2157725e40e98cc1bdb6aafa783a1ca5e94f6b6fc9
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
