FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1762952303@sha256:ebc9604c67aa5daa87cd431d64754a1cb6e22372446a6e8e0d966bfc709c9f3f as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1762952303@sha256:ebc9604c67aa5daa87cd431d64754a1cb6e22372446a6e8e0d966bfc709c9f3f
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
