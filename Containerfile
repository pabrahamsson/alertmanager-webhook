FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1772441549@sha256:29599cb2a44f3275232bc5fc48d26e069e8ba72b710229bed6652633725aa31a as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1772441549@sha256:29599cb2a44f3275232bc5fc48d26e069e8ba72b710229bed6652633725aa31a
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
