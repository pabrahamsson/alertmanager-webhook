FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1750783441@sha256:ed9c42c1ab3144be1ad8a955e393fee25e38fe51b8a2022268af40e2c7bde712 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1750783441@sha256:ed9c42c1ab3144be1ad8a955e393fee25e38fe51b8a2022268af40e2c7bde712
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
