FROM quay.io/hummingbird/rust:1.99-builder@sha256:7fb5bd9de67d1d9d25134e63da16646a898203584d2a78d1f2550c1124ad2a3f AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:7be9c91a677f1c9bb3b781caa2fde634828ba21f7f93de8e406376a2bae5198c
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
