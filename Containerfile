FROM quay.io/hummingbird/rust:1.96-builder@sha256:bbd522a6ae241c7a5b6f844cbf1c68828c47af222e8f038615390bf9826cd864 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:03dcff5be98fdccad9d18bb1e36e924a24e3f85d9c328d3cdbcb6e173e426b47
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
