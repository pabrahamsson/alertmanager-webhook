FROM quay.io/hummingbird/rust:1.98-builder@sha256:76da8629c6d1e4e81a98ad76f68419bb7d2550c6828a8a7886ca863608df55f9 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:d3de94814037a9bf36448d1520dc2f09d496b6d4ee5db4067fc419737b9d0123
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
