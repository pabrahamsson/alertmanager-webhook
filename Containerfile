FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1763362715@sha256:28ec2f4662bdc4b0d4893ef0d8aebf36a5165dfb1d1dc9f46319bd8a03ed3365 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.1-1763362715@sha256:28ec2f4662bdc4b0d4893ef0d8aebf36a5165dfb1d1dc9f46319bd8a03ed3365
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
