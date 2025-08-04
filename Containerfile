FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1754275025@sha256:346be33bb06db10736e8eac2af9994ac91a4b69e4815b695dfaac67e2f4a7b6a as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1754275025@sha256:346be33bb06db10736e8eac2af9994ac91a4b69e4815b695dfaac67e2f4a7b6a
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
