FROM quay.io/hummingbird/rust:1.95-builder@sha256:0a7e8b80663bf601f741221e10cea0c91fc30cda18ac6a1bc125af91d06610dd AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:39fc1f437dd49b9429fc195a73ad79599d9895e38e0b7e827abfa19c85d50d82
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
