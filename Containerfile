FROM quay.io/hummingbird/rust:1.97-builder@sha256:ff0cbbbd5572de5223f30700f0e67d537d6ed2a98936db18387a992e96d140e1 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:edb396242b6d91adf5f0429a4b9e7f81fcd7dcd649d410da80d67693d83372e3
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
