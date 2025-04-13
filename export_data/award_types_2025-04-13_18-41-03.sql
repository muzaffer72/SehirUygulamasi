CREATE TABLE IF NOT EXISTS award_types (
  id integer,
  name character varying(100),
  description text,
  icon_url text,
  badge_url text,
  color character varying(20),
  points integer,
  created_at timestamp without time zone,
  is_system boolean,
  icon character varying(100),
  min_rate numeric,
  max_rate numeric,
  badge_color character varying(20)
);

