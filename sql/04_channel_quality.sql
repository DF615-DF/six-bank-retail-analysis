-- 04 渠道质量分析
-- 业务问题：不同开户渠道带来的客户，户均价值差别大吗？
-- 做法：GROUP BY 开户渠道，看客户数、户均 AUM 和总 AUM。

SELECT
  open_channel,
  COUNT(*) AS customer_cnt,
  ROUND(AVG(aum), 0) AS avg_aum,
  ROUND(SUM(aum) / 100000000, 2) AS aum_yi
FROM customers
GROUP BY open_channel
ORDER BY avg_aum DESC;
