FROM quay.io/hummingbird/rust:1.95-builder@sha256:06f1ea013d1be46116f161be6b30900093cbc3b4b5654aea63488bf24ed9bb61 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:b401f67b2924221a39766dfd0486ed391a7f700511182c879ed8541dee474112
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
