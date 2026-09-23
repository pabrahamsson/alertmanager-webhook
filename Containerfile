FROM quay.io/hummingbird/rust:1.98-builder@sha256:e424d73b7c0a0227621bc0fead60127e7d6790a212d8b8ddabad9613d86597cb AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:23f35b6f892f48d97b686326618fa515e0c313666f5b0a3788e206f5ae44a257
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
