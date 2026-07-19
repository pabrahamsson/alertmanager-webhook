FROM quay.io/hummingbird/rust:1.96-builder@sha256:bbd522a6ae241c7a5b6f844cbf1c68828c47af222e8f038615390bf9826cd864 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:b9147692d67ce65e9b6b8a840b855a2c40d2b6323bc5a5e186ed0219a371e84e
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
