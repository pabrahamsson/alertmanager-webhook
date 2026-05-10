FROM quay.io/hummingbird/rust:1.95-builder@sha256:5766e274f447561c5824a54f70634115bb7e2c647b041eb7f2e17823f553640d AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:4522e91744debce46fc565b9e4aa6270198bae74983a9a567cf46eadd63e7f42
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
