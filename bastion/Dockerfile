# Build the bastion yourself:
#   docker build --build-arg VERSION=0.11.7 -t shell-proxy-bastion bastion/
# Multi-arch (amd64/arm64) works with `docker buildx build --platform ...`.
FROM alpine:3.21

# TARGETARCH is set by buildx (amd64/arm64); it selects the matching
# shell-proxy-ctl binary from the GitHub release.
ARG TARGETARCH
ARG VERSION
# The unprivileged account that sshd sessions and the daemon run as. This is
# also the user part of the --bastion value you give the agent.
ARG SHELL_PROXY_USER=shellproxy
ENV SHELL_PROXY_USER=${SHELL_PROXY_USER}

RUN apk add --no-cache openssh mosh tini su-exec curl && \
    test -n "${VERSION}" && \
    curl -fsSL -o /usr/local/bin/shell-proxy-ctl \
      "https://github.com/tpmullan/shell-proxy/releases/download/v${VERSION}/shell-proxy-ctl-linux-${TARGETARCH}" && \
    chmod +x /usr/local/bin/shell-proxy-ctl && \
    apk del curl

RUN adduser -D -h "/home/${SHELL_PROXY_USER}" -s /bin/sh "${SHELL_PROXY_USER}" && \
    passwd -u "${SHELL_PROXY_USER}" && \
    mkdir -p /run/sshd /config/ssh_host_keys /config/.ssh /run/shell-proxy-ctl && \
    chown "${SHELL_PROXY_USER}:${SHELL_PROXY_USER}" /run/shell-proxy-ctl

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Host keys and authorized_keys live here; mount a volume so they persist.
VOLUME /config
EXPOSE 2222

# tini runs as PID 1 with -s (subreap) only. entrypoint.sh execs into sshd,
# so sshd receives SIGTERM directly; the in-memory ctl daemon is simply killed
# at the end of the grace period, which loses nothing.
ENTRYPOINT ["/sbin/tini", "-s", "--"]
CMD ["/entrypoint.sh"]
