variable "grafana_url" {
  description = "Grafana API URL"
  type        = string
  default     = "https://grafana.example.com"
}

variable "grafana_token" {
  description = "Grafana service account token"
  type        = string
  sensitive   = true
}

variable "prometheus_url" {
  description = "Prometheus base URL"
  type        = string
  default     = "https://prometheus.example.com"
}

variable "loki_url" {
  description = "Loki base URL"
  type        = string
  default     = "https://loki.example.com"
}

variable "tempo_url" {
  description = "Tempo base URL"
  type        = string
  default     = "https://tempo.example.com"
}

variable "grafana_contact_point" {
  description = "Existing Grafana contact point used by the alert policy"
  type        = string
  default     = "platform-notifications"
}
