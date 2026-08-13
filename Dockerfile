# security-scanner-toolbox — trivy + grype + syft + cosign, pinned and
# multi-arch. One image for the whole scan/attest step in CI.
ARG TRIVY_VERSION=0.73.0
ARG GRYPE_VERSION=0.95.0
ARG SYFT_VERSION=1.28.0
ARG COSIGN_VERSION=2.5.3
# SHA-256 of each release's checksums.txt. Pinning the checksum file rather than
# per-arch binary digests keeps this to one constant per tool while still
# covering every architecture: the file is verified against the pin, then the
# downloaded binary is verified against the file.
#
# This image exists to verify other people's supply chains, so it cannot fetch
# its own tools on trust — least of all cosign, which is the thing users run to
# check everything else. Bump alongside the versions above.
# VERSION-BUMP
ARG TRIVY_CHECKSUMS_SHA256=36890275ffdff13025e9bd9fe039724c6e36bf58e698499856b801f619046fe2
# VERSION-BUMP
ARG GRYPE_CHECKSUMS_SHA256=0665f621dd856996232251bc6084657171b2c9438785fa3b75db32595a097c30
# VERSION-BUMP
ARG SYFT_CHECKSUMS_SHA256=4cf5750a220be81408b45ed26b35228b94b353ad176a815ac8e986d0145d87af
# VERSION-BUMP
ARG COSIGN_CHECKSUMS_SHA256=0b9d811bcc2e93d0eb7a61e515550b1948887718953cdcc6e518bca63fc10967

FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS fetch
ARG TRIVY_VERSION
ARG GRYPE_VERSION
ARG SYFT_VERSION
ARG COSIGN_VERSION
ARG TRIVY_CHECKSUMS_SHA256
ARG GRYPE_CHECKSUMS_SHA256
ARG SYFT_CHECKSUMS_SHA256
ARG COSIGN_CHECKSUMS_SHA256
ARG TARGETARCH=amd64
# pipefail matters twice over here. A failed download used to leave tar happily
# unpacking nothing, shipping an image without the tool — that is how the trivy
# 404 stayed invisible until a build broke. It now also makes the `awk | sha256sum`
# verification below fail closed when awk finds no line for the artifact.
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
# Eight release downloads follow, and any one of them dropping mid-transfer
# fails the whole build — CI hit exactly that (curl 56, "failure in receiving
# network data", on the grype tarball). curl reads ~/.curlrc on every
# invocation, so the retry policy sits here once instead of on eight command
# lines where it would drift. Retries are safe: every artifact is checksum-pinned
# below, so a repeated fetch still has to match its pin.
RUN apk add --no-cache curl ca-certificates \
 && printf '%s\n' \
      'retry = 5' \
      'retry-all-errors' \
      'retry-delay = 2' \
      'retry-max-time = 120' \
      'connect-timeout = 15' > /root/.curlrc

# verify <artifact> <checksums-file> <expected-sha256-of-checksums-file>
# Two steps, both fail closed: the checksums file must match its pin, then the
# artifact must match its line in that file. awk exits non-zero when the artifact
# is absent from the file, so a renamed or missing entry fails rather than passing
# silently on an empty check.
COPY verify-download /usr/local/bin/verify-download

RUN set -eu; \
    ARCH="$([ "$TARGETARCH" = "arm64" ] && echo ARM64 || echo 64bit)"; \
    f="trivy_${TRIVY_VERSION}_Linux-${ARCH}.tar.gz"; \
    cd /tmp; \
    curl -fsSLO "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/${f}"; \
    curl -fsSLo sums.txt "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_checksums.txt"; \
    verify-download "$f" sums.txt "${TRIVY_CHECKSUMS_SHA256}"; \
    tar -xz -C /usr/local/bin -f "$f" trivy; \
    rm -f "$f" sums.txt

RUN set -eu; \
    f="grype_${GRYPE_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    cd /tmp; \
    curl -fsSLO "https://github.com/anchore/grype/releases/download/v${GRYPE_VERSION}/${f}"; \
    curl -fsSLo sums.txt "https://github.com/anchore/grype/releases/download/v${GRYPE_VERSION}/grype_${GRYPE_VERSION}_checksums.txt"; \
    verify-download "$f" sums.txt "${GRYPE_CHECKSUMS_SHA256}"; \
    tar -xz -C /usr/local/bin -f "$f" grype; \
    rm -f "$f" sums.txt

RUN set -eu; \
    f="syft_${SYFT_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    cd /tmp; \
    curl -fsSLO "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/${f}"; \
    curl -fsSLo sums.txt "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_checksums.txt"; \
    verify-download "$f" sums.txt "${SYFT_CHECKSUMS_SHA256}"; \
    tar -xz -C /usr/local/bin -f "$f" syft; \
    rm -f "$f" sums.txt

RUN set -eu; \
    f="cosign-linux-${TARGETARCH}"; \
    cd /tmp; \
    curl -fsSLO "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/${f}"; \
    curl -fsSLo sums.txt "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign_checksums.txt"; \
    verify-download "$f" sums.txt "${COSIGN_CHECKSUMS_SHA256}"; \
    install -m 0755 "$f" /usr/local/bin/cosign; \
    rm -f "$f" sums.txt

FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
LABEL org.opencontainers.image.title="security-scanner-toolbox" \
      org.opencontainers.image.description="trivy + grype + syft + cosign, pinned, for supply-chain CI steps" \
      org.opencontainers.image.licenses="Apache-2.0 AND GPL-2.0-or-later AND GPL-3.0-or-later" \
      org.opencontainers.image.source="https://github.com/fabiocicerchia/security-scanner-toolbox"
RUN apk add --no-cache bash ca-certificates git \
 && adduser -D -u 10001 scanner
COPY NOTICE /NOTICE
COPY --from=fetch /usr/local/bin/trivy /usr/local/bin/grype /usr/local/bin/syft /usr/local/bin/cosign /usr/local/bin/
COPY scan-image /usr/local/bin/scan-image
USER 10001
WORKDIR /work
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["scan-image --help"]
