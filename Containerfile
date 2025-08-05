FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1754373924@sha256:c07753b82a485973c441b2dfefb909ff17486409f49a1800a30e9ea4f104aeb9 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1754373924@sha256:c07753b82a485973c441b2dfefb909ff17486409f49a1800a30e9ea4f104aeb9
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
