FROM quay.io/hummingbird/rust:1.100-builder@sha256:40363e092771aac75aa0980f1c46561621a7e0c30f68ab67aa7ce7309ec740eb AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:6175dc80fce7cbf6d853e332ba9111b98c1561c31958ca77f40ff5735f123638
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
