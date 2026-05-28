FROM quay.io/hummingbird/rust:1.95-builder@sha256:54a0f3f981a220b196cd0bbf8bef79e592b52db9038a8b70c656bbe0917a70d5 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:66e6da58d07201cf30a48b4f049c98c993511d220099ff42fcec17ffcb6d9013
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
