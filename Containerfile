FROM quay.io/hummingbird/rust:1.99-builder@sha256:da59991f0e70606165ac27a05c98351ce12abf10a4ce9195ddf7512874bbe4c8 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:63ee017519dd918294cce39f4957322c13bc7ac6f206a389bb670c8bf6e34111
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
