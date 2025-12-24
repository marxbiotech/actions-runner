# Custom GitHub Actions Runner with additional tools
# Based on the official GitHub Actions Runner image
FROM ghcr.io/actions/actions-runner:latest

# Switch to root user for installation
USER root

# Install GitHub CLI (gh)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gpg && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to runner user
USER runner

# Verify gh installation
RUN gh --version

# Pre-install Claude Code (latest version)
RUN curl -fsSL https://claude.ai/install.sh | bash

# Verify Claude Code installation
RUN $HOME/.local/bin/claude --version

# Add Claude Code to PATH for the runner
ENV PATH="$PATH:/home/runner/.local/bin"
