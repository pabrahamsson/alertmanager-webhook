FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1752072397@sha256:d73cdd31faa42d8de8596791b9a85940151d87b0c7c19e3a28af2d93051fd014 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1752072397@sha256:d73cdd31faa42d8de8596791b9a85940151d87b0c7c19e3a28af2d93051fd014
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
