FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1766033715@sha256:67aafc6c9c44374e1baf340110d4c835457d59a0444c068ba9ac6431a6d9e7ac as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1766033715@sha256:67aafc6c9c44374e1baf340110d4c835457d59a0444c068ba9ac6431a6d9e7ac
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
