--Error Testing
INSERT INTO orders (order_id, member_id, restaurant_id, amount, order_status, order_type) 
VALUES (1000, 1, 1, -10, 'Pending', 'Delivery');

--Correct Testing
INSERT INTO orders (order_id, member_id, restaurant_id, amount, order_status, order_type) 
VALUES (1001, 1, 1, 60, 'Pending', 'Dine-In');