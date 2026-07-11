/*
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
*/

/*
SELECT hypertable_name, num_dimensions
FROM timescaledb_information.hypertables
ORDER BY hypertable_name;
*/

/*
SELECT
    hypertable_name,
    num_dimensions
FROM timescaledb_information.hypertables
ORDER BY hypertable_name;
*/

/*
SELECT
    hypertable_name,
    COUNT(*) AS chunk_count
FROM timescaledb_information.chunks
GROUP BY hypertable_name
ORDER BY hypertable_name;
*/

/*

SELECT
    hypertable_name,
    dimension_number,
    column_name,
    column_type,
    dimension_type,
    time_interval
FROM timescaledb_information.dimensions
WHERE hypertable_name IN ('media_events', 'api_metrics')
ORDER BY hypertable_name, dimension_number;

*/

/*
SELECT
    hypertable_name,
    chunk_name,
    range_start,
    range_end
FROM timescaledb_information.chunks
WHERE hypertable_name IN ('media_events', 'api_metrics')
ORDER BY hypertable_name, range_start;

/*
TRUNCATE TABLE media_events, api_metrics, content_catalog
RESTART IDENTITY CASCADE;
*/

/*
SELECT COUNT(*) AS media_events_count
FROM media_events;
*/

/*
DROP TABLE IF EXISTS media_events_upload;

CREATE TABLE media_events_upload (
    event_time      TIMESTAMPTZ NOT NULL,
    user_id         INTEGER NOT NULL,
    content_id      INTEGER NOT NULL,
    event_type      TEXT NOT NULL,
    device_type     TEXT NOT NULL,
    region          TEXT NOT NULL,
    watch_seconds   INTEGER NOT NULL,
    bitrate_kbps    INTEGER,
    buffer_ms       INTEGER,
    app_version     TEXT
);
*/


/*
SELECT 'content_catalog' AS table_name, COUNT(*) AS row_count
FROM content_catalog

UNION ALL

SELECT 'media_events' AS table_name, COUNT(*) AS row_count
FROM media_events

UNION ALL

SELECT 'api_metrics' AS table_name, COUNT(*) AS row_count
FROM api_metrics;
*/




