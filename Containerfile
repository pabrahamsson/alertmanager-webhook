FROM quay.io/hummingbird/rust:1.97-builder@sha256:ff0cbbbd5572de5223f30700f0e67d537d6ed2a98936db18387a992e96d140e1 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:01cd4bc79402d3b9e7785d458d318040963ff0fcfb3691203d40ad18de39f561
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
