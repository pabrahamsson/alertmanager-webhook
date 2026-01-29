FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1769677092@sha256:f8c05e3c6d15fea32e59635477c0f690e6d4b88a81924e8619f369e57306b701 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1769677092@sha256:f8c05e3c6d15fea32e59635477c0f690e6d4b88a81924e8619f369e57306b701
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
