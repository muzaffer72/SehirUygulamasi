CREATE TABLE IF NOT EXISTS city_stats (
  id integer,
  city_id integer,
  year character varying(4),
  unemployment_rate numeric,
  healthcare_access numeric,
  education_quality numeric,
  infrastructure_quality numeric,
  safety_index numeric,
  cost_of_living numeric,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

