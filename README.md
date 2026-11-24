Практична робота №13.1: Проєктування та реалізація системи збору, зберігання, агрегації та візуалізації IoT-телеметрії в реальному часі.
Структура проєкту
Plaintext
iot-timeseries-openhab/
├── docker-compose.yml                 # Оркестрація контейнерів OpenHAB, InfluxDB, Grafana
├── openhab/
│   └── conf/
│       ├── items/iot_sensors.items    # Опис 6 метрик та тегів метаданих
│       ├── persistence/influxdb.persist # Стратегії збереження (everyChange, everyMinute)
│       ├── rules/analytics.rules      # Симуляція сенсорів та обчислення похідних метрик
│       └── services/                  # Конфігурація аддонів та підключення до InfluxDB
├── influxdb/
│   └── hourly_downsample.flux         # Flux Task для погодинної агрегації (mean, max, min)
└── grafana/
    ├── provisioning/datasources/      # Автоматичне підключення InfluxDB_v2_Flux
    └── dashboards/iot_dashboard.json  # Експортований JSON дашборда Grafana
4. Приклади Flux-запитів (Query Examples)
А. Отримання динаміки температури та точки роси (Time Series)
Фрагмент коду
from(bucket: "openhab_raw")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "LivingRoom_Temp" or r["_measurement"] == "DewPoint_Calc")
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
Б. Погодинний Downsampling у бакет openhab_hourly (Continuous Task)
Фрагмент коду
option task = {name: "Hourly Downsample IoT", every: 1h, offset: 5m}

from(bucket: "openhab_raw")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
  |> set(key: "agg_type", value: "mean")
  |> to(bucket: "openhab_hourly", org: "iot_org")
В. Виявлення аномального стрибка потужності (Alerting Rule)
Фрагмент коду
from(bucket: "openhab_raw")
  |> range(start: -5m)
  |> filter(fn: (r) => r["_measurement"] == "Kitchen_Power" and r["_field"] == "value")
  |> difference(nonNegative: true)
  |> last()
