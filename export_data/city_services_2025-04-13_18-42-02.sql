CREATE TABLE IF NOT EXISTS city_services (
  id integer,
  city_id integer,
  name character varying(255),
  description text,
  address character varying(255),
  phone character varying(50),
  website character varying(255),
  type character varying(50),
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

