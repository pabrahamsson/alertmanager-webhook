FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1764604111@sha256:a13cec4e2e30fa2ca6468d474d02eb349200dc4a831c8c93f05a2154c559f09b as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1764604111@sha256:a13cec4e2e30fa2ca6468d474d02eb349200dc4a831c8c93f05a2154c559f09b
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
