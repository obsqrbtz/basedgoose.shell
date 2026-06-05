## Monitoring servers (Fedora Server example)

### Install

```bash
sudo dnf install prometheus node_exporter
```

---

### Enable services

```bash
sudo systemctl enable --now node_exporter
sudo systemctl enable --now prometheus
```

---

### node_exporter

* Runs on: `http://localhost:9100/metrics`

---

### Prometheus config

File:

```bash
/etc/prometheus/prometheus.yml
```

Minimal config:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node"
    static_configs:
      - targets: ["localhost:9100"]
```

---

### Set custom port for prometheus

File:

```bash
sudo systemctl edit prometheus
```

Add:

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --web.listen-address=:9090
```

---

### Restart

```bash
sudo systemctl daemon-reload
sudo systemctl restart prometheus
```

---

### Verify

Prometheus:

```
http://localhost:9090/targets
```

Should show node exporter.

node_exporter:

```bash
curl http://localhost:9100/metrics
```

### Add server in shell settings