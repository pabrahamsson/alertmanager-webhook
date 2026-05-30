FROM quay.io/hummingbird/rust:1.95-builder@sha256:8d9088785c080874a1e5caf69845cb0c90b488c7111e037e2f06938d07feba25 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:66e6da58d07201cf30a48b4f049c98c993511d220099ff42fcec17ffcb6d9013
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
