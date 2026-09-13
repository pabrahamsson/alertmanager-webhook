FROM quay.io/hummingbird/rust:1.97-builder@sha256:35be8de5c66b03e83a03d836303c4e50886123606e405b7ba77fb0bb0f497325 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:172193391ba9d05a1645495417f1df9405e2e42b14b6cdd7a463433c4acaba65
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
