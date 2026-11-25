FROM quay.io/hummingbird/rust:1.100-builder@sha256:40363e092771aac75aa0980f1c46561621a7e0c30f68ab67aa7ce7309ec740eb AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:9c94f62cfb8e21a242c94a492f4491904e636d62fd87a329b2e1241bfd45fc2e
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
