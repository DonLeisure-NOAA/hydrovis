DROP TABLE IF EXISTS publish.srf_18hr_max_coastal_inundation_depth_hi;
CREATE TABLE publish.srf_18hr_max_coastal_inundation_depth_hi (
    reference_time TEXT,
    valid_time TEXT,
    update_time TEXT
);
INSERT INTO publish.srf_18hr_max_coastal_inundation_depth_hi
VALUES (
    to_char('1900-01-01 00:00:00'::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS UTC'), 
    to_char('1900-01-01 00:00:00'::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS UTC'), 
    to_char(now()::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS UTC')
);