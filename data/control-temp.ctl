LOAD DATA
INFILE '/opt/oracle/data/Customer_support_data.csv'
INTO TABLE temp_support_raw
APPEND
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  unique_id              CHAR(100),
  channel_name           CHAR(100),
  category               CHAR(100),
  sub_category           CHAR(100),
  customer_remarks       CHAR(10000),
  order_id               CHAR(100),
  order_date_time        CHAR(100),
  issue_reported_at      CHAR(100),
  issue_responded        CHAR(100),
  survey_response_date   CHAR(100),
  customer_city          CHAR(100),
  product_category       CHAR(100),
  item_price             CHAR(50),
  connected_handling_time CHAR(50),
  agent_name             CHAR(100),
  supervisor             CHAR(100),
  manager                CHAR(100),
  tenure_bucket          CHAR(100),
  agent_shift            CHAR(100),

  csat_score             CHAR(30),

  row_number
)
