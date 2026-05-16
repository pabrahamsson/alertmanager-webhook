FROM quay.io/hummingbird/rust:1.95-builder@sha256:0add3808a6be62bd4e8764c955e397abcc86f1d7459f10eec24a83a25f912e73 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:39fc1f437dd49b9429fc195a73ad79599d9895e38e0b7e827abfa19c85d50d82
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
