FROM quay.io/hummingbird/rust:1.97-builder@sha256:5f9ce5a9651efa80cadfaa646bb9f87da323bea4815eb6af6bc0484efbcf827d AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:a54ed9c927de64cdbc170d7c9635c8ea179080741644aa4c4c6ee220126338ed
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
