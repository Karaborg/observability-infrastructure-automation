resource "grafana_dashboard" "main" {
  config_json = file("${path.module}/dashboards/xtkCtBkiz.json")
}

resource "grafana_dashboard" "node_exporter" {
  folder      = grafana_folder.node_exporter.id
  config_json = file("${path.module}/dashboards/StarsL-JOB-node.json")
}

resource "grafana_dashboard" "node_exporter_full" {
  folder      = grafana_folder.node_exporter.id
  config_json = file("${path.module}/dashboards/rYdddlPWk.json")
}

resource "grafana_dashboard" "distributed_tracing" {
  config_json = file("${path.module}/dashboards/distributed-tracing.json")
}
