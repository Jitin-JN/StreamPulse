# StreamPulse: Media Streaming Observability with Tiger Cloud, TimescaleDB & Grafana

## Project Overview

**StreamPulse** is a time-series observability project built to analyze media streaming performance using **Tiger Cloud**, **TimescaleDB**, **PostgreSQL** and **Grafana**.

The project simulates a real-world streaming platform where users generate playback events and backend services generate API performance metrics. The goal is to identify whether user-facing streaming issues, such as buffering, can be correlated with backend service degradation such as API latency, CPU spikes and errors.

This project was designed as a database troubleshooting and observability case study, focusing on:

- Time-series data modeling with TimescaleDB hypertables
- CSV-based telemetry ingestion into Tiger Cloud
- Incident investigation using SQL
- PostgreSQL query optimization with `EXPLAIN ANALYZE`
- Grafana dashboards for operational monitoring

---

## Business Problem

A media streaming company receives reports that:

> **US Smart TV users are experiencing severe buffering.**

The engineering team needs to answer:

- Is the issue isolated to a specific region or device type?
- Is buffering increasing during a specific time window?
- Is a backend API contributing to the user-facing issue?
- Are API latency, CPU usage, and errors increasing at the same time?
- Can database queries used for investigation be optimized?

---

## Solution Summary

I built an end-to-end observability workflow using Tiger Cloud and Grafana.

The workflow includes:

1. Ingesting CSV telemetry data into Tiger Cloud.
2. Modeling playback events and API metrics as TimescaleDB hypertables.
3. Querying time-series data to detect a simulated production incident.
4. Using `EXPLAIN ANALYZE` to inspect query plans.
5. Creating composite and covering indexes to improve investigation query performance.
6. Building a Grafana dashboard to visualize API latency, buffering, CPU usage, request volume, errors, and worst-performing segments.

---

## Tech Stack

| Area | Technology |
|---|---|
| Database Platform | Tiger Cloud |
| Database Engine | TimescaleDB / PostgreSQL |
| Query Language | SQL |
| Visualization | Grafana |
| Data Source | CSV files |
| Optimization | `EXPLAIN ANALYZE`, composite indexes, covering indexes |
| Time-Series Features | Hypertables, chunks, `time_bucket()` |

---

## Dataset

The project uses synthetic but realistic media streaming telemetry data.

| Table | Description | Approx. Rows |
|---|---|---:|
| `content_catalog` | Metadata for content such as movies, series, songs, and live events | 100 |
| `media_events` | Playback events such as play, pause, skip, rewatch, buffering, and ratings | 150,000 |
| `api_metrics` | Backend API telemetry including latency, status codes, request volume, and CPU usage | 129,000+ |

Total data analyzed: **279,000+ records**

---

## Architecture

<img width="895" height="601" alt="image" src="https://github.com/user-attachments/assets/32ecfd9f-b064-4da9-bcec-bd36e0f51c57" />
