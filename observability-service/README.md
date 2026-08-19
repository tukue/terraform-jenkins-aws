# Platform Observability Service

This directory provides a functional local observability stack using open-source tools. It is designed to monitor the platform's infrastructure and services.

## Components

- **Prometheus**: Time-series database for metrics collection and alerting.
- **Grafana**: Visualization and dashboarding platform.
- **Node Exporter**: Collects hardware and OS metrics from the host.
- **cAdvisor**: Provides resource usage and performance characteristics of running containers.

## Quick Start

1. **Start the observability stack:**
   ```bash
   docker compose up -d
   ```

2. **Access the services:**
   - **Grafana**: [http://localhost:3001](http://localhost:3001) (Default credentials: `admin`/`admin`)
   - **Prometheus**: [http://localhost:9090](http://localhost:9090)
   - **Node Exporter**: [http://localhost:9100](http://localhost:9100)
   - **cAdvisor**: [http://localhost:8081](http://localhost:8081)

3. **View Dashboards:**
   Log in to Grafana and navigate to the "Platform" folder to find the "Platform Overview" dashboard.

## Configuration

- `prometheus/prometheus.yml`: Scrape targets for Prometheus.
- `grafana/provisioning/`: Automatic configuration for Grafana data sources and dashboards.
- `grafana/dashboards/`: JSON definitions for Grafana dashboards.

## Cloud Integration

The platform also supports managed observability on AWS:
- **Amazon Managed Service for Prometheus (AMP)**: See `prometheus/` directory.
- **Self-hosted Grafana on EC2**: See `grafana/` directory.
- **CloudWatch Integration**: See `cloudwatch-observability/` directory.
