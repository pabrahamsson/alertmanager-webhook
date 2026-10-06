FROM quay.io/hummingbird/rust:1.98-builder@sha256:35d169964eb50c2f8ef40b70854cc10d60b013f79b9c8ce95eb0dcfca1a01b08 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:63ee017519dd918294cce39f4957322c13bc7ac6f206a389bb670c8bf6e34111
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
