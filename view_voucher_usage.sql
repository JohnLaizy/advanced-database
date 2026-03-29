CREATE OR REPLACE VIEW vw_voucher_usage AS
-- [TACTICAL] Shows how each voucher is performing in terms of redemptions
-- and total discount cost to the business.
-- LEFT JOIN ensures vouchers with zero usage still appear.
-- NULLIF guards against division by zero on avg calculation.
SELECT
    v.voucher_code,
    v.voucher_type,
    v.status                                            AS voucher_status,
    COUNT(vr.redemption_id)                             AS total_used,
    NVL(SUM(vr.discount_applied), 0)                   AS total_discount_given,
    ROUND(SUM(vr.discount_applied)
          / NULLIF(COUNT(vr.redemption_id), 0), 2)     AS avg_discount_per_use
FROM voucher v
LEFT JOIN voucher_redemption vr
    ON v.voucher_id = vr.voucher_id
GROUP BY v.voucher_code, v.voucher_type, v.status;

SELECT
    voucher_code,
    voucher_type,
    voucher_status,
    total_used,
    total_discount_given,
    avg_discount_per_use
FROM vw_voucher_usage
ORDER BY total_used DESC;