--buffering issue by region and device
SELECT
    region,
    device_type,
    COUNT(*) AS buffering_events,
    ROUND(AVG(buffer_ms), 2) AS avg_buffer_ms,
    MAX(buffer_ms) AS worst_buffer_ms
FROM media_events
WHERE event_type = 'buffering'
GROUP BY region, device_type
ORDER BY avg_buffer_ms DESC;

--API latency issue

SELECT
    endpoint,
    region,
    ROUND(AVG(response_ms), 2) AS avg_response_ms,
    MAX(response_ms) AS max_response_ms,
    SUM(request_count) AS total_requests,
    COUNT(*) FILTER (WHERE status_code >= 500) AS error_count
FROM api_metrics
GROUP BY endpoint, region
ORDER BY avg_response_ms DESC;

--Full-period buffering by region/device.

WITH bounds AS (
    SELECT MAX(event_time) AS max_event_time
    FROM media_events
)
SELECT
    region,
    device_type,
    COUNT(*) AS buffering_events,
    ROUND(AVG(buffer_ms), 2) AS avg_buffer_ms,
    MAX(buffer_ms) AS worst_buffer_ms
FROM media_events
CROSS JOIN bounds
WHERE event_type = 'buffering'
  AND event_time >= max_event_time - INTERVAL '36 hours'
  AND event_time <  max_event_time - INTERVAL '30 hours'
GROUP BY region, device_type
ORDER BY avg_buffer_ms DESC;

--Incident-window buffering comparison.

WITH bounds AS (
    SELECT MAX(event_time) AS max_event_time
    FROM media_events
),
labeled_events AS (
    SELECT
        CASE
            WHEN event_time >= max_event_time - INTERVAL '36 hours'
             AND event_time <  max_event_time - INTERVAL '30 hours'
                THEN 'incident_window'
            ELSE 'baseline_other_42_hours'
        END AS time_period,
        event_type,
        buffer_ms
    FROM media_events
    CROSS JOIN bounds
    WHERE region = 'US'
      AND device_type = 'smart_tv'
      AND event_time >= max_event_time - INTERVAL '48 hours'
)
SELECT
    time_period,
    COUNT(*) AS total_events,
    COUNT(*) FILTER (WHERE event_type = 'buffering') AS buffering_events,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE event_type = 'buffering') / COUNT(*),
        2
    ) AS buffering_rate_pct,
    ROUND(
        AVG(buffer_ms) FILTER (WHERE event_type = 'buffering'),
        2
    ) AS avg_buffer_ms,
    MAX(buffer_ms) FILTER (WHERE event_type = 'buffering') AS worst_buffer_ms
FROM labeled_events
GROUP BY time_period
ORDER BY time_period;


--Incident window for API latency

WITH bounds AS (
    SELECT MAX(metric_time) AS max_metric_time
    FROM api_metrics
)
SELECT
    endpoint,
    region,
    ROUND(AVG(response_ms), 2) AS avg_response_ms,
    MAX(response_ms) AS max_response_ms,
    ROUND(AVG(cpu_pct), 2) AS avg_cpu_pct,
    SUM(request_count) AS total_requests,
    COUNT(*) FILTER (WHERE status_code >= 500) AS error_count
FROM api_metrics
CROSS JOIN bounds
WHERE metric_time >= max_metric_time - INTERVAL '36 hours'
  AND metric_time <  max_metric_time - INTERVAL '30 hours'
GROUP BY endpoint, region
ORDER BY avg_response_ms DESC;


--Incident-window API comparison

WITH bounds AS (
    SELECT MAX(metric_time) AS max_metric_time
    FROM api_metrics
),
labeled_metrics AS (
    SELECT
        CASE
            WHEN metric_time >= max_metric_time - INTERVAL '36 hours'
             AND metric_time <  max_metric_time - INTERVAL '30 hours'
                THEN 'incident_window'
            ELSE 'baseline_other_42_hours'
        END AS time_period,
        response_ms,
        status_code,
        request_count,
        cpu_pct
    FROM api_metrics
    CROSS JOIN bounds
    WHERE endpoint = '/recommendations'
      AND region = 'US'
      AND metric_time >= max_metric_time - INTERVAL '48 hours'
)
SELECT
    time_period,
    ROUND(AVG(response_ms), 2) AS avg_response_ms,
    MAX(response_ms) AS max_response_ms,
    ROUND(AVG(cpu_pct), 2) AS avg_cpu_pct,
    SUM(request_count) AS total_requests,
    COUNT(*) FILTER (WHERE status_code >= 500) AS error_count
FROM labeled_metrics
GROUP BY time_period
ORDER BY time_period;