CREATE TABLE product (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price INT NOT NULL,
    description TEXT
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL
);

INSERT INTO product (name, price, description) VALUES
    ('Laptop', 999, 'A high-performance laptop'),
    ('Smartphone', 699, 'A latest smartphone with advanced features');

INSERT INTO users (username, email, password) VALUES
    ('john_doe', 'john.doe@example.com', 'securepassword123'),
    ('jane_smith', 'jane.smith@example.com', 'anothersecurepassword456');