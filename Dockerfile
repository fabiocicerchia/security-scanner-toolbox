# security-scanner-toolbox — trivy + grype + syft + cosign, pinned and
# multi-arch. One image for the whole scan/attest step in CI.
ARG TRIVY_VERSION=0.64.1
ARG GRYPE_VERSION=0.95.0
ARG SYFT_VERSION=1.28.0
ARG COSIGN_VERSION=2.5.3

FROM alpine:3.24 AS fetch
ARG TRIVY_VERSION
ARG GRYPE_VERSION
ARG SYFT_VERSION
ARG COSIGN_VERSION
ARG TARGETARCH=amd64
RUN apk add --no-cache curl ca-certificates
RUN ARCH="$([ "$TARGETARCH" = "arm64" ] && echo ARM64 || echo 64bit)" \
 && curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${ARCH}.tar.gz" \
      | tar -xz -C /usr/local/bin trivy
RUN curl -fsSL "https://github.com/anchore/grype/releases/download/v${GRYPE_VERSION}/grype_${GRYPE_VERSION}_linux_${TARGETARCH}.tar.gz" \
      | tar -xz -C /usr/local/bin grype
RUN curl -fsSL "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_${TARGETARCH}.tar.gz" \
      | tar -xz -C /usr/local/bin syft
RUN curl -fsSLo /usr/local/bin/cosign \
      "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-${TARGETARCH}" \
 && chmod 0755 /usr/local/bin/cosign

FROM alpine:3.24
LABEL org.opencontainers.image.title="security-scanner-toolbox" \
      org.opencontainers.image.description="trivy + grype + syft + cosign, pinned, for supply-chain CI steps" \
      org.opencontainers.image.licenses="Apache-2.0 AND GPL-2.0-or-later AND GPL-3.0-or-later" \
      org.opencontainers.image.source="https://github.com/fabiocicerchia/security-scanner-toolbox"
RUN apk add --no-cache bash ca-certificates git \
 && adduser -D -u 10001 scanner
COPY --from=fetch /usr/local/bin/trivy /usr/local/bin/grype /usr/local/bin/syft /usr/local/bin/cosign /usr/local/bin/
COPY scan-image /usr/local/bin/scan-image
USER 10001
WORKDIR /work
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["scan-image --help"]
