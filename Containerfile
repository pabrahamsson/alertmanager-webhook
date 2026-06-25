FROM quay.io/hummingbird/rust:1.96-builder@sha256:a8be3f5e5d66917fd9670dd0e6dcd9ad3de156ab4862dea54959e29c3a62437b AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:607a1240d18ea0b34b5b012b1397559945a8617f04635105ff35158b7b942e46
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
