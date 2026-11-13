FROM quay.io/hummingbird/rust:1.99-builder@sha256:7fb5bd9de67d1d9d25134e63da16646a898203584d2a78d1f2550c1124ad2a3f AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:ca112849205bb517e36da872657e63f9297f6d25fd30342e54517289a840a4af
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
