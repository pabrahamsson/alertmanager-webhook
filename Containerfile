FROM quay.io/hummingbird/rust:1.95-builder@sha256:bf98b38dab36dc549eb9b1201e59e30895580b5d4149a673d59d5028e7552e81 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:8fdff7b31bc696baa967bf899115a92266e455897549a29441d08ebaf09869f9
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
