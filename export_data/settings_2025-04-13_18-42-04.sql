CREATE TABLE IF NOT EXISTS settings (
  id integer,
  site_name character varying(100),
  site_description text,
  admin_email character varying(255),
  maintenance_mode boolean,
  email_notifications boolean,
  push_notifications boolean,
  new_post_notifications boolean,
  new_user_notifications boolean,
  api_key character varying(100),
  webhook_url character varying(255),
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

INSERT INTO settings (id, site_name, site_description, admin_email, maintenance_mode, email_notifications, push_notifications, new_post_notifications, new_user_notifications, api_key, webhook_url, created_at, updated_at) VALUES ('1', 'ŞikayetVar Yönetim', 'Belediye ve Valilik\'e yönelik şikayet ve öneri paylaşım platformu', 'admin@sikayetvar.com', '', '1', '1', '1', '1', 'ca69cdad8162fe78357ffe4e568507db', 'https://sikayetvar.com/api/webhook', '2025-04-11 13:43:28.278784', '2025-04-11 13:43:28.278784');
