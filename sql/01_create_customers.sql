-- 六大行客户经营分析项目
-- 01 创建模拟客户表
-- 目的：生成 50,000 行"非真实、可复现"的客户数据，用来演示银行客户经理的日常分析逻辑。
-- 说明：本文件故意用 SQL 生成模拟数据，方便你在面试时讲清楚"数据从哪来、为什么这样分层"。

-- 删除旧表，保证每次重建结果一致。
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  customer_id       TEXT PRIMARY KEY,
  city              TEXT NOT NULL,
  open_channel      TEXT NOT NULL,
  aum               REAL NOT NULL,          -- 本行金融资产规模（元）
  product_count     INTEGER NOT NULL,       -- 持有产品数
  monthly_txn_count INTEGER NOT NULL,       -- 月均交易笔数
  active_days       INTEGER NOT NULL        -- 近 90 天活跃天数
);

-- 先生成 50,000 个客户号，以及每个客户独立的随机种子。
-- 每一行只用一次 random()，保证同一行的城市、渠道、AUM 不会互相干扰。
WITH RECURSIVE seq(seq_index) AS (
  SELECT 1
  UNION ALL
  SELECT seq_index + 1 FROM seq WHERE seq_index < 50000
),
seeded AS (
  SELECT
    seq_index,
    printf('C%06d', seq_index) AS customer_id,
    -- 用 seq_index 生成一个确定性的伪随机种子，保证每次重建结果完全一致。
    -- 面试时只需要说：这是我设计的模拟数据生成规则，可以复现。
    ((seq_index * 2654435761) % 2147483647) AS seed1,
    ((seq_index * 40503 + 12345) % 2147483647) AS seed2,
    ((seq_index * 7919 + 17) % 2147483647) AS seed3
  FROM seq
),
random_customers AS (
  SELECT
    seq_index,
    customer_id,
    -- seed1 决定城市与客户价值档位，seed2 决定渠道，seed3 决定活跃度。
    (seed1 % 100) AS city_rnd,
    (seed2 % 100) AS channel_rnd,
    (seed1 % 100) AS tier_rnd,
    seed3 AS aum_rnd,
    (seed1 % 6) AS product_rnd,
    (seed2 % 30) AS txn_rnd,
    (seed3 % 90) AS active_rnd
  FROM seeded
)
INSERT INTO customers
SELECT
  customer_id,

  -- 城市分布：杭州/深圳/西安/成都/北京各 12%，其他 40%。
  CASE
    WHEN city_rnd < 12 THEN '杭州'
    WHEN city_rnd < 24 THEN '深圳'
    WHEN city_rnd < 36 THEN '西安'
    WHEN city_rnd < 48 THEN '成都'
    WHEN city_rnd < 60 THEN '北京'
    ELSE '其他'
  END AS city,

  -- 开户渠道：柜台 35%、代发工资 25%、线上活动 20%、手机银行 20%。
  -- 渠道与客户价值关联后，代发工资更容易沉淀中高价值客户，手机银行更多是自助客群。
  CASE
    WHEN tier_rnd < 2 THEN
      CASE
        WHEN channel_rnd < 25 THEN '柜台'
        WHEN channel_rnd < 70 THEN '代发工资'
        WHEN channel_rnd < 90 THEN '线上活动'
        ELSE '手机银行'
      END
    WHEN tier_rnd < 20 THEN
      CASE
        WHEN channel_rnd < 35 THEN '柜台'
        WHEN channel_rnd < 65 THEN '代发工资'
        WHEN channel_rnd < 85 THEN '线上活动'
        ELSE '手机银行'
      END
    WHEN tier_rnd < 55 THEN
      CASE
        WHEN channel_rnd < 40 THEN '柜台'
        WHEN channel_rnd < 65 THEN '代发工资'
        WHEN channel_rnd < 85 THEN '线上活动'
        ELSE '手机银行'
      END
    ELSE
      CASE
        WHEN channel_rnd < 30 THEN '柜台'
        WHEN channel_rnd < 45 THEN '代发工资'
        WHEN channel_rnd < 65 THEN '线上活动'
        ELSE '手机银行'
      END
  END AS open_channel,

  -- AUM 分档：2% 高价值、18% 成长、35% 基础、45% 低价值。
  CASE
    WHEN tier_rnd < 2  THEN CAST(800000 + (aum_rnd % 7000000) AS REAL)  -- 高价值：80万~780万
    WHEN tier_rnd < 20 THEN CAST(200000 + (aum_rnd % 600000) AS REAL)   -- 成长：20万~80万
    WHEN tier_rnd < 55 THEN CAST(20000  + (aum_rnd % 180000) AS REAL)   -- 基础：2万~20万
    ELSE CAST(1000 + (aum_rnd % 19000) AS REAL)                         -- 低价值：1000~2万
  END AS aum,

  -- 产品持有数：越有价值、越活跃的客户通常产品越多。
  CASE
    WHEN tier_rnd < 2  THEN 3 + product_rnd
    WHEN tier_rnd < 20 THEN 2 + product_rnd % 3
    WHEN tier_rnd < 55 THEN 1 + product_rnd % 3
    ELSE 1 + product_rnd % 2
  END AS product_count,

  -- 月均交易笔数：基础客群以低频为主，少量高活跃客户。
  CASE
    WHEN tier_rnd < 2  THEN 8 + txn_rnd
    WHEN tier_rnd < 20 THEN 4 + txn_rnd % 12
    WHEN tier_rnd < 55 THEN 1 + txn_rnd % 8
    ELSE 1 + txn_rnd % 3
  END AS monthly_txn_count,

  -- 近 90 天活跃天数：约 3% 客户低活跃、约 7% 客户活跃度明显下降，用于流失预警演示。
  CASE
    WHEN (active_rnd % 100) < 3 THEN active_rnd % 6
    WHEN (active_rnd % 100) < 10 THEN 5 + active_rnd % 15
    ELSE 15 + active_rnd % 75
  END AS active_days

FROM random_customers;

-- 建表后快速看数量与分档比例，确认 50,000 行、约 3%/20%/35%/42% 已成立。
SELECT '客户总行数' AS check_item, COUNT(*) AS value FROM customers;
SELECT
  CASE
    WHEN aum >= 500000 THEN '高价值'
    WHEN aum >= 100000 THEN '成长'
    WHEN aum >= 10000  THEN '基础'
    ELSE '低价值'
  END AS tier,
  COUNT(*) AS cnt,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) AS pct
FROM customers
GROUP BY tier
ORDER BY cnt DESC;
