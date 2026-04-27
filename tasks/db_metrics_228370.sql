SET NOCOUNT ON;

-- 228370 DB metrics snapshot script (before/after).
-- Designed for csv-friendly output (no PRINT). Run once BEFORE load, once AFTER load.

DECLARE @ts_utc DATETIME2(0) = SYSUTCDATETIME();

-- Perf counters (selected)
SELECT
    CONVERT(VARCHAR(19), @ts_utc, 120) + 'Z' AS ts_utc,
    object_name,
    counter_name,
    instance_name,
    cntr_value,
    cntr_type
FROM sys.dm_os_performance_counters
WHERE
    (
        object_name LIKE '%SQL Statistics%' AND counter_name IN ('Batch Requests/sec')
    )
    OR (
        object_name LIKE '%General Statistics%' AND counter_name IN ('User Connections')
    )
    OR (
        object_name LIKE '%Locks%' AND counter_name IN ('Lock Waits/sec', 'Lock Wait Time (ms)')
    )
ORDER BY object_name, counter_name, instance_name;

-- Wait stats (top by cumulative wait_time_ms). Deltas are computed outside SQL.
SELECT TOP (50)
    CONVERT(VARCHAR(19), @ts_utc, 120) + 'Z' AS ts_utc,
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE 'SLEEP%'
ORDER BY wait_time_ms DESC;

