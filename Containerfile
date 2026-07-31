FROM quay.io/hummingbird/rust:1.97-builder@sha256:aea6dc6cc564984488da79a98f1e1bbd82009535f0c304698b9c4e3b2ce35f21 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:edb396242b6d91adf5f0429a4b9e7f81fcd7dcd649d410da80d67693d83372e3
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
