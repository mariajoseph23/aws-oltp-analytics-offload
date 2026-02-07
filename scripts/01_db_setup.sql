-- Creates the OLTP schema used by the demo loader script.

CREATE DATABASE IF NOT EXISTS appdb;
USE appdb;

-- Keep it simple: one core OLTP table.
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  status VARCHAR(16) NOT NULL,
  order_total DECIMAL(10,2) NOT NULL,
  created_at DATETIME NOT NULL,

  KEY idx_customer_created (customer_id, created_at),
  KEY idx_created_status (created_at, status)
) ENGINE=InnoDB;

-- Optional sanity seed row
INSERT INTO orders(customer_id, status, order_total, created_at)
VALUES (1, 'NEW', 19.99, UTC_TIMESTAMP());