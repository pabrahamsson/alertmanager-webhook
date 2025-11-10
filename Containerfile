FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1762765041@sha256:e9b2b981488c404fbf576865db2022ad8693bc9102421117a1eecd60ce8035f5 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1762765041@sha256:e9b2b981488c404fbf576865db2022ad8693bc9102421117a1eecd60ce8035f5
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
