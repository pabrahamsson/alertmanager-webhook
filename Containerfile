FROM quay.io/hummingbird/rust:1.95-builder@sha256:bf98b38dab36dc549eb9b1201e59e30895580b5d4149a673d59d5028e7552e81 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:db371895d480b269ce6ae06f2bb5a23e188d81db884e5608def5dc2d680d6b7d
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
