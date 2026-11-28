FROM quay.io/hummingbird/rust:1.100-builder@sha256:f48e6b5ed770420aa6ca0d30de66811bf03a631c09fa50b6890f6fad6b9492ce AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:9c94f62cfb8e21a242c94a492f4491904e636d62fd87a329b2e1241bfd45fc2e
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
