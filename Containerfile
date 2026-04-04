FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1774545417@sha256:7bd3d2e7f5c507aebd1575d0f2fab9fe3e882e25fee54fa07f7970aa8bbc5fab as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1774545417@sha256:7bd3d2e7f5c507aebd1575d0f2fab9fe3e882e25fee54fa07f7970aa8bbc5fab
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
