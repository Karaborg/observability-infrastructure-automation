# Observability Infrastructure Automation

A public, production-oriented Infrastructure-as-Code project for centralized application logs and Grafana configuration. Ansible manages host-side Grafana Alloy deployment; Terraform manages Grafana folders, data sources, dashboards, alerting policy, and mute timings.

## Status

| Area | Status |
| --- | --- |
| Grafana Alloy installation and systemd lifecycle | Implemented |
| `.log` and `.out` collection to Loki | Implemented |
| Grafana folders, data sources, dashboards, alert rules, mute timings, and notification policy | Implemented as Terraform |
| OpenTelemetry Java-agent rollout | Scaffold only; not deployable |
| Jenkins orchestration and operational playbooks | Planned |
| Prometheus, Loki, Tempo, and Grafana server installation | Outside this repository / planned |

## Architecture

```text
Git change
  -> Jenkins (planned)
  -> Ansible -> Linux hosts -> Grafana Alloy -> Loki -> Grafana
  -> Terraform --------------------------------------------> Grafana
```

<p align="center">
  <img src="docs/Observability%20Infrastructure%20Reference%20Architecture.png" alt="Observability automation architecture with Jenkins, Ansible, Terraform, Grafana Alloy, Loki, and Grafana." width="100%">
</p>

Ansible owns host configuration; Terraform owns Grafana API resources. This boundary prevents dashboard and alert changes from being coupled to agent rollout.

## Log pipeline and safety

```text
*.log and *.out -> local.file_match -> loki.source.file -> loki.process -> loki.write -> Loki
```

Streams receive `environment`, `hostname`, `logfile`, and `job` labels. `tail_from_end = true` avoids an initial historical backfill; `stage.truncate` limits each entry to 256 KiB by default. The non-root Alloy service is constrained by systemd `MemoryLimit`, `CPUQuota`, `TasksMax`, and restart-on-failure.

## Repository layout

```text
ansible/
  inventories/       Safe development, staging, and production examples
  playbooks/         Alloy deployment plus planned operation/OTel scaffolding
  roles/alloy/       Host installation, configuration, and systemd management
  roles/otel_java_agent/  Generic environment-template scaffold only
terraform/grafana/   Grafana resources, dashboards, and alert configuration
jenkins/             Reserved for a future tested pipeline
docs/                Design and usage notes
```

## Prerequisites

- Ansible Core 2.16.x on the control node
- Linux x86_64 hosts with systemd, `unzip`, SSH access, and approved privilege escalation
- A reachable Loki push API; the Alloy service account must read the target logs
- Terraform and a Grafana service-account token for Grafana resources

## Deploy Alloy

The inventories use non-routable documentation addresses. Replace all example values before running a deployment.

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt

ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml --syntax-check
ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml --check --diff
ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml
```

Role defaults are in `ansible/roles/alloy/defaults/main.yml`. Configure `application_name`, `application_log_path`, `alloy_environment`, `loki_url`, and resource limits per environment through inventory or encrypted variables.

## Configure Grafana with Terraform

Terraform runs from `terraform/grafana` and provisions Grafana folders, Prometheus/Loki/Tempo data sources, dashboards, an availability alert rule, mute timings, and a notification policy. Endpoint defaults are illustrative only.

```bash
export TF_VAR_grafana_token='set-in-a-secret-store-or-shell'
cd terraform/grafana
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Set URLs and the existing Grafana contact point with ignored `.tfvars` files, CI environment variables, or a secrets manager. Review a plan before applying. The local Terraform state backend is intentionally ignored and must be handled according to your own state policy.

## Security

Do not commit credentials, service-account tokens, webhooks, private keys, Ansible Vault passwords, Terraform state, or `.tfvars` files. `.gitignore` covers common sensitive/generated paths but every change still needs review.

This project should be published with a fresh, sanitized Git history, not an internal history:

```bash
rm -rf .git
git init
git add .
git commit -m "Initial public release"
```

## Roadmap

- Complete and test the OpenTelemetry Java-agent deployment role.
- Add operational service status/restart playbooks.
- Add a tested Jenkins pipeline for Ansible and Terraform validation/deployment.
- Add checksum verification and architecture-aware Alloy artifact selection.
- Add server-side observability platform provisioning where appropriate.

See [architecture.md](docs/architecture.md) and [usage.md](docs/usage.md) for details. Licensed under [MIT](LICENSE).
