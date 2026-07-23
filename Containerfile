FROM quay.io/hummingbird/rust:1.97-builder@sha256:ef54124d698b67c7fc6cde0e269378897156faab32071ea3761e6ca1e8925b26 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:7a747fd4c3712efe08bf964e1cd2b36f7f07b63e5d4120b6abd5f10e2422aa7f
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
