# PavedRoad

A local Internal Developer Platform built in milestone order from [the PRD](docs/PRD.md).

Current status: environment initialization prepared; cluster acceptance has not run.
The application platform is not yet implemented. See [handover](docs/HANDOVER.md).

## Initialize a Codespace

1. Use `https://github.com/treasurebby/Pavedroad` as the platform repository.
2. Create a GitHub Codespace with at least 4 CPUs and 16 GB memory using the committed dev container.
3. Wait for the post-create tool installation to finish.
4. Run `bash scripts/check-environment.sh`.
5. Run `PATH="$PWD/.local/bin:$PATH" kind create cluster --name pavedroad --wait 5m`.
6. Run `kubectl --context kind-pavedroad get nodes` and record the actual result in `docs/HANDOVER.md`.

The setup installs kind with a release checksum. Docker, kubectl and Helm come from
Dev Container features. No cloud infrastructure is provisioned. These commands
initialize the environment; they do not deploy services.

## Implementation sequence

Environment acceptance → mandatory Helm primitive → image CI → ArgoCD GitOps →
canary analysis → observability → service generator → documentation and handover.
Each milestone must pass its real acceptance test before the next begins.

## Verified references

- [kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Codespaces dev containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers)
- [Docker-in-Docker feature](https://github.com/devcontainers/features/tree/main/src/docker-in-docker)
- [Kubernetes tools feature](https://github.com/devcontainers/features/tree/main/src/kubectl-helm-minikube)
