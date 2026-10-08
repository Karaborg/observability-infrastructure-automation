resource "grafana_rule_group" "down_services" {
  org_id             = 1
  name               = "Default"
  folder_uid         = "bfopy1hy6tc00d"
  interval_seconds   = 60
  disable_provenance = true

  rule {
    uid       = "dfopy52rvaneoc"
    name      = "Down Services"
    condition = "A"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "dfoiotr4n13pce"
      model          = "{\"editorMode\":\"code\",\"expr\":\"probe_http_status_code != 200\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }

    no_data_state  = "OK"
    exec_err_state = "Error"
    for            = "1m"
    annotations = {
      __dashboardUid__ = "xtkCtBkiz"
      __panelId__      = "140"
      summary          = "Down Service"
    }
    is_paused = false

    notification_settings {
      contact_point = var.grafana_contact_point
      mute_timings  = ["Monday-Friday-1", "Monday-Friday-2", "Weekend"]
    }
  }
}
