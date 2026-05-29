FROM quay.io/hummingbird/rust:1.95-builder@sha256:8e574406152d3233613c6911e3fe36ea35d9be671f8d88c66b660a542a07a713 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:66e6da58d07201cf30a48b4f049c98c993511d220099ff42fcec17ffcb6d9013
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
