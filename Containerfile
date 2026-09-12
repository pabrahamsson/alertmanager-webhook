FROM quay.io/hummingbird/rust:1.98-builder@sha256:cd932aadf1784109fca2885a7e65058bf67e46a1dfbec75707fafbeb583d90bf AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:b154dd97b580c74d63c5c790ef734537ef58dd1e9f5f279207221fc1a53867d0
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
