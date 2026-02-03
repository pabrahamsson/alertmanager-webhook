FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1770052085@sha256:380da76bb8a69e333b6c11341d600f5d3aab9ee5b8c95ceb64aae2457f5c1c6e as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1770052085@sha256:380da76bb8a69e333b6c11341d600f5d3aab9ee5b8c95ceb64aae2457f5c1c6e
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
