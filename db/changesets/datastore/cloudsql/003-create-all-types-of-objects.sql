-- liquibase formatted sql

-- =====================================================
-- CloudSQL PostgreSQL - Complete Schema Objects Script
-- Schema: poc_app_dw
-- With Liquibase Changesets and Rollbacks
-- =====================================================

-- changeset author:set_search_path context:poc_app_dw
-- comment: Set search path to poc_app_dw schema
SET search_path TO poc_app_dw, public;
-- rollback SET search_path TO public;

-- =====================================================
-- 1. DOMAINS (Custom Data Types)
-- =====================================================

-- changeset author:create_domain_email_type context:poc_app_dw
-- comment: Create email_type domain
CREATE DOMAIN poc_app_dw.liquibase_email_type AS VARCHAR(255)
CHECK (VALUE ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
-- rollback DROP DOMAIN IF EXISTS poc_app_dw.liquibase_email_type CASCADE;

-- changeset author:create_domain_phone_type context:poc_app_dw
-- comment: Create phone_type domain
CREATE DOMAIN poc_app_dw.liquibase_phone_type AS VARCHAR(20)
CHECK (VALUE ~* '^\+?[0-9]{10,15}$');
-- rollback DROP DOMAIN IF EXISTS poc_app_dw.liquibase_phone_type CASCADE;

-- changeset author:create_domain_positive_integer context:poc_app_dw
-- comment: Create positive_integer domain
CREATE DOMAIN poc_app_dw.liquibase_positive_integer AS INTEGER
CHECK (VALUE > 0);
-- rollback DROP DOMAIN IF EXISTS poc_app_dw.liquibase_positive_integer CASCADE;

-- =====================================================
-- 2. ENUMS
-- =====================================================

-- changeset author:create_enum_user_status context:poc_app_dw
-- comment: Create user_status enum type
CREATE TYPE poc_app_dw.liquibase_user_status AS ENUM ('active', 'inactive', 'suspended', 'deleted');
-- rollback DROP TYPE IF EXISTS poc_app_dw.liquibase_user_status CASCADE;

-- changeset author:create_enum_order_status context:poc_app_dw
-- comment: Create order_status enum type
CREATE TYPE poc_app_dw.liquibase_order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');
-- rollback DROP TYPE IF EXISTS poc_app_dw.liquibase_order_status CASCADE;

-- changeset author:create_enum_payment_method context:poc_app_dw
-- comment: Create payment_method enum type
CREATE TYPE poc_app_dw.liquibase_payment_method AS ENUM ('credit_card', 'debit_card', 'paypal', 'bank_transfer');
-- rollback DROP TYPE IF EXISTS poc_app_dw.liquibase_payment_method CASCADE;

-- =====================================================
-- 3. COMPOSITE TYPES
-- =====================================================

-- changeset author:create_composite_address_type context:poc_app_dw
-- comment: Create address_type composite type
CREATE TYPE poc_app_dw.liquibase_address_type AS (
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50)
);
-- rollback DROP TYPE IF EXISTS poc_app_dw.liquibase_address_type CASCADE;

-- changeset author:create_composite_audit_info context:poc_app_dw
-- comment: Create audit_info composite type
CREATE TYPE poc_app_dw.liquibase_audit_info AS (
    created_by VARCHAR(100),
    created_at TIMESTAMP,
    modified_by VARCHAR(100),
    modified_at TIMESTAMP
);
-- rollback DROP TYPE IF EXISTS poc_app_dw.liquibase_audit_info CASCADE;

-- =====================================================
-- 4. SEQUENCES
-- =====================================================

-- changeset author:create_sequence_customer_id context:poc_app_dw
-- comment: Create customer_id_seq sequence
CREATE SEQUENCE poc_app_dw.liquibase_customer_id_seq
    START WITH 1000
    INCREMENT BY 1
    MINVALUE 1000
    MAXVALUE 999999999
    CACHE 10;
-- rollback DROP SEQUENCE IF EXISTS poc_app_dw.liquibase_customer_id_seq CASCADE;

