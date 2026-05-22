FROM quay.io/hummingbird/rust:1.95-builder@sha256:42016c9d20545b019bbed62d75a93768a8e1f5504843e648a9671db386d706fd AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:39fc1f437dd49b9429fc195a73ad79599d9895e38e0b7e827abfa19c85d50d82
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
