FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1753766430@sha256:ce6e336ca4c1b153e84719f9a123b9b94118dd83194e10da18137d1c571017fe as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1753766430@sha256:ce6e336ca4c1b153e84719f9a123b9b94118dd83194e10da18137d1c571017fe
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
