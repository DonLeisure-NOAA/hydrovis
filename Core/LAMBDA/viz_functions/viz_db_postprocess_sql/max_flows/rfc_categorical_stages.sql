DROP TABLE IF EXISTS cache.rfc_categorical_stages;

-- Create temporary routelink tables, which significantly speeds up recursive upstream/downstream
-- calculation
SELECT *
INTO ingest.routelink
FROM external.nwm_routelink;

SELECT 
	main.nwm_feature_id, 
	upstream.nwm_feature_id AS upstream_feature_id, 
	main.stream_length, 
	main.stream_order
INTO ingest.routelink_up
FROM ingest.routelink AS main
JOIN ingest.routelink AS upstream
	ON main.nwm_feature_id = upstream.downstream_feature_id;

WITH RECURSIVE

basis_site AS (
	SELECT * 
	FROM ingest.stage_based_catfim_sites
	WHERE mapped IS TRUE
),

upstream_trace AS (
	SELECT 
		rl.nwm_feature_id as root_feature_id, 
		rl.nwm_feature_id as trace_feature_id, 
		rl.upstream_feature_id, 
		rl.stream_order, 
		rl.stream_length, 
		SUM(CAST(0 as float)) as trace_length
	FROM basis_site
	INNER JOIN ingest.routelink_up AS rl
		ON rl.nwm_feature_id = basis_site.nwm_feature_id
	GROUP BY trace_feature_id, upstream_feature_id, stream_order, stream_length

	UNION

	SELECT 
		upstream_trace.root_feature_id, 
		iter.nwm_feature_id as trace_feature_id, 
		iter.upstream_feature_id, 
		iter.stream_order, 
		iter.stream_length, 
		upstream_trace.trace_length + iter.stream_length as trace_length
	FROM ingest.routelink_up iter
	JOIN upstream_trace 
		ON iter.nwm_feature_id = upstream_trace.upstream_feature_id
		AND iter.stream_order = upstream_trace.stream_order
		AND upstream_trace.trace_length < (5 * 1609.34)  -- Miles converted to meters
		AND upstream_trace.trace_length + iter.stream_length < (6 * 1609.34)  -- Miles converted to meters
),

downstream_trace AS (
	SELECT 
		rl.nwm_feature_id as root_feature_id, 
		rl.nwm_feature_id as trace_feature_id, 
		rl.downstream_feature_id, 
		rl.stream_order, 
		rl.stream_length, 
		SUM(CAST(0 as float)) as trace_length
	FROM basis_site
	INNER JOIN ingest.routelink AS rl
		ON rl.nwm_feature_id = basis_site.nwm_feature_id
	GROUP BY trace_feature_id, downstream_feature_id, stream_order, stream_length

	UNION

	SELECT 
		downstream_trace.root_feature_id, 
		iter.nwm_feature_id as trace_feature_id, 
		iter.downstream_feature_id, 
		iter.stream_order, 
		iter.stream_length, 
		downstream_trace.trace_length + iter.stream_length as trace_length
	FROM ingest.routelink iter
	JOIN downstream_trace 
		ON iter.nwm_feature_id = downstream_trace.downstream_feature_id
		AND iter.stream_order = downstream_trace.stream_order
		AND downstream_trace.trace_length < (5 * 1609.34)  -- Miles converted to meters
		AND downstream_trace.trace_length + iter.stream_length < (6 * 1609.34)  -- Miles converted to meters
),

trace AS (
	SELECT 
		root_feature_id,
		trace_feature_id
	FROM downstream_trace

	UNION

	SELECT 
		root_feature_id,
		trace_feature_id
	FROM upstream_trace
)

SELECT
	trace.root_feature_id as nwm_feature_id,
	trace.trace_feature_id,
	basis_site.nws_station_id,
	adj_action_stage_m,
	adj_action_stage_ft,
	adj_minor_stage_m,
	adj_minor_stage_ft,
	adj_moderate_stage_m,
	adj_moderate_stage_ft,
	adj_major_stage_m,
	adj_major_stage_ft,
	adj_record_stage_m,
	adj_record_stage_ft
INTO cache.rfc_categorical_stages
FROM trace
LEFT JOIN basis_site
	ON basis_site.nwm_feature_id = trace.root_feature_id;

DROP TABLE IF EXISTS ingest.routelink;
DROP TABLE IF EXISTS ingest.routelink_up;