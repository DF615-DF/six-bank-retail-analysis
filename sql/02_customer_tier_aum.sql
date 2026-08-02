-- 02 客户分档与 AUM 贡献
  -- 业务问题：客户经理先要知道"资源集中在哪里"。
  -- 做法：用 CASE WHEN 把 AUM 切成 4 档（80万/20万/2万），再用 GROUP BY 汇总。

SELECT
  CASE
    WHEN aum >= 800000 THEN '高价值'
    WHEN aum >= 200000 THEN '成长'
    WHEN aum >= 20000  THEN '基础'
    ELSE '低价值'
  END AS customer_tier,
  COUNT(*) AS customer_cnt,
  ROUND(SUM(aum) / 100000000, 2) AS aum_yi,
  ROUND(AVG(aum), 0) AS avg_aum
FROM customers
GROUP BY customer_tier
ORDER BY aum_yi DESC;
