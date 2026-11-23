FROM quay.io/hummingbird/rust:1.100-builder@sha256:04303ce3a60df5fdb8d3f0effdc2b2f1946d8eb85e0ea58075a89c31c96757f3 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:6175dc80fce7cbf6d853e332ba9111b98c1561c31958ca77f40ff5735f123638
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
