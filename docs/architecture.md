# Architecture

This project separates host configuration from central observability-platform configuration.

| Component | Responsibility | Status |
| --- | --- | --- |
| Ansible | Linux directories, Alloy binary/configuration, systemd lifecycle | Implemented |
| Grafana Alloy | Discover, enrich, truncate, and forward application logs | Implemented |
| Loki | Central log storage and query backend | External dependency |
| Grafana | Log exploration, dashboards, alerts | External dependency |
| Terraform | Grafana resources such as folders, dashboards, and alerts | Planned |
| Jenkins | Run Ansible and Terraform in CI/CD | Planned |

## Host-side flow

```text
Application files (*.log, *.out)
  -> local.file_match
  -> loki.source.file
  -> loki.process
  -> loki.write
  -> Loki
  -> Grafana
```

The configuration adds `environment`, `hostname`, `logfile`, and `job` labels. `job` maps to the configured `application_name`; `logfile` is derived from the source filename. This makes environment-wide and per-file queries possible without embedding internal infrastructure naming in the role.

## Design decisions

**Idempotency.** Ansible uses state-based modules for directories, templates, and systemd. Artifact extraction and binary renaming use `creates` guards. An unchanged deployment should converge without changes.

**Least privilege.** The systemd unit runs Alloy as `monitoring_owner`. Only unit installation and service lifecycle operations use privilege escalation. The designated user must be granted read access to the application logs by the host’s normal permission model.

**First-rollout safety.** `tail_from_end = true` begins at the end of existing files, preventing a deployment from immediately sending a large historical backlog.

**Large-entry safety.** `stage.truncate` limits each pathological line to 256 KiB by default, preserving a suffix to make truncation visible.

**Host protection.** Systemd supplies `MemoryLimit`, `CPUQuota`, `TasksMax`, and restart-on-failure. `MemoryLimit` was selected for compatibility with older systemd versions where relying only on newer cgroup settings is less portable.

**Ownership boundaries.** Ansible does not configure Grafana resources, and Terraform will not install host agents. This keeps agent rollout independent from dashboards and alerting changes.

For setup instructions, see [usage.md](usage.md).
