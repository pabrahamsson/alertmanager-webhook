FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1752576249@sha256:4cfec88c16451cc9ce4ba0a8c6109df13d67313a33ff8eb2277d0901b4d81020 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1752576249@sha256:4cfec88c16451cc9ce4ba0a8c6109df13d67313a33ff8eb2277d0901b4d81020
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
