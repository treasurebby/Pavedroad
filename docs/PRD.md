# PavedRoad — Implementation PRD for Coding Agent

**Version:** 1.0
**Deliverable:** A working, tested local Internal Developer Platform repository — Kubernetes primitives, GitOps, progressive delivery, and observability, runnable entirely in a GitHub Codespace.

## 1. Instructions to the agent and definition of completion

### 1.1 Assignment
Implement this end to end: Helm chart, CI pipeline, ArgoCD GitOps wiring, Argo Rollouts canary config, Prometheus/Grafana/Alertmanager observability stack, one runbook, one golden-path scaffold script, two sample services. Produce real, runnable YAML/Helm/scripts/code — not pseudocode or a description of what should exist.

Priority when decisions conflict:
1. The founder's explicit current instruction
2. Verified tool/platform behavior (kind, Helm, ArgoCD, Argo Rollouts, Prometheus docs)
3. The milestone order and ownership rules in this PRD
4. Convenience/defaults

### 1.2 Implementation discipline
- Cluster: kind only. Do not provision cloud infrastructure, do not add Terraform resources targeting a real cloud provider.
- One Helm chart (`deploy/charts/service-primitive`) is the only deployment primitive. Every service consumes it — do not hand-write a second Deployment manifest for any service.
- GitOps only: ArgoCD watches the repo. Do not deploy via manual `kubectl apply`/`helm install` in any committed script meant for steady-state use (manual commands are fine for Milestone 2 bootstrapping only, and must be removed/superseded once ArgoCD is wired in Milestone 4).
- Canary rollout via Argo Rollouts `Rollout` resource, not raw `Deployment`, for both sample services once Milestone 5 is reached.
- No fake dashboards: Grafana panels must query real Prometheus metrics produced by the actual pipeline, not hardcoded demo data.
- No placeholder alert rules that never fire — the alert must be tied to a real metric with a real threshold, and must be demonstrably triggerable.
- No TODO stubs in any file under `deploy/`, `.github/workflows/`, or `services/*/src`. Deferred work goes in `docs/KNOWN_LIMITATIONS.md` only.
- Do not silently swap tool choices (e.g. Flux instead of ArgoCD, Linkerd instead of Istio) without flagging the substitution in the handover notes.

### 1.3 Required repository outputs
| Output | Contents |
|---|---|
| Helm chart | `deploy/charts/service-primitive` — deployment/rollout, service, probes, resource limits as required (non-optional) values |
| CI | `.github/workflows/ci.yml` — build, test, push to `ghcr.io`, tag by Git SHA |
| GitOps | `deploy/argocd/*.yaml` — Application manifests per namespace |
| Progressive delivery | `Rollout` resources with canary steps + automated analysis/health gate |
| Observability | Prometheus + Grafana + Alertmanager install manifests/values, one dashboard JSON, one alert rule |
| Golden path | `scripts/new-service.sh` (or cookiecutter template) — generates Dockerfile + CI workflow + chart values for a new service |
| Services | Two minimal sample services under `services/`, each with a `/healthz` and a `/metrics` endpoint |
| Docs | `README.md`, `docs/PRD.md`, `docs/runbooks/canary-stuck.md`, `docs/KNOWN_LIMITATIONS.md` |
| Handover | Exact commands run, actual test/demo results, what remains manual |

Completion means a second engineer can clone the repo, follow the README, and reach a running cluster with GitOps-managed, canary-deployed, observed services — without inventing missing code.

## 2. Scope and decisions

This is a demonstration platform, not a multi-tenant production system. No RBAC, no plugin architecture, no multi-cluster. `staging`/`prod` are namespaces in one kind cluster. This is a stated, deliberate simplification — not a gap to silently work around.

## 3. Architecture and ownership

```
services/<name>/        → app code + Dockerfile (owned per-service)
deploy/charts/service-primitive/ → the only deployment primitive (owned centrally)
deploy/argocd/           → GitOps Application definitions (owned centrally)
.github/workflows/       → CI (owned centrally, one workflow parametrized per service or one per service — agent's choice, document it)
scripts/                 → golden-path generator
docs/runbooks/           → operational runbooks
```

