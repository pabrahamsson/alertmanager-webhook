FROM quay.io/hummingbird/rust:1.99-builder@sha256:5062396309f344f443eb7f26cffd70108f83d852fe5b16cd44da3fe8ac68a4b0 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:79e013e632ca2acd397fdcae10c3c89658e58b059ee0f4364296e7d197b5bc70
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
