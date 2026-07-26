FROM quay.io/hummingbird/rust:1.97-builder@sha256:358b034d8bfc858cbd0e5085c77520190b85c306042e21d13cf3edb6a9115139 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:7a747fd4c3712efe08bf964e1cd2b36f7f07b63e5d4120b6abd5f10e2422aa7f
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
