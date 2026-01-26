# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Custom GitHub Actions Runner Docker image extending `ghcr.io/actions/actions-runner:latest` with GitHub CLI (`gh`) pre-installed. Published to `ghcr.io/marxbiotech/actions-runner`.

## Build Commands

```bash
# Build image locally
docker build -t ghcr.io/marxbiotech/actions-runner:latest .

# Test the image
docker run --rm ghcr.io/marxbiotech/actions-runner:latest gh --version
```

## CI/CD

Images are automatically built and pushed to GitHub Container Registry when:
- Pushing to `main` branch
- Manually triggering the workflow via `workflow_dispatch`

The workflow (`.github/workflows/build-push.yml`) generates tags: `latest`, branch name, and commit SHA.

## Architecture

This is a minimal Docker-based project with no application code:

- **Dockerfile**: Installs GitHub CLI from official sources with GPG verification, runs as non-root `runner` user
- **build-push.yml**: GitHub Actions workflow using Docker Buildx with GHA caching

When adding new tools to the image, follow the existing pattern in Dockerfile:
1. Switch to root for installation
2. Use `--no-install-recommends` to minimize image size
3. Clean apt cache after installation
4. Switch back to `runner` user
5. Add a version verification step
