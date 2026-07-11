CREATE INDEX idx_media_events_incident_lookup
ON media_events (
    event_type,
    region,
    device_type,
    event_time DESC
);


ANALYZE media_events;


/*
CREATE INDEX idx_api_metrics_incident_lookup
ON api_metrics (
    endpoint,
    region,
    metric_time DESC
);
*/

DROP INDEX IF EXISTS idx_api_metrics_incident_lookup;

CREATE INDEX idx_api_metrics_incident_lookup_cover
ON api_metrics (
    endpoint,
    region,
    metric_time DESC
)
INCLUDE (
    response_ms,
    cpu_pct,
    request_count,
    status_code
);

ANALYZE api_metrics;



--Media buffering investigation plan


EXPLAIN (ANALYZE, BUFFERS)
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
  AND region = 'US'
  AND device_type = 'smart_tv'
  AND event_time >= max_event_time - INTERVAL '36 hours'
  AND event_time <  max_event_time - INTERVAL '30 hours'
GROUP BY region, device_type;

--API latency investigation plan

EXPLAIN (ANALYZE, BUFFERS)
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
WHERE endpoint = '/recommendations'
  AND region = 'US'
  AND metric_time >= max_metric_time - INTERVAL '36 hours'
  AND metric_time <  max_metric_time - INTERVAL '30 hours'
GROUP BY endpoint, region;



