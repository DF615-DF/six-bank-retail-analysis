-- 03 交叉销售机会
  -- 业务问题：成长客户"已有一定资产、但产品覆盖还浅"，是下一轮交叉销售的主要名单。
  -- 做法：筛选 AUM 20万~80万、产品持有数 <= 2 的客户。

SELECT
  COUNT(*) AS cross_sell_candidates,
  ROUND(AVG(aum), 0) AS avg_aum,
  ROUND(SUM(aum) / 100000000, 2) AS aum_yi
FROM customers
WHERE aum BETWEEN 200000 AND 800000
  AND product_count <= 2;
