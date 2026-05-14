FROM quay.io/hummingbird/rust:1.95-builder@sha256:0a7e8b80663bf601f741221e10cea0c91fc30cda18ac6a1bc125af91d06610dd AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:9b61a96493c47b19e3bfef7f2383eb874f37b93d98c1895bac31b3803903b9a3
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
