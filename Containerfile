FROM quay.io/hummingbird/rust:1.99-builder@sha256:76116908bf373a90122fabbb5d3901862191dd55b0f4b49fcd1e0f608027d4a4 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:79e013e632ca2acd397fdcae10c3c89658e58b059ee0f4364296e7d197b5bc70
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
