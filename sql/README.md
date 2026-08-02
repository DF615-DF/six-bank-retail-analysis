# SQL 模拟案例说明

## 这个文件夹是什么

这不是真实银行客户数据，而是一张用 SQL 生成的 50,000 行模拟客户表，用来演示客户经理岗位常见的分析逻辑：

1. 客户分档：高价值、成长、基础、低价值，各自贡献多少 AUM
2. 交叉销售：成长客户（20万-80万）中产品少的客户，是产品渗透的优先名单
3. 渠道质量：柜台、手机银行、代发工资、线上活动带来的户均价值
4. 流失预警：低活跃、低交易、有资产的客户需要先被触达

## 如何运行

本机已安装 SQLite。在项目根目录（`E:\AI\工作\六大行客户经营分析项目`）执行：

```bash
sqlite3 output/customers.db < sql/01_create_customers.sql
sqlite3 -header -column output/customers.db < sql/02_customer_tier_aum.sql
sqlite3 -header -column output/customers.db < sql/03_cross_sell.sql
sqlite3 -header -column output/customers.db < sql/04_channel_quality.sql
sqlite3 -header -column output/customers.db < sql/05_at_risk.sql
```

输出文件已经保存在 `output/` 下，可以直接看结果。`01_create_customers.sql` 使用确定性伪随机数生成模拟客户，只要不修改脚本，每次重建结果一致，方便面试复盘。

## 面试时怎么讲

- 不要背 SQL 语法，讲清楚“我为什么问这个问题”。
- 先用年报数据说明行业背景，再用 SQL 说明客户经理怎么把“分层、渗透、渠道、流失”变成动作。
- 真实银行环境需要脱敏、权限、合规审批，模拟数据只是练习方法。
