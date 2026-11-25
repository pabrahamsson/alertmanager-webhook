FROM quay.io/hummingbird/rust:1.100-builder@sha256:a3d2bf85a647d26d2a773db565a64224daea9fdb254f63e285e127a0ee12a916 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:9c94f62cfb8e21a242c94a492f4491904e636d62fd87a329b2e1241bfd45fc2e
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
