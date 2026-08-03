FROM quay.io/hummingbird/rust:1.97-builder@sha256:5f9ce5a9651efa80cadfaa646bb9f87da323bea4815eb6af6bc0484efbcf827d AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:ad1e14f51983a96c6fd86bec77f9f149686c415be28f3bb0d887b7bcd82b782e
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
