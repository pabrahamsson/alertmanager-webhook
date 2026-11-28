FROM quay.io/hummingbird/rust:1.100-builder@sha256:d53aaa059348c857dd2f5edc802245fb6095c87c2b340295255638ba9459a82a AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:9c94f62cfb8e21a242c94a492f4491904e636d62fd87a329b2e1241bfd45fc2e
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
