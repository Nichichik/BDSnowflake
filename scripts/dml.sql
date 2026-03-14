COPY mock_data FROM '/data/MOCK_DATA.csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA (1).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA (2).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA (3).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA (4).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA (5).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA (6).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA (7).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA (8).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/data/MOCK_DATA (9).csv' DELIMITER ',' CSV HEADER;

INSERT INTO dim_locations (country, state, city, postal_code)
SELECT DISTINCT store_country, store_state, store_city, NULL FROM mock_data WHERE store_city IS NOT NULL
UNION
SELECT DISTINCT supplier_country, NULL, supplier_city, NULL FROM mock_data WHERE supplier_city IS NOT NULL
UNION
SELECT DISTINCT customer_country, NULL, NULL, customer_postal_code FROM mock_data WHERE customer_postal_code IS NOT NULL
UNION
SELECT DISTINCT seller_country, NULL, NULL, seller_postal_code FROM mock_data WHERE seller_postal_code IS NOT NULL
ON CONFLICT DO NOTHING;


INSERT INTO dim_suppliers (name, contact, email, phone, address, location_id)
SELECT DISTINCT md.supplier_name, md.supplier_contact, md.supplier_email, md.supplier_phone, md.supplier_address, loc.location_id
FROM mock_data md
LEFT JOIN dim_locations loc ON md.supplier_city = loc.city AND md.supplier_country = loc.country AND loc.postal_code IS NULL;


INSERT INTO dim_sellers (seller_id, first_name, last_name, email, location_id)
SELECT DISTINCT ON (md.sale_seller_id) md.sale_seller_id, md.seller_first_name, md.seller_last_name, md.seller_email, loc.location_id
FROM mock_data md
LEFT JOIN dim_locations loc ON md.seller_postal_code = loc.postal_code AND md.seller_country = loc.country;


INSERT INTO dim_stores (name, email, phone, location_string, location_id)
SELECT DISTINCT md.store_name, md.store_email, md.store_phone, md.store_location, loc.location_id
FROM mock_data md
LEFT JOIN dim_locations loc ON md.store_city = loc.city AND md.store_state = loc.state AND md.store_country = loc.country;


INSERT INTO dim_products (product_id, name, category, brand, price, weight, color, size, material, description, rating, reviews, release_date, expiry_date, pet_category, supplier_id)
SELECT DISTINCT ON (md.sale_product_id)
    md.sale_product_id, md.product_name, md.product_category, md.product_brand, md.product_price,
    md.product_weight, md.product_color, md.product_size, md.product_material, md.product_description,
    CAST(md.product_rating AS DECIMAL(3,1)), 
    CAST(md.product_reviews AS INT),
    TO_DATE(md.product_release_date, 'MM/DD/YYYY'),
    TO_DATE(md.product_expiry_date, 'MM/DD/YYYY'),
    md.pet_category, sup.supplier_id
FROM mock_data md
JOIN dim_suppliers sup ON md.supplier_name = sup.name;


INSERT INTO dim_customers (customer_id, first_name, last_name, email, age, pet_type, pet_name, pet_breed, location_id)
SELECT DISTINCT ON (md.sale_customer_id)
    md.sale_customer_id, md.customer_first_name, md.customer_last_name, md.customer_email, md.customer_age, 
    md.customer_pet_type, md.customer_pet_name, md.customer_pet_breed, loc.location_id
FROM mock_data md
LEFT JOIN dim_locations loc ON md.customer_postal_code = loc.postal_code AND md.customer_country = loc.country;


INSERT INTO fact_sales (
    sale_date,
    quantity,
    total_price,
    customer_id,
    product_id,
    store_id,
    seller_id
)
SELECT
    TO_DATE(md.sale_date, 'MM/DD/YYYY'),
    md.sale_quantity,
    md.sale_total_price,
    dc.customer_id,
    md.sale_product_id,
    s.real_store_id,
    ds.seller_id
FROM mock_data md

JOIN dim_customers dc
ON md.sale_customer_id = dc.customer_id

JOIN dim_sellers ds
ON md.sale_seller_id = ds.seller_id

JOIN (
    SELECT name, MIN(store_id) as real_store_id
    FROM dim_stores
    GROUP BY name
) s
ON md.store_name = s.name;
