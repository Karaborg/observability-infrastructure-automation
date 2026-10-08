resource "grafana_folder" "node_exporter" {
  uid   = "cg0l967m74npcd"
  title = "Node Exporter"
}

resource "grafana_folder" "alerts" {
  uid   = "bfopy1hy6tc00d"
  title = "Alerts"
}
