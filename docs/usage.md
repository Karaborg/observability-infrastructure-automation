# Usage

## Ansible inventory

Use `development`, `staging`, and `production` inventories as templates only. Replace the documentation IP address, SSH user, Loki endpoint, application path, and application name before deployment.

```yaml
all:
  vars:
    alloy_environment: staging
    application_name: payments-api
    application_log_path: /var/log/payments-api
    loki_url: https://loki.example.com/loki/api/v1/push
```

The Alloy service account must already exist and have read access to the application logs. Store sensitive overrides in Ansible Vault or your CI secret store, never in a committed inventory.

## Validation

```bash
ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml --syntax-check
ansible-playbook -i ansible/inventories/development/hosts.yml ansible/playbooks/deploy-alloy.yml --check --diff
```

After deployment:

```bash
systemctl status alloy
journalctl -u alloy --no-pager -n 100
```

Query Loki in Grafana with labels such as:

```logql
{environment="development", job="example-app"}
```

## Terraform

Run Terraform from `terraform/grafana`. Supply `grafana_token` through `TF_VAR_grafana_token` or an ignored variables file, then run `terraform init`, `terraform validate`, and `terraform plan`. Provide real Grafana and data-source URLs through Terraform variables; public defaults are placeholders.

Do not run the OpenTelemetry or operations playbooks as production automation yet: they are intentionally empty scaffolds.
