FROM quay.io/hummingbird/rust:1.96-builder@sha256:52120609ffe5746997d50074a5b8f1bd212fd112d5805669d6d6754ac038ea37 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:03dcff5be98fdccad9d18bb1e36e924a24e3f85d9c328d3cdbcb6e173e426b47
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
