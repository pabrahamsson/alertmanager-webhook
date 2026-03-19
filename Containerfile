FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1773895769@sha256:fa956af586b367c3366ac4376c3ee42a1141792b482e77d57aefb813f740f04d as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1773895769@sha256:fa956af586b367c3366ac4376c3ee42a1141792b482e77d57aefb813f740f04d
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
