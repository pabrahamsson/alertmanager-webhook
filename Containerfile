FROM quay.io/hummingbird/rust:1.96-builder@sha256:bbd522a6ae241c7a5b6f844cbf1c68828c47af222e8f038615390bf9826cd864 AS builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN dnf install -y openssl-devel gcc && \
  dnf clean all && \
  cargo build --release

FROM quay.io/hummingbird/core-runtime:latest-openssl@sha256:eec2bdc9562f4a439dc5c2b2beb275434804d32738fbae5b3a6b4366405b8716
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
