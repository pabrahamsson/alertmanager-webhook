FROM quay.io/hummingbird/rust:1.99-builder@sha256:5062396309f344f443eb7f26cffd70108f83d852fe5b16cd44da3fe8ac68a4b0 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:7be9c91a677f1c9bb3b781caa2fde634828ba21f7f93de8e406376a2bae5198c
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
