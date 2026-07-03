FROM quay.io/hummingbird/rust:1.96-builder@sha256:e4895e3ff45a3ae915459cbedb77dbed4ffade06ea525fd0216196b64eee0b17 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:eec2bdc9562f4a439dc5c2b2beb275434804d32738fbae5b3a6b4366405b8716
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
