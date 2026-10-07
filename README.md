# Observability Infrastructure Automation

A production-oriented Infrastructure-as-Code portfolio project for deploying a Grafana Alloy log collector to Linux hosts. It demonstrates a practical separation of concerns: Ansible manages host-side agent lifecycle, while Terraform is reserved for central Grafana configuration and Jenkins for orchestration.

## Problem

Log collection should be repeatable, safe on busy hosts, and easy to operate across environments. This repository deploys Alloy idempotently, labels logs consistently for Loki, and constrains the agent so an unexpected log volume or malformed entry does not consume unchecked host resources.

## Architecture

<p align="center">
  <img src="docs/Observability%20Infrastructure%20Automation%20Pipeline.png" alt="Observability Infrastructure Automation architecture: Jenkins orchestrates Ansible and Terraform; Grafana Alloy collects application logs and sends them to Loki and Grafana." width="100%">
</p>

The diagram shows the intended end-to-end architecture. The implemented host-side path is Ansible → Linux hosts → Grafana Alloy → Loki → Grafana; Terraform and Jenkins orchestration are planned work.

## Technology stack

- Ansible Core 2.16.x
- Grafana Alloy 1.20.1
- Loki and Grafana
- Linux and systemd
- Terraform and Jenkins (planned integration)

## Repository layout

```text
ansible/
  inventories/       Safe development, staging, and production examples
  playbooks/         Alloy deployment playbook
  roles/alloy/       Installation, configuration, service, and defaults
terraform/           Reserved for Grafana resources; no configuration yet
jenkins/             Reserved for orchestration; no executable pipeline yet
docs/                Architecture and operational usage notes
```

## Implemented: Ansible and Alloy

`ansible/playbooks/deploy-alloy.yml` applies the `alloy` role to target hosts. The role creates the monitoring directory, downloads and installs Alloy, renders its configuration, installs a systemd unit, enables the service, and starts it. It is designed to converge cleanly: after a successful deployment, a second unchanged run should report no changes.

The supplied example inventories are deliberately non-routable documentation samples. Replace their host addresses, SSH user, Loki endpoint, and application settings with your own values. Store environment-specific secrets outside Git, for example in Ansible Vault or your CI credential store.

### Log pipeline

```text
*.log and *.out files
  -> local.file_match
  -> loki.source.file
  -> loki.process
  -> loki.write
  -> Loki
```

Each log stream includes `environment`, `hostname`, `logfile`, and `job` labels. `job` is set from `application_name`. Example LogQL queries:

```logql
{environment="development"}
{environment="development", logfile="application.log"}
```

### Safety and resource protection

- `tail_from_end = true` avoids ingesting potentially large historical files on first rollout.
- `stage.truncate` limits individual entries to 256 KiB by default.
- Alloy runs as `monitoring_owner`, not as root; the account must be able to read the target logs.
- The systemd unit uses `MemoryLimit`, `CPUQuota`, `TasksMax`, and automatic restart on failure. `MemoryLimit` is retained for compatibility with older systemd releases.
- Changes to the Alloy configuration or unit trigger a controlled service restart.

## Prerequisites

- A Linux host with systemd and an x86_64-compatible Alloy binary target
- SSH access for the Ansible control user, with `become` permission for systemd unit installation
- Python compatible with Ansible Core 2.16 on managed hosts
- `unzip` available on managed hosts for archive extraction
- A reachable Loki push endpoint

Install the control-node dependency:

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

## Deploy an example environment

1. Copy or edit an inventory under `ansible/inventories/` and replace every example value.
2. Ensure the configured `monitoring_owner` exists and can read `application_log_path`.
3. Validate before applying:

```bash
ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml --syntax-check
ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml --check --diff
ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml
```

Check the deployment on a host:

```bash
systemctl status alloy
journalctl -u alloy --no-pager -n 100
```

See [usage documentation](docs/usage.md) for configuration details.

## Key configuration

The role defaults are in `ansible/roles/alloy/defaults/main.yml`; define environment-specific overrides in an inventory, group variables, or encrypted Vault file.

| Variable | Purpose | Default |
| --- | --- | --- |
| `application_name` | Value for the `job` Loki label | `example-app` |
| `application_log_path` | Directory scanned for `*.log` and `*.out` | `/var/log/example-app` |
| `alloy_environment` | Value for the `environment` label | `development` |
| `loki_url` | Loki push API endpoint | placeholder URL |
| `monitoring_owner` | Non-root Alloy service user | `ansible_user` |
| `alloy_memory_limit` | systemd memory limit | `256M` |
| `alloy_cpu_quota` | systemd CPU quota | `20%` |
| `alloy_tasks_max` | systemd task limit | `128` |

## Terraform and Jenkins status

Terraform is intended to manage the central Grafana side: folders, dashboards, datasources, alert rules, and notification resources where appropriate. Jenkins is intended to run Ansible deployments and Terraform plan/apply after Git changes. Neither has an executable implementation in this repository yet; their directories are intentionally marked as planned work rather than presenting placeholders as working automation.

## Security

Never commit Loki credentials, SSH keys, Vault passwords, Terraform state, `.tfvars`, or CI credentials. `.gitignore` excludes common sensitive and generated files, but it is a safety net—not a substitute for reviewing every commit. Prefer Ansible Vault, Jenkins Credentials, Terraform environment variables, or a dedicated secrets manager.

This repository is intended to be published from a new, sanitized Git history. Do not publish the history of the original internal project. When ready, from a reviewed copy of the working tree:

```bash
rm -rf .git
git init
git add .
git commit -m "Initial public release"
```

## Roadmap

- Add tested Terraform configuration for Grafana resources.
- Add a Jenkins pipeline for Ansible deployment and Terraform plan/apply.
- Add automated linting and validation in CI.
- Add optional checksum verification and architecture-aware Alloy artifact selection.

## License

MIT. See [LICENSE](LICENSE).
