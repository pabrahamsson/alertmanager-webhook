FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1754585875@sha256:5a57b4c2509df8df587e19cc7c2d9cfa45b012139f5decd77f942daeb2334228 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1754585875@sha256:5a57b4c2509df8df587e19cc7c2d9cfa45b012139f5decd77f942daeb2334228
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
