DROP TABLE IF EXISTS publish.ana_past_7day_max_high_flow_magnitude;

SELECT channels.feature_id,
	channels.feature_id::TEXT AS feature_id_str,
	channels.strm_order,
	channels.name,
	channels.huc6,
	channels.state,
	hfm_7day.nwm_vers,
	hfm_7day.reference_time,
	hfm_7day.reference_time AS valid_time,
	hfm_7day.discharge_cfs AS max_flow_7day_cfs,
	CASE
		WHEN discharge_cfs >= thresholds.rf_50_0_17C THEN '2'
		WHEN discharge_cfs >= thresholds.rf_25_0_17C THEN '4'
		WHEN discharge_cfs >= thresholds.rf_10_0_17C THEN '10'
		WHEN discharge_cfs >= thresholds.rf_5_0_17C THEN '20'
		WHEN discharge_cfs >= thresholds.rf_2_0_17C THEN '50'
		WHEN discharge_cfs >= thresholds.high_water_threshold THEN '>50'
		ELSE NULL
	END AS recur_cat_7day,
	thresholds.high_water_threshold AS high_water_threshold,
	thresholds.rf_2_0_17C AS flow_2yr,
	thresholds.rf_5_0_17C AS flow_5yr,
	thresholds.rf_10_0_17C AS flow_10yr,
	thresholds.rf_25_0_17C AS flow_25yr,
	thresholds.rf_50_0_17C AS flow_50yr,
	to_char(now()::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS UTC') AS update_time,
	channels.geom
INTO publish.ana_past_7day_max_high_flow_magnitude
FROM derived.channels_CONUS channels
JOIN derived.recurrence_flows_CONUS thresholds ON (channels.feature_id = thresholds.feature_id)
JOIN cache.max_flows_ana_7day hfm_7day ON (channels.feature_id = hfm_7day.feature_id)
WHERE (thresholds.high_water_threshold > 0) AND hfm_7day.discharge_cfs >= thresholds.high_water_threshold