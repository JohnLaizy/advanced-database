CREATE INDEX idx_orders_member    ON orders(member_id);
-- Used by: get_member_orders cursor, member_order_report nested cursor,
--          vw_restaurant_revenue JOIN, create_order INSERT

CREATE INDEX idx_voucher_status   ON voucher(status);
-- Used by: apply_voucher status check, trg_voucher_expiry trigger,
--          vw_voucher_usage filter