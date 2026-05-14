FROM quay.io/hummingbird/rust:1.95-builder@sha256:c40bf2f0a3bb871af37730d3056815a19b4c6dff455c29f67e599f55e041a6be AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:9b61a96493c47b19e3bfef7f2383eb874f37b93d98c1895bac31b3803903b9a3
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
