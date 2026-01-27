FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1769521234@sha256:919a5a4c8595deb2f9c21b8a05ad027157f42feb6eed6b64efd1f4f455a5f759 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1769521234@sha256:919a5a4c8595deb2f9c21b8a05ad027157f42feb6eed6b64efd1f4f455a5f759
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
