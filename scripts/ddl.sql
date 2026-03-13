DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_customers CASCADE;
DROP TABLE IF EXISTS dim_products CASCADE;
DROP TABLE IF EXISTS dim_stores CASCADE;
DROP TABLE IF EXISTS dim_sellers CASCADE;
DROP TABLE IF EXISTS dim_suppliers CASCADE;
DROP TABLE IF EXISTS dim_locations CASCADE;


CREATE TABLE dim_locations (
    location_id SERIAL PRIMARY KEY,
    country VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    CONSTRAINT uniq_loc UNIQUE NULLS NOT DISTINCT (country, state, city, postal_code)
);


CREATE TABLE dim_suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(150),
    contact VARCHAR(100),
    email VARCHAR(150),
    phone VARCHAR(50),
    address VARCHAR(200),
    location_id INT REFERENCES dim_locations(location_id)
);


CREATE TABLE dim_sellers (
    seller_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150),
    location_id INT REFERENCES dim_locations(location_id)
);


CREATE TABLE dim_stores (
    store_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(150),
    phone VARCHAR(50),
    location_string VARCHAR(200),
    location_id INT REFERENCES dim_locations(location_id)
);


CREATE TABLE dim_products (
    product_id INT PRIMARY KEY,
    name VARCHAR(200),
    category VARCHAR(100),
    brand VARCHAR(100),
    price DECIMAL(10,2),
    weight VARCHAR(50),
    color VARCHAR(50),
    size VARCHAR(50),
    material VARCHAR(100),
    description TEXT,
    rating DECIMAL(3,1),
    reviews INT,
    release_date DATE,
    expiry_date DATE,
    pet_category VARCHAR(100),
    supplier_id INT REFERENCES dim_suppliers(supplier_id)
);


CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150),
    age INT,
    pet_type VARCHAR(50),
    pet_name VARCHAR(100),
    pet_breed VARCHAR(100),
    location_id INT REFERENCES dim_locations(location_id)
);



CREATE TABLE fact_sales (
    sale_id SERIAL PRIMARY KEY, 
    sale_date DATE,
    quantity INT,
    total_price DECIMAL(10,2),
    customer_id INT REFERENCES dim_customers(customer_id),
    product_id INT REFERENCES dim_products(product_id),
    store_id INT REFERENCES dim_stores(store_id),
    seller_id INT REFERENCES dim_sellers(seller_id)
);