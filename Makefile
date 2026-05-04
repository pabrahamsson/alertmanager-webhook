TAG?=alertmanager-webhook:latest
clean:
				cargo clean

debug:
				cargo build

release:
				cargo build -r

docker-debug-build: debug
				podman pull quay.io/hummingbird/core-runtime:latest-openssl
				podman build -t $(TAG) . -f Containerfile.local

docker-release-build: release
				podman pull quay.io/hummingbird/core-runtime:latest-openssl
				podman build -t $(TAG) . -f Containerfile.local --build-arg BUILD=release

docker-push:
				podman push $(TAG)

docker-debug: docker-debug-build docker-push

docker-release: docker-release-build docker-push
