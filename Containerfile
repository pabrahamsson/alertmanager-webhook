FROM quay.io/hummingbird/rust:1.95-builder@sha256:0add3808a6be62bd4e8764c955e397abcc86f1d7459f10eec24a83a25f912e73 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:0958ae0587c27d699e92161eeb5ddc58e1aa306970ca2f148756dde4d9c25cb1
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
