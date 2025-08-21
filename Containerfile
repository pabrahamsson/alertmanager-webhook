FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1755721767@sha256:d8cba62fbd44610595a6ce7badd287ca4c9985cbe9df55cc9b6a5c311b9a46e6 as builder
WORKDIR /usr/src/app
COPY Cargo.* .
COPY src/ src
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  source "$HOME/.cargo/env" && \
  microdnf update -y && \
  microdnf install -y openssl-devel gcc perl && \
  cargo build --release

FROM registry.access.redhat.com/ubi10/ubi-minimal:10.0-1755721767@sha256:d8cba62fbd44610595a6ce7badd287ca4c9985cbe9df55cc9b6a5c311b9a46e6
COPY --from=builder /usr/src/app/target/release/alertmanager-webhook /usr/local/bin/alertmanager-webhook
ENTRYPOINT ["alertmanager-webhook"]
