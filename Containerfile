FROM quay.io/hummingbird/rust:1.98-builder@sha256:ef9431f16a115973a22e6cdeaf21490dc0c266269da370433bb1e79fdf89d5af AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:172193391ba9d05a1645495417f1df9405e2e42b14b6cdd7a463433c4acaba65
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
