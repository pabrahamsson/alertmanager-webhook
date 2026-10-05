FROM quay.io/hummingbird/rust:1.98-builder@sha256:35d169964eb50c2f8ef40b70854cc10d60b013f79b9c8ce95eb0dcfca1a01b08 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:f3e0afd0eb63bcd0a3a25e2157725e40e98cc1bdb6aafa783a1ca5e94f6b6fc9
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
