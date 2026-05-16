FROM quay.io/hummingbird/rust:1.95-builder@sha256:0add3808a6be62bd4e8764c955e397abcc86f1d7459f10eec24a83a25f912e73 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:9b61a96493c47b19e3bfef7f2383eb874f37b93d98c1895bac31b3803903b9a3
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
