FROM quay.io/hummingbird/rust:1.95-builder@sha256:95ae4531bf25dd8be5ebeed892bbea29a5c4499a70165c3f3a55a4cc2dfb9d2c AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:b401f67b2924221a39766dfd0486ed391a7f700511182c879ed8541dee474112
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
