FROM quay.io/hummingbird/rust:1.99-builder@sha256:cee080d2ff56345e3beaf3fa003e4f61163868d59fe311ae76616c13cbbc27c0 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:5310dc2962780574bdb0b2a8a0c8c0274a0a55db089baa0bd5cd59da50c3923b
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
