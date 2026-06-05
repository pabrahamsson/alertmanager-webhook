FROM quay.io/hummingbird/rust:1.95-builder@sha256:6c9eb898c3b0ba9d9c9efe9b3368d96cfede890b1b65cc243d6e9669d5414987 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:66e6da58d07201cf30a48b4f049c98c993511d220099ff42fcec17ffcb6d9013
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
