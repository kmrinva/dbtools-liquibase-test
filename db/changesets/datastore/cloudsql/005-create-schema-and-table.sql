--liquibase formatted sql

--changeset poc-user:005_create-schema-and-table labels:cloudsql,ddl context:poc
--comment: Create schema and test table

CREATE SCHEMA poc_app_lnd;

CREATE TABLE IF NOT EXISTS poc_app_lnd.test_table (
  test_id BIGINT,
  code VARCHAR(10),
  description VARCHAR(255),
  created_at TIMESTAMPTZ
);

--rollback DROP TABLE IF EXISTS poc_app_lnd.test_table;