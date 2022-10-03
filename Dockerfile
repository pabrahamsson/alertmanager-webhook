FROM registry.access.redhat.com/ubi9/ubi-minimal:latest as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    source "$HOME/.cargo/env" && \
    microdnf update -y && \
    microdnf install -y openssl-devel gcc perl && \
    cargo build --release

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
