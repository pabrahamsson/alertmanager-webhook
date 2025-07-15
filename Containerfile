FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1752560555@sha256:616d066e8ab37ec914f8628823cba7cafd14b6496801ebcdfa73ff1491a5b744 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1752560555@sha256:616d066e8ab37ec914f8628823cba7cafd14b6496801ebcdfa73ff1491a5b744
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
