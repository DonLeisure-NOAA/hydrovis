DROP TABLE IF EXISTS publish.srf_48hr_accum_precip_prvi;
CREATE TABLE publish.srf_48hr_accum_precip_prvi (
    reference_time TEXT,
    update_time TEXT
);
INSERT INTO publish.srf_48hr_accum_precip_prvi
VALUES (
    to_char('1900-01-01 00:00:00'::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS UTC'),
    to_char(now()::timestamp without time zone, 'YYYY-MM-DD HH24:MI:SS UTC')
);