FROM quay.io/hummingbird/rust:1.95-builder@sha256:42016c9d20545b019bbed62d75a93768a8e1f5504843e648a9671db386d706fd AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:66e6da58d07201cf30a48b4f049c98c993511d220099ff42fcec17ffcb6d9013
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
