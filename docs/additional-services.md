# Additional Services

A variety of additional services can be deployed alongside the main stack, each designed to enhance its functionality and capabilities.

Below is a list of services available for deployment using Kurtosis:

| Service              | Description                                                                                                                                                                                                                              |
|----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `prometheus_grafana` | Deploys [Prometheus](https://github.com/prometheus/prometheus) and [Grafana](https://github.com/grafana/grafana), two powerful monitoring tools that collect and visualize metrics for blockchain infrastructure health and performance. |

Here is a simple example that deploys Prometheus, Grafana:

```yml
args:
  additional_services:
    - prometheus_grafana
```

Access the different web interfaces:

- Prometheus:

```bash
open $(kurtosis port print apstark-v1 prometheus-001 http)
```

- Grafana:

```bash
open $(kurtosis port print apstark-v1 grafana-001 dashboards)
```
