resource "grafana_data_source" "prometheus" {
  name        = "Prometheus"
  type        = "prometheus"
  uid         = "dfoiotr4n13pce"
  url         = var.prometheus_url
  access_mode = "proxy"
  is_default  = true

  json_data_encoded = jsonencode({
    pdcInjected   = false
    tlsSkipVerify = true
  })
}

resource "grafana_data_source" "loki" {
  name        = "Loki"
  type        = "loki"
  uid         = "cfsaeblaygpogb"
  url         = var.loki_url
  access_mode = "proxy"
  is_default  = false

  json_data_encoded = jsonencode({
    derivedFields = [
      {
        datasourceUid   = "ffoiz165svcaof"
        matcherRegex    = "traceId=([a-fA-F0-9]{32})"
        matcherType     = "regex"
        name            = "TraceID"
        url             = "$${__value.raw}"
        urlDisplayLabel = ""
      }
    ]
    oauthPassThru = false
    pdcInjected   = false
    tlsSkipVerify = true
  })
}

resource "grafana_data_source" "tempo" {
  name        = "Tempo"
  type        = "tempo"
  uid         = "ffoiz165svcaof"
  url         = var.tempo_url
  access_mode = "proxy"
  is_default  = false

  json_data_encoded = jsonencode({
    pdcInjected   = false
    tlsSkipVerify = true

    tracesToLogsV2 = {
      customQuery        = true
      datasourceUid      = "cfsaeblaygpogb"
      filterByTraceID    = true
      query              = "{job=\"example-app\"} |= \"$${__trace.traceId}\""
      spanEndTimeShift   = "5m"
      spanStartTimeShift = "-5m"
    }

    tracesToMetrics = {
      datasourceUid = "dfoiotr4n13pce"

      queries = [
        {
          name  = "Request Rate"
          query = "sum(rate(traces_spanmetrics_calls_total{$${__tags}}[5m]))"
        },
        {
          name  = "Error Rate (%)"
          query = "100 * sum(rate(traces_spanmetrics_calls_total{$${__tags},status_code=\"STATUS_CODE_ERROR\"}[5m])) / clamp_min(sum(rate(traces_spanmetrics_calls_total{$${__tags}}[5m])), 0.000001)"
        },
        {
          name  = "Latency P95"
          query = "histogram_quantile(   0.95,   sum by (le) (     rate(traces_spanmetrics_latency_bucket{$${__tags}}[5m])   ) )"
        }
      ]

      spanEndTimeShift   = "5m"
      spanStartTimeShift = "-5m"

      tags = [
        {
          key   = "service.name"
          value = "service"
        }
      ]
    }
  })
}
