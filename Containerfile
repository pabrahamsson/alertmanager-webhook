FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1776071394@sha256:7fabf2ff42ba1c2b3e4efcdd9ae25de0bce0592edf59151b41e58057b40898ce as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1776071394@sha256:7fabf2ff42ba1c2b3e4efcdd9ae25de0bce0592edf59151b41e58057b40898ce
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
