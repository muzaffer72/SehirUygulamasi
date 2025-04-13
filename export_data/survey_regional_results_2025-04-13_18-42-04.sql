CREATE TABLE IF NOT EXISTS survey_regional_results (
  id integer,
  survey_id integer,
  option_id integer,
  region_type character varying(20),
  region_id integer,
  vote_count integer
);