-- changeset author:create_sequence_order_number context:poc_app_dw
-- comment: Create order_number_seq sequence
CREATE SEQUENCE poc_app_dw.liquibase_order_number_seq
    START WITH 100000
    INCREMENT BY 1
    CACHE 20;
-- rollback DROP SEQUENCE IF EXISTS poc_app_dw.liquibase_order_number_seq CASCADE;

-- changeset author:create_sequence_invoice_number context:poc_app_dw
-- comment: Create invoice_number_seq sequence
CREATE SEQUENCE poc_app_dw.liquibase_invoice_number_seq
    START WITH 1
    INCREMENT BY 1
    CACHE 5;
-- rollback DROP SEQUENCE IF EXISTS poc_app_dw.liquibase_invoice_number_seq CASCADE;

-- =====================================================
-- 5. TABLES
-- =====================================================

-- changeset author:create_table_customers context:poc_app_dw
-- comment: Create customers table
CREATE TABLE poc_app_dw.liquibase_customers (
    customer_id INTEGER PRIMARY KEY DEFAULT nextval('poc_app_dw.liquibase_customer_id_seq'),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email poc_app_dw.liquibase_email_type UNIQUE NOT NULL,
    phone poc_app_dw.liquibase_phone_type,
    status poc_app_dw.liquibase_user_status DEFAULT 'active',
    address poc_app_dw.liquibase_address_type,
    registration_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_customers CASCADE;

-- changeset author:create_table_suppliers context:poc_app_dw
-- comment: Create suppliers table
CREATE TABLE poc_app_dw.liquibase_suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200) NOT NULL,
    contact_email poc_app_dw.liquibase_email_type
);
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_suppliers CASCADE;

-- changeset author:create_table_products context:poc_app_dw
-- comment: Create products table
CREATE TABLE poc_app_dw.liquibase_products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    price NUMERIC(10, 2) CHECK (price >= 0),
    stock_quantity poc_app_dw.liquibase_positive_integer DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    supplier_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_products CASCADE;

-- changeset author:create_table_orders context:poc_app_dw
-- comment: Create orders table
CREATE TABLE poc_app_dw.liquibase_orders (
    order_id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE DEFAULT 'ORD-' || nextval('poc_app_dw.liquibase_order_number_seq'),
    customer_id INTEGER NOT NULL REFERENCES poc_app_dw.liquibase_customers(customer_id) ON DELETE CASCADE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status poc_app_dw.liquibase_order_status DEFAULT 'pending',
    total_amount NUMERIC(12, 2) DEFAULT 0,
    payment_method poc_app_dw.liquibase_payment_method,
    shipping_address poc_app_dw.liquibase_address_type,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_orders CASCADE;

-- changeset author:create_table_order_items context:poc_app_dw
-- comment: Create order_items table
CREATE TABLE poc_app_dw.liquibase_order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES poc_app_dw.liquibase_orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES poc_app_dw.liquibase_products(product_id),
    quantity INTEGER CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) CHECK (unit_price >= 0),
    subtotal NUMERIC(12, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    discount_percentage NUMERIC(5, 2) DEFAULT 0 CHECK (discount_percentage BETWEEN 0 AND 100)
);
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_order_items CASCADE;

