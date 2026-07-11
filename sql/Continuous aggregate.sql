
--media continuous aggregate
DROP MATERIALIZED VIEW IF EXISTS media_events_5min_summary CASCADE;

CREATE MATERIALIZED VIEW media_events_5min_summary
WITH (timescaledb.continuous) AS
SELECT
    time_bucket(INTERVAL '5 minutes', event_time) AS bucket,
    content_id,
    event_type,
    region,
    device_type,
    COUNT(*) AS event_count,
    SUM(watch_seconds) AS total_watch_seconds,
    ROUND(AVG(buffer_ms), 2) AS avg_buffer_ms,
    MAX(buffer_ms) AS max_buffer_ms
FROM media_events
GROUP BY
    bucket,
    content_id,
    event_type,
    region,
    device_type
WITH NO DATA;



CALL refresh_continuous_aggregate(
    'media_events_5min_summary',
    NULL,
    NULL
);


-- API continuous aggregate

DROP MATERIALIZED VIEW IF EXISTS api_metrics_5min_summary CASCADE;

CREATE MATERIALIZED VIEW api_metrics_5min_summary
WITH (timescaledb.continuous) AS
SELECT
    time_bucket(INTERVAL '5 minutes', metric_time) AS bucket,
    service_name,
    endpoint,
    region,
    ROUND(AVG(response_ms), 2) AS avg_response_ms,
    MAX(response_ms) AS max_response_ms,
    SUM(request_count) AS total_requests,
    ROUND(AVG(cpu_pct), 2) AS avg_cpu_pct,
    COUNT(*) FILTER (WHERE status_code >= 500) AS error_count
FROM api_metrics
GROUP BY
    bucket,
    service_name,
    endpoint,
    region
WITH NO DATA;

CALL refresh_continuous_aggregate(
    'api_metrics_5min_summary',
    NULL,
    NULL
);

--Verify continuous aggregates

SELECT
    view_name,
    materialized_only
FROM timescaledb_information.continuous_aggregates
ORDER BY view_name;


---------------------------------------------------------------------------------------------------------

-- media aggregate

SELECT
    bucket,
    region,
    device_type,
    SUM(event_count) AS buffering_events,
    ROUND(AVG(avg_buffer_ms), 2) AS avg_buffer_ms
FROM media_events_5min_summary
WHERE event_type = 'buffering'
  AND region = 'US'
  AND device_type = 'smart_tv'
GROUP BY bucket, region, device_type
ORDER BY bucket;


-- api aggregate

SELECT
    bucket,
    endpoint,
    region,
    ROUND(AVG(avg_response_ms), 2) AS avg_response_ms,
    MAX(max_response_ms) AS max_response_ms,
    ROUND(AVG(avg_cpu_pct), 2) AS avg_cpu_pct,
    SUM(error_count) AS error_count
FROM api_metrics_5min_summary
WHERE endpoint = '/recommendations'
  AND region = 'US'
GROUP BY bucket, endpoint, region
ORDER BY bucket;


