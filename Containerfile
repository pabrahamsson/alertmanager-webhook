FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1758185635@sha256:53de6ac7c3e830b0ddfc9867ff6a8092785bcf156ab4e63dfa9af83c880fd988 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1758185635@sha256:53de6ac7c3e830b0ddfc9867ff6a8092785bcf156ab4e63dfa9af83c880fd988
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
