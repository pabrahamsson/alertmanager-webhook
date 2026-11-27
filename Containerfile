FROM quay.io/hummingbird/rust:1.100-builder@sha256:f7e18e76d3fc1c899a625627a8815d1450fee5122fbc291c74fcbe191255a3ec AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:9c94f62cfb8e21a242c94a492f4491904e636d62fd87a329b2e1241bfd45fc2e
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
