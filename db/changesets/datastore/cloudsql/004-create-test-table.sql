--liquibase formatted sql

--changeset poc-user:004_create_test_table labels:cloudsql,ddl context:poc
--comment: Create test table only

CREATE TABLE IF NOT EXISTS poc_app_dw.test_table (
  test_id BIGINT,
  code VARCHAR(10),
  description VARCHAR(255),
  created_at TIMESTAMPTZ
);

--rollback DROP TABLE IF EXISTS poc_app_dw.test_table;