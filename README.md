# IoT Time-Series Analytics з OpenHAB, InfluxDB 2.x та Grafana

Проєкт демонструє повний цикл збору, зберігання, агрегації (downsampling) та візуалізації IoT-телеметрії в реальному часі за допомогою мікросервісного стеку Docker.

---

## 1. Архітектура системи

Усі сервіси розгорнуті в Docker-контейнерах у спільній мережі `iot-net`:

```mermaid
flowchart LR
    subgraph OpenHAB["OpenHAB 4.1.2 (Port 8081)"]
        R[Rules Engine<br/>analytics.rules] -->|Оновлення кожні 15с| I[Items & Groups<br/>gInfluxDB]
        I -->|everyChange, everyMinute| P[InfluxDB Persistence<br/>Service]
    end

    subgraph InfluxDB["InfluxDB 2.7 (Port 8086)"]
        B1[(Bucket: openhab_raw<br/>Retention: 7d)]
        T[Flux Task<br/>Hourly Downsample]
        B2[(Bucket: openhab_hourly<br/>Retention: 90d)]
        B3[(Bucket: openhab_daily<br/>Retention: 365d)]
        B1 --> T --> B2
        B2 -.->|Rollup| B3
    end

    subgraph Grafana["Grafana 10.4.1 (Port 3000)"]
        D[Dashboard<br/>Time Series / Gauge / Stat]
        A[Alerting Engine<br/>Threshold & Anomaly]
        W((Webhook<br/>Notifications))
        D --- A --> W
    end

    P -->|HTTP API / Flux| B1
    B1 -->|Flux Queries| D
    B2 -->|Flux Queries| D
