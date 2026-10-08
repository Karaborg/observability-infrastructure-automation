# Terraform status

`terraform/grafana` manages Grafana resources only. It does not install Grafana, Loki, Prometheus, Tempo, or an OTLP collector.

Use secret variables and a state backend appropriate to your environment. Terraform state and `.tfvars` files must not be committed.
