FROM quay.io/hummingbird/rust:1.100-builder@sha256:40363e092771aac75aa0980f1c46561621a7e0c30f68ab67aa7ce7309ec740eb AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:ca112849205bb517e36da872657e63f9297f6d25fd30342e54517289a840a4af
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
