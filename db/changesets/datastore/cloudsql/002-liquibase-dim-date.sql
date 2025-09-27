--liquibase formatted sql

--changeset poc-user:002_dim_date labels:bigquery,ddl context:prod,dev
--comment: Create table only
CREATE TABLE IF NOT EXISTS poc_app_dw.liquibase_dim_date
(
  date_key       DATE        PRIMARY KEY,
  day_of_week    SMALLINT,
  day_name       TEXT,
  week_of_year   SMALLINT,
  month          SMALLINT,
  month_name     TEXT,
  quarter        SMALLINT,
  year           INTEGER,
  is_business_day BOOLEAN,
  my_last_column TEXT
);

COMMENT ON TABLE  poc_app_dw.liquibase_dim_date IS 'Date dimension with standard calendar attributes';

COMMENT ON COLUMN poc_app_dw.liquibase_dim_date.date_key        IS 'Business date (YYYY-MM-DD) – surrogate natural key';
COMMENT ON COLUMN poc_app_dw.liquibase_dim_date.day_of_week     IS 'ISO day of week (1=Mon … 7=Sun)';
COMMENT ON COLUMN poc_app_dw.liquibase_dim_date.day_name        IS 'Localized day name, e.g., Monday';
COMMENT ON COLUMN poc_app_dw.liquibase_dim_date.week_of_year    IS 'ISO week number (1–53)';
COMMENT ON COLUMN poc_app_dw.liquibase_dim_date.month           IS 'Month number (1–12)';
COMMENT ON COLUMN poc_app_dw.liquibase_dim_date.month_name      IS 'Localized month name, e.g., January';
COMMENT ON COLUMN poc_app_dw.liquibase_dim_date.quarter         IS 'Quarter number (1–4)';
COMMENT ON COLUMN poc_app_dw.liquibase_dim_date.year            IS 'Calendar year, e.g., 2025';
COMMENT ON COLUMN poc_app_dw.liquibase_dim_date.is_business_day IS 'True if typical business day';
COMMENT ON COLUMN poc_app_dw.liquibase_dim_date.my_last_column  IS 'Additional text column';

--rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_dim_date;
