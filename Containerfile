FROM quay.io/hummingbird/rust:1.95-builder@sha256:6c9eb898c3b0ba9d9c9efe9b3368d96cfede890b1b65cc243d6e9669d5414987 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:312527c9348a4ce52869a8852eb7d924df9475e12dfd735fe59a14bdd506a789
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
