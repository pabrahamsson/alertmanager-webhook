FROM quay.io/hummingbird/rust:1.98-builder@sha256:b0a7c2412cb683e80eb8581b714d7fb675c2c0dd7e1c93656a099776288b2864 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:f3e0afd0eb63bcd0a3a25e2157725e40e98cc1bdb6aafa783a1ca5e94f6b6fc9
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
