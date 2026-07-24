FROM quay.io/hummingbird/rust:1.97-builder@sha256:ef54124d698b67c7fc6cde0e269378897156faab32071ea3761e6ca1e8925b26 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:ffa0ceac6f0842978d012089a69334afadc484376bf60655330ff43078fc951a
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
