FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1769090502@sha256:2910fd7720d45c3cabc708c71a6ff6b98695e1d814b71547c9324c97a728ebef as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1769090502@sha256:2910fd7720d45c3cabc708c71a6ff6b98695e1d814b71547c9324c97a728ebef
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
