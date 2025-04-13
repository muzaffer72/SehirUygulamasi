CREATE TABLE IF NOT EXISTS city_events (
  id integer,
  city_id integer,
  name character varying(255),
  description text,
  location character varying(255),
  event_date date,
  event_time time without time zone,
  type character varying(50),
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

