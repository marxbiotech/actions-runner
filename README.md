# Custom GitHub Actions Runner

This repository contains a custom GitHub Actions Runner image based on the official `ghcr.io/actions/actions-runner:latest` with additional tools pre-installed.

## Image

```
ghcr.io/marxbiotech/actions-runner:latest
```

## Base Image

- **Base**: `ghcr.io/actions/actions-runner:latest`

## Additional Tools

This custom image includes the following additional tools beyond the base image:

| Tool | Description | Version |
|------|-------------|---------|
| **GitHub CLI (`gh`)** | GitHub's official command line tool for interacting with GitHub API, managing PRs, issues, repos, and more | Latest |

### GitHub CLI (`gh`)

The GitHub CLI allows you to:
- Create, view, and manage pull requests
- Create, view, and manage issues
- Manage GitHub Actions workflows
- Authenticate and interact with GitHub API
- Clone, fork, and manage repositories

**Usage Example in Workflow:**
```yaml
steps:
  - name: Create a pull request
    run: gh pr create --title "My PR" --body "Description"
    env:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Automated Builds

This image is automatically built and pushed to GitHub Container Registry (ghcr.io) when:
- A push is made to the `main` branch
- The workflow is manually triggered

## Usage

### Pull the image
```bash
docker pull ghcr.io/marxbiotech/actions-runner:latest
```

### Use in self-hosted runner
Configure your self-hosted runner to use this image instead of the default one.

## Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest build from main branch |
| `main` | Latest build from main branch |
| `<sha>` | Specific commit SHA |

## License

This project follows the same license as the base GitHub Actions Runner image.
