FROM quay.io/hummingbird/rust:1.98-builder@sha256:1380b9324ba899ef2d80a132c8e97927eec02d3b0108f7ce7f3504b7e2bc58f2 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:23f35b6f892f48d97b686326618fa515e0c313666f5b0a3788e206f5ae44a257
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
