FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1751880071@sha256:da1aedf263c25c4d5a58bc9d44a6b9f973a217ed67cb7ad2e08ec2711e901eec as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1751880071@sha256:da1aedf263c25c4d5a58bc9d44a6b9f973a217ed67cb7ad2e08ec2711e901eec
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
