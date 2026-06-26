FROM quay.io/hummingbird/rust:1.96-builder@sha256:858ad153361b3a1d77b78a57749a784b1a861ba95d5953574c6be859da949595 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:c2f7eef918f0fbf1670e72ac7ca95f21b8ae8f40d832860b2c77e5806ca69be9
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
