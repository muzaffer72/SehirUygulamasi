CREATE TABLE IF NOT EXISTS city_projects (
  id integer,
  city_id integer,
  name character varying(255),
  description text,
  status character varying(20),
  budget numeric,
  start_date date,
  end_date date,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

INSERT INTO city_projects (id, city_id, name, description, status, budget, start_date, end_date, created_at, updated_at) VALUES ('1', '26', 'TEST', 'Test proje', 'planned', '1500000.00', '2025-04-18', '2026-07-01', '2025-04-11 18:18:11.569448', '2025-04-11 18:18:11.569448');
