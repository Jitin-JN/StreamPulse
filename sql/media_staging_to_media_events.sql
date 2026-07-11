INSERT INTO media_events (
    event_time,
    user_id,
    content_id,
    event_type,
    device_type,
    region,
    watch_seconds,
    bitrate_kbps,
    buffer_ms,
    app_version
)
SELECT
    event_time,
    user_id,
    content_id,
    event_type,
    device_type,
    region,
    watch_seconds,
    bitrate_kbps,
    buffer_ms,
    app_version
FROM media_events_upload;