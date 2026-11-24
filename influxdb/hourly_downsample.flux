option task = {name: "Hourly Downsample IoT", every: 1h, offset: 5m}

data = from(bucket: "openhab_raw")
    |> range(start: -1h)
    |> filter(fn: (r) => r["_field"] == "value")

data
    |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
    |> set(key: "agg_type", value: "mean")
    |> to(bucket: "openhab_hourly", org: "iot_org")

data
    |> aggregateWindow(every: 1h, fn: max, createEmpty: false)
    |> set(key: "agg_type", value: "max")
    |> to(bucket: "openhab_hourly", org: "iot_org")

data
    |> aggregateWindow(every: 1h, fn: min, createEmpty: false)
    |> set(key: "agg_type", value: "min")
    |> to(bucket: "openhab_hourly", org: "iot_org")