-- changeset author:create_table_audit_log context:poc_app_dw
-- comment: Create audit_log table
CREATE TABLE poc_app_dw.liquibase_audit_log (
    log_id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    record_id BIGINT,
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_audit_log CASCADE;

-- changeset author:create_table_sales_data context:poc_app_dw
-- comment: Create partitioned sales_data table
CREATE TABLE poc_app_dw.liquibase_sales_data (
    sale_id BIGSERIAL,
    sale_date DATE NOT NULL,
    customer_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    amount NUMERIC(12, 2),
    PRIMARY KEY (sale_id, sale_date)
) PARTITION BY RANGE (sale_date);
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_sales_data CASCADE;

-- changeset author:create_partition_sales_data_2024 context:poc_app_dw
-- comment: Create sales_data partition for 2024
CREATE TABLE poc_app_dw.liquibase_sales_data_2024 PARTITION OF poc_app_dw.liquibase_sales_data
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_sales_data_2024 CASCADE;

-- changeset author:create_partition_sales_data_2025 context:poc_app_dw
-- comment: Create sales_data partition for 2025
CREATE TABLE poc_app_dw.liquibase_sales_data_2025 PARTITION OF poc_app_dw.liquibase_sales_data
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_sales_data_2025 CASCADE;

-- changeset author:create_table_session_data context:poc_app_dw
-- comment: Create unlogged session_data table
CREATE UNLOGGED TABLE poc_app_dw.liquibase_session_data (
    session_id VARCHAR(100) PRIMARY KEY,
    user_id INTEGER,
    session_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_session_data CASCADE;

-- changeset author:create_table_categories context:poc_app_dw
-- comment: Create categories table for hierarchical data
CREATE TABLE poc_app_dw.liquibase_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INTEGER REFERENCES poc_app_dw.liquibase_categories(category_id)
);
-- rollback DROP TABLE IF EXISTS poc_app_dw.liquibase_categories CASCADE;

-- =====================================================
-- 6. FOREIGN KEY CONSTRAINTS
-- =====================================================

-- changeset author:add_fk_products_supplier context:poc_app_dw
-- comment: Add foreign key from products to suppliers
ALTER TABLE poc_app_dw.liquibase_products
ADD CONSTRAINT fk_products_supplier 
FOREIGN KEY (supplier_id) REFERENCES poc_app_dw.liquibase_suppliers(supplier_id) 
ON DELETE SET NULL ON UPDATE CASCADE;
-- rollback ALTER TABLE poc_app_dw.liquibase_products DROP CONSTRAINT IF EXISTS fk_products_supplier;

-- changeset author:add_check_total_amount context:poc_app_dw
-- comment: Add check constraint for total_amount
ALTER TABLE poc_app_dw.liquibase_orders
ADD CONSTRAINT chk_total_amount_positive CHECK (total_amount >= 0);
-- rollback ALTER TABLE poc_app_dw.liquibase_orders DROP CONSTRAINT IF EXISTS chk_total_amount_positive;

-- =====================================================
-- 7. INDEXES
-- =====================================================

-- changeset author:create_index_customers_email context:poc_app_dw
-- comment: Create index on customers email
CREATE INDEX idx_customers_email ON poc_app_dw.liquibase_customers(email);
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_customers_email;

-- changeset author:create_index_customers_status context:poc_app_dw
-- comment: Create index on customers status
CREATE INDEX idx_customers_status ON poc_app_dw.liquibase_customers(status);
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_customers_status;

-- changeset author:create_index_customers_registration context:poc_app_dw
-- comment: Create index on customers registration_date
CREATE INDEX idx_customers_registration ON poc_app_dw.liquibase_customers(registration_date);
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_customers_registration;

-- changeset author:create_index_active_products context:poc_app_dw
-- comment: Create partial index on active products
CREATE INDEX idx_active_products ON poc_app_dw.liquibase_products(product_id) 
WHERE is_active = TRUE;
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_active_products;

-- changeset author:create_index_orders_customer_date context:poc_app_dw
-- comment: Create composite index on orders
CREATE INDEX idx_orders_customer_date ON poc_app_dw.liquibase_orders(customer_id, order_date DESC);
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_orders_customer_date;

-- changeset author:create_index_customers_id_hash context:poc_app_dw
-- comment: Create hash index on customers
CREATE INDEX idx_customers_id_hash ON poc_app_dw.liquibase_customers USING HASH (customer_id);
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_customers_id_hash;

-- changeset author:create_index_audit_old_values context:poc_app_dw
-- comment: Create GIN index on audit_log old_values
CREATE INDEX idx_audit_old_values ON poc_app_dw.liquibase_audit_log USING GIN (old_values);
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_audit_old_values;

-- changeset author:create_index_audit_new_values context:poc_app_dw
-- comment: Create GIN index on audit_log new_values
CREATE INDEX idx_audit_new_values ON poc_app_dw.liquibase_audit_log USING GIN (new_values);
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_audit_new_values;

-- changeset author:create_index_products_fts context:poc_app_dw
-- comment: Create GiST index for full-text search on products
CREATE INDEX idx_products_fts ON poc_app_dw.liquibase_products USING GiST (to_tsvector('english', product_name || ' ' || COALESCE(description, '')));
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_products_fts;

-- changeset author:create_index_sales_date_brin context:poc_app_dw
-- comment: Create BRIN index on sales_data
CREATE INDEX idx_sales_date_brin ON poc_app_dw.liquibase_sales_data USING BRIN (sale_date);
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_sales_date_brin;

-- changeset author:create_index_customers_full_name context:poc_app_dw
-- comment: Create expression index on customers full name
CREATE INDEX idx_customers_full_name ON poc_app_dw.liquibase_customers((first_name || ' ' || last_name));
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_customers_full_name;

-- changeset author:create_index_unique_customer_email context:poc_app_dw
-- comment: Create unique index on lowercase customer email
CREATE UNIQUE INDEX idx_unique_customer_email ON poc_app_dw.liquibase_customers(LOWER(email));
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_unique_customer_email;

-- =====================================================
-- 8. VIEWS
-- =====================================================

-- changeset author:create_view_active_customers context:poc_app_dw
-- comment: Create view for active customers
CREATE VIEW poc_app_dw.liquibase_active_customers AS
SELECT customer_id, first_name, last_name, email, phone
FROM poc_app_dw.liquibase_customers
WHERE status = 'active';
-- rollback DROP VIEW IF EXISTS poc_app_dw.liquibase_active_customers;

-- changeset author:create_view_order_summary context:poc_app_dw
-- comment: Create view for order summary with joins
CREATE VIEW poc_app_dw.liquibase_order_summary AS
SELECT 
    o.order_id,
    o.order_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    o.order_date,
    o.status,
    o.total_amount,
    COUNT(oi.order_item_id) AS total_items
FROM poc_app_dw.liquibase_orders o
JOIN poc_app_dw.liquibase_customers c ON o.customer_id = c.customer_id
LEFT JOIN poc_app_dw.liquibase_order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_number, c.first_name, c.last_name, c.email, o.order_date, o.status, o.total_amount;
-- rollback DROP VIEW IF EXISTS poc_app_dw.liquibase_order_summary;

-- changeset author:create_materialized_view_customer_statistics context:poc_app_dw
-- comment: Create materialized view for customer statistics
CREATE MATERIALIZED VIEW poc_app_dw.liquibase_customer_statistics AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM poc_app_dw.liquibase_customers c
LEFT JOIN poc_app_dw.liquibase_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;
-- rollback DROP MATERIALIZED VIEW IF EXISTS poc_app_dw.liquibase_customer_statistics;

-- changeset author:create_index_mv_customer_stats context:poc_app_dw
-- comment: Create index on materialized view
CREATE INDEX idx_mv_customer_stats ON poc_app_dw.liquibase_customer_statistics(customer_id);
-- rollback DROP INDEX IF EXISTS poc_app_dw.liquibase_idx_mv_customer_stats;

-- changeset author:create_view_category_hierarchy context:poc_app_dw
-- comment: Create recursive view for category hierarchy
CREATE VIEW poc_app_dw.liquibase_category_hierarchy AS
WITH RECURSIVE category_tree AS (
    SELECT category_id, category_name, parent_category_id, 1 AS level
    FROM poc_app_dw.liquibase_categories
    WHERE parent_category_id IS NULL
    UNION ALL
    SELECT c.category_id, c.category_name, c.parent_category_id, ct.level + 1
    FROM poc_app_dw.liquibase_categories c
    JOIN category_tree ct ON c.parent_category_id = ct.category_id
)
SELECT * FROM category_tree;
-- rollback DROP VIEW IF EXISTS poc_app_dw.liquibase_category_hierarchy;

-- =====================================================
-- 9. FUNCTIONS
-- =====================================================

-- changeset author:create_function_get_customer_full_name context:poc_app_dw
-- comment: Create function to get customer full name
CREATE OR REPLACE FUNCTION poc_app_dw.liquibase_get_customer_full_name(p_customer_id INTEGER)
RETURNS VARCHAR(200)
LANGUAGE plpgsql
AS $$
DECLARE
    v_full_name VARCHAR(200);
BEGIN
    SELECT first_name || ' ' || last_name INTO v_full_name
    FROM poc_app_dw.liquibase_customers
    WHERE customer_id = p_customer_id;
    
    RETURN v_full_name;
END;
$$;
-- rollback DROP FUNCTION IF EXISTS poc_app_dw.liquibase_get_customer_full_name(INTEGER);

-- changeset author:create_function_get_order_stats context:poc_app_dw
-- comment: Create function to get order statistics
CREATE OR REPLACE FUNCTION poc_app_dw.liquibase_get_order_stats(
    p_customer_id INTEGER,
    OUT total_orders INTEGER,
    OUT total_spent NUMERIC,
    OUT avg_order_value NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT 
        COUNT(*),
        COALESCE(SUM(total_amount), 0),
        COALESCE(AVG(total_amount), 0)
    INTO total_orders, total_spent, avg_order_value
    FROM poc_app_dw.liquibase_orders
    WHERE customer_id = p_customer_id;
END;
$$;
-- rollback DROP FUNCTION IF EXISTS poc_app_dw.liquibase_get_order_stats(INTEGER);

-- changeset author:create_function_get_top_products context:poc_app_dw
-- comment: Create table-returning function for top products
CREATE OR REPLACE FUNCTION poc_app_dw.liquibase_get_top_products(p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
    product_id INTEGER,
    product_name VARCHAR,
    total_sold BIGINT,
    revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.quantity)::BIGINT AS total_sold,
        SUM(oi.subtotal) AS revenue
    FROM poc_app_dw.liquibase_products p
    JOIN poc_app_dw.liquibase_order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
    ORDER BY revenue DESC
    LIMIT p_limit;
END;
$$;
-- rollback DROP FUNCTION IF EXISTS poc_app_dw.liquibase_get_top_products(INTEGER);

-- changeset author:create_function_calculate_discount context:poc_app_dw
-- comment: Create function to calculate discount based on quantity
CREATE OR REPLACE FUNCTION poc_app_dw.liquibase_calculate_discount(
    quantity INTEGER,
    unit_price NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    IF quantity >= 100 THEN
        RETURN unit_price * 0.20;
    ELSIF quantity >= 50 THEN
        RETURN unit_price * 0.15;
    ELSIF quantity >= 10 THEN
        RETURN unit_price * 0.10;
    ELSE
        RETURN 0;
    END IF;
END;
$$;
-- rollback DROP FUNCTION IF EXISTS poc_app_dw.liquibase_calculate_discount(INTEGER, NUMERIC);

-- =====================================================
-- 10. STORED PROCEDURES
-- =====================================================

-- changeset author:create_procedure_process_order context:poc_app_dw
-- comment: Create procedure to process an order
CREATE OR REPLACE PROCEDURE poc_app_dw.liquibase_process_order(
    p_customer_id INTEGER,
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_payment_method poc_app_dw.liquibase_payment_method
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id BIGINT;
    v_product_price NUMERIC;
    v_total_amount NUMERIC;
BEGIN
    -- Get product price
    SELECT price INTO v_product_price
    FROM poc_app_dw.liquibase_products
    WHERE product_id = p_product_id AND is_active = TRUE;
    
    IF v_product_price IS NULL THEN
        RAISE EXCEPTION 'Product not found or inactive';
    END IF;
    
    -- Calculate total
    v_total_amount := v_product_price * p_quantity;
    
    -- Create order
    INSERT INTO poc_app_dw.liquibase_orders (customer_id, total_amount, payment_method)
    VALUES (p_customer_id, v_total_amount, p_payment_method)
    RETURNING order_id INTO v_order_id;
    
    -- Create order item
    INSERT INTO poc_app_dw.liquibase_order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, p_product_id, p_quantity, v_product_price);
    
    -- Update product stock
    UPDATE poc_app_dw.liquibase_products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = p_product_id;
    
    COMMIT;
END;
$$;
-- rollback DROP PROCEDURE IF EXISTS poc_app_dw.liquibase_process_order(INTEGER, INTEGER, INTEGER, poc_app_dw.liquibase_payment_method);

-- =====================================================
-- 11. TRIGGER FUNCTIONS
-- =====================================================

-- changeset author:create_trigger_function_update_timestamp context:poc_app_dw
-- comment: Create trigger function to update timestamp
CREATE OR REPLACE FUNCTION poc_app_dw.liquibase_update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;
-- rollback DROP FUNCTION IF EXISTS poc_app_dw.liquibase_update_timestamp() CASCADE;

-- changeset author:create_trigger_function_audit context:poc_app_dw
-- comment: Create trigger function for audit logging
CREATE OR REPLACE FUNCTION poc_app_dw.liquibase_audit_trigger_func()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO poc_app_dw.liquibase_audit_log (table_name, operation, record_id, new_values, changed_by)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.customer_id, row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO poc_app_dw.liquibase_audit_log (table_name, operation, record_id, old_values, new_values, changed_by)
        VALUES (TG_TABLE_NAME, TG_OP, NEW.customer_id, row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO poc_app_dw.liquibase_audit_log (table_name, operation, record_id, old_values, changed_by)
        VALUES (TG_TABLE_NAME, TG_OP, OLD.customer_id, row_to_json(OLD), current_user);
        RETURN OLD;
    END IF;
END;
$$;
-- rollback DROP FUNCTION IF EXISTS poc_app_dw.liquibase_audit_trigger_func() CASCADE;

-- changeset author:create_trigger_function_active_customers_insert context:poc_app_dw
-- comment: Create trigger function for active customers view insert
CREATE OR REPLACE FUNCTION poc_app_dw.liquibase_active_customers_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO poc_app_dw.liquibase_customers (first_name, last_name, email, phone, status)
    VALUES (NEW.first_name, NEW.last_name, NEW.email, NEW.phone, 'active');
    RETURN NEW;
END;
$$;
-- rollback DROP FUNCTION IF EXISTS poc_app_dw.liquibase_active_customers_insert() CASCADE;

-- =====================================================
-- 12. TRIGGERS
-- =====================================================

-- changeset author:create_trigger_customers_update context:poc_app_dw
-- comment: Create trigger for customers update timestamp
CREATE TRIGGER trg_customers_update
BEFORE UPDATE ON poc_app_dw.liquibase_customers
FOR EACH ROW
EXECUTE FUNCTION poc_app_dw.liquibase_update_timestamp();
-- rollback DROP TRIGGER IF EXISTS trg_customers_update ON poc_app_dw.liquibase_customers;

-- changeset author:create_trigger_products_update context:poc_app_dw
-- comment: Create trigger for products update timestamp
CREATE TRIGGER trg_products_update
BEFORE UPDATE ON poc_app_dw.liquibase_products
FOR EACH ROW
EXECUTE FUNCTION poc_app_dw.liquibase_update_timestamp();
-- rollback DROP TRIGGER IF EXISTS trg_products_update ON poc_app_dw.liquibase_products;

-- changeset author:create_trigger_orders_update context:poc_app_dw
-- comment: Create trigger for orders update timestamp
CREATE TRIGGER trg_orders_update
BEFORE UPDATE ON poc_app_dw.liquibase_orders
FOR EACH ROW
EXECUTE FUNCTION poc_app_dw.liquibase_update_timestamp();
-- rollback DROP TRIGGER IF EXISTS trg_orders_update ON poc_app_dw.liquibase_orders;

-- changeset author:create_trigger_customers_audit context:poc_app_dw
-- comment: Create audit trigger for customers table
CREATE TRIGGER trg_customers_audit
AFTER INSERT OR UPDATE OR DELETE ON poc_app_dw.liquibase_customers
FOR EACH ROW
EXECUTE FUNCTION poc_app_dw
-- rollback DROP TRIGGER IF EXISTS trg_customers_audit ON poc_app_dw.liquibase_orders;