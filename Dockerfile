# Custom GitHub Actions Runner with additional tools
# Based on the official GitHub Actions Runner image
FROM ghcr.io/actions/actions-runner:2.338.2

# Switch to root user for installation
USER root

# Use bash for pipefail support
SHELL ["/bin/bash", "-c"]

# Install GitHub CLI (gh) and Docker CLI
RUN set -eo pipefail && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gpg \
        ca-certificates \
        libatomic1 && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    # Add GitHub CLI repository
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    # Add Docker repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    # Install packages
    apt-get update && \
    apt-get install -y --no-install-recommends \
        gh \
        docker-ce-cli \
        docker-buildx-plugin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to runner user
USER runner

# Run every JavaScript action on the bundled Node 24 instead of Node 20. The
# runner bundles both; Node 20 is EOL and gets no security fixes (2.338.1 still
# ships 20.20.2). The runner reads this from its own environment as well as the
# workflow's.
ENV FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true

# Verify installations and Node.js runtime dependency. The bundled Node 24 must
# be at least 24.22.1 (October 2026 Node.js security release), so a base image
# that bundles an older one fails the build.
RUN /sbin/ldconfig -p | grep -q 'libatomic.so.1' && \
    gh --version && \
    docker --version && \
    docker buildx version && \
    /home/runner/externals/node24/bin/node --version && \
    /home/runner/externals/node24/bin/node -e 'const [a, b, c] = process.versions.node.split(".").map(Number); if (a !== 24 || b < 22 || (b === 22 && c < 1)) { console.error("bundled node24 " + process.version + " is older than 24.22.1"); process.exit(1); }'
