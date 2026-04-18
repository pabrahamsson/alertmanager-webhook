FROM quay.io/hummingbird/rust:1.94-builder@sha256:f870fd06dc9684c44ce1e2e9827e92b0432c3c150ddb58c1945e19bcca9f81ef AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:f1796c60b2c28225fb537671b1d98efdf258ca2e5869694dbdd0c2289dcba781
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
