# Custom GitHub Actions Runner

This repository contains a custom GitHub Actions Runner image based on the official `ghcr.io/actions/actions-runner` image with additional tools pre-installed.

## Image

```
ghcr.io/marxbiotech/actions-runner:latest
```

## Base Image

- **Base**: `ghcr.io/actions/actions-runner:2.336.0` (pinned in the Dockerfile)

The base image is pinned to an exact runner version and bumped via Dependabot. Keep it current:
GitHub stops queueing jobs to a self-hosted runner that has not been updated within 30 days of a
new `actions/runner` release, and ARC runners do not self-update — the image tag is the only way
to upgrade them.

## Additional Tools

This custom image includes the following additional tools beyond the base image:

| Tool | Description | Version |
|------|-------------|---------|
| **GitHub CLI (`gh`)** | GitHub's official command line tool for interacting with GitHub API, managing PRs, issues, repos, and more | Latest |
| **Docker CLI** | Docker command line client for building and managing containers | Latest |
| **Docker Buildx** | Docker CLI plugin for extended build capabilities with BuildKit | Latest |

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

### Docker CLI

The Docker CLI allows you to build and manage containers. When running on ARC (Actions Runner Controller), configure a DinD sidecar to provide the Docker daemon.

**ARC RunnerSet with DinD Sidecar:**
```yaml
apiVersion: actions.github.com/v1alpha1
kind: RunnerSet
metadata:
  name: my-runner
spec:
  template:
    spec:
      containers:
        - name: runner
          image: ghcr.io/marxbiotech/actions-runner:latest
          command: ["/bin/sh", "-c"]
          args:
            - |
              while [ ! -f /certs/client/ca.pem ]; do
                echo "Waiting for dind certificates..."
                sleep 1
              done
              /home/runner/run.sh
          env:
            - name: DOCKER_HOST
              value: tcp://localhost:2376
            - name: DOCKER_TLS_VERIFY
              value: "1"
            - name: DOCKER_CERT_PATH
              value: /certs/client
          volumeMounts:
            - name: docker-certs
              mountPath: /certs/client
              readOnly: true
        - name: dind
          image: docker:dind
          securityContext:
            privileged: true
          env:
            - name: DOCKER_TLS_CERTDIR
              value: /certs
          volumeMounts:
            - name: docker-certs
              mountPath: /certs
      volumes:
        - name: docker-certs
          emptyDir: {}
```

**Usage Example in Workflow:**
```yaml
steps:
  - name: Build Docker image
    run: docker build -t my-app .
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