Rule: a service's own repo folder never contains deployment logic beyond chart *values* — the chart itself is the single owner of how a Deployment/Rollout/Service object is structured.

## 4. Feature sections

### 4.1 Compute primitive (Milestone 2)
Helm chart must require (not default-allow-empty): image repo/tag, resource requests/limits, liveness probe path, readiness probe path. Chart rejects install if these are unset — this is the "paved road enforcing good defaults" behavior, implement it as a Helm `required()` validation, not just documentation.

### 4.2 CI (Milestone 3)
On push to `main` affecting `services/<name>/**`: build image, run any tests present, push to `ghcr.io/<owner>/<name>:<git-sha>`. Do not use `:latest` as the deployed tag anywhere in GitOps manifests.

### 4.3 GitOps (Milestone 4)
ArgoCD `Application` per namespace, pointed at `deploy/charts/service-primitive` with namespace-specific values files. Sync policy: automated, with self-heal enabled. A manual Git value change must propagate without operator `kubectl`/`helm` commands — this is the acceptance test for this milestone.

### 4.4 Progressive delivery (Milestone 5)
`Rollout` with canary steps (20% → pause → 50% → pause → 100%), gated by a readiness/analysis check. Must demonstrably roll back on a forced-bad image (agent must run this test and record the result, not just claim the config supports it).

### 4.5 Observability (Milestone 6)
- Prometheus scrapes both sample services' `/metrics`
- Grafana dashboard: deploy success rate (from Rollout events/analysis results) + p95 latency (from service metrics)
- One Alertmanager rule: p95 latency over threshold for 5 minutes
- Agent must trigger the alert on purpose at least once and record that it fired
- `docs/runbooks/canary-stuck.md`: real, specific, written as an actual responder would use it (symptom → confirm → mitigate → root-cause steps → close-out)

### 4.6 Golden path (Milestone 7)
One script/template. Running it with a service name produces a working, deployable service skeleton. Acceptance test: time from running the script to the new service showing `Healthy`/`Synced` in ArgoCD — must be under 10 minutes, agent records the actual time.

## 5. Testing and acceptance scenarios
- `kind create cluster` succeeds, both namespaces exist
- Helm chart install fails correctly when required values are omitted
- CI produces a new image tag on push
- Git value change propagates via ArgoCD without manual commands
- Forced-bad canary image triggers rollback automatically
- Grafana dashboard shows non-zero real data
- Alert fires on a forced threshold breach
- Golden-path script produces a second working service in under 10 minutes

## 6. Implementation order and handover

Order: M1 env setup → M2 primitive → M3 CI → M4 GitOps → M5 progressive delivery → M6 observability → M7 golden path → M8 docs → M9 stretch (service mesh, optional).

Do not skip ahead; do not stop after scaffolding without running the acceptance test for that milestone.

**Required final handover:**
- Repo location, exact run instructions
- Which milestones are complete, which acceptance tests actually ran and their actual results
- Any tool substitutions made and why
- `docs/KNOWN_LIMITATIONS.md`: single-node cluster, namespace-simulated environments, no RBAC, no plugin architecture — stated explicitly, not omitted

No "done" claim on any milestone without the corresponding acceptance test actually having been run.

## 7. Traceability

| Capability | Owner | Test |
|---|---|---|
| Deploy a service | Helm chart | M2 acceptance |
| Automated build/push | CI workflow | M3 acceptance |
| Git-driven deploys | ArgoCD Application | M4 acceptance |
| Safe rollout | Argo Rollouts | M5 acceptance |
| Operational visibility | Prometheus/Grafana/Alertmanager | M6 acceptance |
| Self-service scaffolding | golden-path script | M7 acceptance |

## 8. Source register
Verify against official docs during build, not from memory: Helm docs, ArgoCD docs, Argo Rollouts docs, kind docs, kube-prometheus-stack chart docs, GitHub Actions `ghcr.io` publishing docs.

**End of brief. Agent: implement, run the acceptance tests for real, hand over exact results.**