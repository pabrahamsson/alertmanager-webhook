FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1758699349@sha256:649f7ce8082531148ac5e45b61612046a21e36648ab096a77e6ba0c94428cf60 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1758699349@sha256:649f7ce8082531148ac5e45b61612046a21e36648ab096a77e6ba0c94428cf60
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
