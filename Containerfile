FROM quay.io/hummingbird/rust:1.100-builder@sha256:a3d2bf85a647d26d2a773db565a64224daea9fdb254f63e285e127a0ee12a916 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:6175dc80fce7cbf6d853e332ba9111b98c1561c31958ca77f40ff5735f123638
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
