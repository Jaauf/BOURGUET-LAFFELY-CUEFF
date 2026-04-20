CREATE TABLE IF NOT EXISTS product (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO product (name, price) VALUES
    ('Product A', 9.99),
    ('Product B', 19.99),
    ('Product C', 4.99);
