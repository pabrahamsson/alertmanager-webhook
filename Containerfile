FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1774228210@sha256:c858c2eb5bd336d8c400f6ee976a9d731beccf3351fa7a6f485dced24ae4af17 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1774228210@sha256:c858c2eb5bd336d8c400f6ee976a9d731beccf3351fa7a6f485dced24ae4af17
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
