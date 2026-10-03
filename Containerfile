FROM quay.io/hummingbird/rust:1.98-builder@sha256:b0a7c2412cb683e80eb8581b714d7fb675c2c0dd7e1c93656a099776288b2864 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:23f35b6f892f48d97b686326618fa515e0c313666f5b0a3788e206f5ae44a257
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
