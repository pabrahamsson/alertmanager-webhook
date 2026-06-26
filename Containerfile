FROM quay.io/hummingbird/rust:1.96-builder@sha256:90339b933eb33cae0c0caf061c8b93a1853afbf5b472684bb58586c7be2313b1 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:607a1240d18ea0b34b5b012b1397559945a8617f04635105ff35158b7b942e46
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
