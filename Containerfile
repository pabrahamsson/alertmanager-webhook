FROM quay.io/hummingbird/rust:1.97-builder@sha256:ff0cbbbd5572de5223f30700f0e67d537d6ed2a98936db18387a992e96d140e1 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:2a8be10ae34dac43d07ff622bc6db1a717d82e106a6ed58d99f198549ba12b31
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
