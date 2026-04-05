CREATE INDEX idx_rest_category_upper ON restaurants(UPPER(category));
CREATE INDEX idx_orders_revenue_calc ON orders(restaurant_id, amount, order_status);