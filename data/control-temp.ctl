LOAD DATA
INFILE '/opt/oracle/data/soporte.csv'
INTO TABLE temp_support_raw
APPEND
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  unique_id,
  channel_name,
  category,
  sub_category,
  customer_remarks,
  order_id,
  order_date_time,
  issue_reported_at,
  issue_responded,
  survey_response_date,
  customer_city,
  product_category,
  item_price,
  connected_handling_time,
  agent_name,
  supervisor,
  manager,
  tenure_bucket,
  agent_shift,
  csat_score,
  row_number
)
