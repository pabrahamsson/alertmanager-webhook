FROM quay.io/hummingbird/rust:1.98-builder@sha256:ef9431f16a115973a22e6cdeaf21490dc0c266269da370433bb1e79fdf89d5af AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:d3de94814037a9bf36448d1520dc2f09d496b6d4ee5db4067fc419737b9d0123
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
