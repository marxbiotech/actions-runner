# Custom GitHub Actions Runner with additional tools
# Based on the official GitHub Actions Runner image
FROM ghcr.io/actions/actions-runner:2.334.0

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
        ca-certificates && \
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

# Verify installations
RUN gh --version && docker --version && docker buildx version
