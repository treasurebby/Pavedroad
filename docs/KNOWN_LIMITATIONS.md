# Known limitations

- Deliberately single-node kind cluster, with staging and prod simulated by namespaces.
- No platform RBAC design, plugin architecture, multi-cluster support or cloud provisioning.
  Upstream controllers may still require their own Kubernetes RBAC resources.
- This Windows environment has no Docker Desktop, installed WSL distribution,
  kind, Helm or kubectl. Real cluster acceptance cannot run here yet.
- Repository selected: `https://github.com/treasurebby/Pavedroad.git`; execution
  target: GitHub Codespaces. This local session has no Codespace terminal connection.
- Only environment initialization is prepared. M1 has not passed cluster acceptance;
  M2–M8 remain unimplemented because the PRD requires sequential acceptance.
- Dev Container base image and feature major tags are mutable; kubectl follows the
  feature's current stable version. Resolve exact versions after the first environment
  acceptance run, then record them in the handover.
- The skills CLI search could not access npm under the current offline cache policy.
  No additional skill was installed or recommended from an unverified result.
