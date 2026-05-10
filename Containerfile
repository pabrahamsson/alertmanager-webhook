FROM quay.io/hummingbird/rust:1.95-builder@sha256:fbfd60e37b5d836165e0fe6089265fe24c4fc1e5007b124c90b481192dd5fb54 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:4522e91744debce46fc565b9e4aa6270198bae74983a9a567cf46eadd63e7f42
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
