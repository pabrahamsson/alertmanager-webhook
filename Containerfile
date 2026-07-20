FROM quay.io/hummingbird/rust:1.97-builder@sha256:ef54124d698b67c7fc6cde0e269378897156faab32071ea3761e6ca1e8925b26 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:b9147692d67ce65e9b6b8a840b855a2c40d2b6323bc5a5e186ed0219a371e84e
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
