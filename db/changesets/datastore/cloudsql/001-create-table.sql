--liquibase formatted sql

--changeset poc-user:001_create_table labels:cloudsql,ddl context:poc
--comment: Create table only
CREATE TABLE IF NOT EXISTS poc_app_dw.demo_customers (
  customer_id BIGINT,
  name VARCHAR(255),
  created_at TIMESTAMPTZ
);

--rollback DROP TABLE IF EXISTS poc_app_dw.demo_customers;