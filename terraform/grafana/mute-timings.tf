resource "grafana_mute_timing" "monday_friday_1" {
  name = "Monday-Friday-1"

  intervals {
    times {
      start = "18:00"
      end   = "24:00"
    }

    weekdays = [
      "monday", "tuesday", "wednesday",
      "thursday", "friday"
    ]

    location = "Europe/Istanbul"
  }
}

resource "grafana_mute_timing" "monday_friday_2" {
  name = "Monday-Friday-2"

  intervals {
    times {
      start = "00:00"
      end   = "09:00"
    }

    weekdays = [
      "monday", "tuesday", "wednesday",
      "thursday", "friday"
    ]

    location = "Europe/Istanbul"
  }
}

resource "grafana_mute_timing" "weekend" {
  name = "Weekend"

  intervals {
    times {
      start = "00:00"
      end   = "24:00"
    }

    weekdays = ["saturday", "sunday"]

    location = "Europe/Istanbul"
  }
}
