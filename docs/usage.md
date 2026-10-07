# Usage

## Configure an inventory

The inventories in `ansible/inventories/development`, `staging`, and `production` are safe examples only. Their IP addresses are reserved documentation ranges and will not point to real systems.

Copy or edit an inventory for your environment. At minimum, replace `ansible_host`, `ansible_user`, `loki_url`, `application_name`, and `application_log_path`.

```yaml
all:
  vars:
    alloy_environment: staging
    application_name: payments-api
    application_log_path: /var/log/payments-api
    loki_url: https://loki.example.com/loki/api/v1/push
  hosts:
    staging-app-01:
      ansible_host: 192.0.2.20
      ansible_user: deploy
```

The Loki endpoint example is intentionally nonfunctional. Provide credentials through an approved secret mechanism if your Loki endpoint requires them; do not put credentials in a committed inventory or URL.

## Override role defaults

Use inventory/group variables or encrypted Ansible Vault variables for environment-specific settings:

```yaml
monitoring_owner: alloy
alloy_memory_limit: 384M
alloy_cpu_quota: 25%
alloy_tasks_max: 128
alloy_max_log_line_size: 256KiB
```

The selected `monitoring_owner` must already exist and must be able to traverse the log directory and read matching `.log` and `.out` files. The role does not create application users or change application log permissions.

## Validate and deploy

From the repository root:

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt

ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml --syntax-check
ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml --check --diff
ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml
```

The playbook requires `become` for the systemd unit and service steps. Supply your normal Ansible privilege-escalation option or configuration; do not store a become password in the repository.

## Verify on a managed host

```bash
systemctl is-enabled alloy
systemctl status alloy
journalctl -u alloy --no-pager -n 100
```

In Grafana, start with:

```logql
{environment="development"}
```

Then narrow by `job`, `hostname`, or `logfile`.

## Operational notes

- Configuration or unit changes notify a service restart, so use normal change-control practices for production rollouts.
- `tail_from_end` intentionally does not backfill existing logs. Remove or change it only when a controlled backfill is desired.
- Verify `MemoryLimit`, `CPUQuota`, and `TasksMax` on representative target systemd versions before tightening them for production.
- The role downloads the tested x86_64 Alloy release artifact. Adapt `alloy_download_url` before using a different architecture or a pinned internal artifact source.
