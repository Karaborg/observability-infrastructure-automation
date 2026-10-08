resource "grafana_notification_policy" "default" {
  contact_point   = var.grafana_contact_point
  group_by        = ["grafana_folder", "alertname", "env"]
  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "4h"

  disable_provenance = true
}
