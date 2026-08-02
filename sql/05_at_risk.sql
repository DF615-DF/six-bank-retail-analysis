-- 05 流失预警名单
-- 业务问题：哪些客户资产不低、但活跃度和交易明显下降？
-- 做法：用"低活跃 + 低交易 + 有资产"三个条件组合，先筛出可能流失的名单。

SELECT
  customer_id,
  city,
  aum,
  product_count,
  monthly_txn_count,
  active_days
FROM customers
WHERE active_days <= 5
  AND monthly_txn_count <= 2
  AND aum BETWEEN 20000 AND 800000
ORDER BY aum DESC
LIMIT 20;
