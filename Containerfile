FROM quay.io/hummingbird/rust:1.98-builder@sha256:ca67ad5eefdb374482738928dacb50d99a6ae6a54ac49e12fb7305bd1c9ade8e AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:23f35b6f892f48d97b686326618fa515e0c313666f5b0a3788e206f5ae44a257
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
