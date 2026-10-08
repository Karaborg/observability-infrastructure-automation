# Architecture

## Responsibility boundaries

| Component | Responsibility | Status |
| --- | --- | --- |
| Ansible | Alloy installation, rendered configuration, systemd lifecycle | Implemented |
| Grafana Alloy | File discovery, log enrichment, truncation, forwarding to Loki | Implemented |
| Terraform | Grafana resources and configuration | Implemented |
| Loki, Prometheus, Tempo, Grafana servers | External dependencies | Not managed here |
| OpenTelemetry Java agent | Generic environment template | Scaffold only |
| Jenkins | CI/CD orchestration | Planned |

## Log path

Alloy discovers configurable `*.log` and `*.out` files and labels streams with environment, hostname, filename, and application job. It starts at the end of existing files and truncates oversized entries before forwarding to Loki.

Systemd limits CPU, memory, and task creation to isolate the agent from noisy workloads. Alloy runs as the configured non-root service account; only unit installation and lifecycle commands use privilege escalation.

## Grafana configuration

The Terraform module provisions folders, Prometheus/Loki/Tempo data sources, dashboards, one generic availability rule, mute timings, and a notification policy. It assumes data sources and a target contact point already exist or are reachable; it does not deploy server components.

The Java-agent template references a configurable OTLP collector but no tasks apply it and no collector configuration is included. Therefore metrics and traces are not represented as an implemented end-to-end path.
