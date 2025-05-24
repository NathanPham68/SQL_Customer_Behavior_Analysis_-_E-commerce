/* 
Query 01: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
Hint: use schema to know the required column. 
*/
select
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) month
  ,sum(totals.visits) visits
  ,sum(totals.pageviews) pageviews
  ,sum(totals.transactions) transactions

FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
where _table_suffix between '0101' and '0331'
group by month
order by month
;




/* 
Query 02: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
Hint: Bounce session is the session that user does not raise any click after landing on the website. 
*/

select
  trafficSource.source source
  ,sum(totals.visits) visits
  ,sum(totals.bounces) bounces
  ,round(safe_divide(sum(totals.bounces), sum(totals.visits)) * 100.0, 3) bounce_rate

FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
group by source
order by visits desc
;




/* 
Query 3: Revenue by traffic source by week, by month in June 2017
Hint 1: separate month and week data then union all.
Hint 2: at time_type, you can [SELECT 'Month' as time_type] to print time_type column
Hint 3: use "productRevenue" to calculate revenue. You need to unnest hits and product to access productRevenue field 
(example at the end of page).
Hint 4: To shorten the result, productRevenue should be divided by 1000000
Hint 5: Add condition "product.productRevenue is not null" to calculate correctly
*/
with weekly_revenue as (
  select
    'week' as time_type
    ,FORMAT_DATE('%Y%W', PARSE_DATE('%Y%m%d', date)) time
    ,trafficSource.source source
    ,sum(product.productRevenue) / 1000000 AS revenue

  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
  ,UNNEST (hits) hits
  ,UNNEST (hits.product) product
  where 1=1
    and _table_suffix between '01' and '31'
    and product.productRevenue is not null
  group by time, source
),

monthly_revenue as (
  select
      'month' as time_type
      ,FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) time
      ,trafficSource.source source
      ,sum(product.productRevenue) / 1000000 AS revenue

    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
    ,UNNEST (hits) hits
    ,UNNEST (hits.product) product
    where 1=1
      and _table_suffix between '01' and '31'
      and product.productRevenue is not null
    group by time, source
)

select * from weekly_revenue
union all
select * from monthly_revenue
order by revenue desc
;




/* 
Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.	
"Note: 
+ fullVisitorId field is user id.
+ We have to  , UNNEST(hits) AS hits
  , UNNEST(hits.product) to access productRevenue"

Hint 1: purchaser: totals.transactions >=1; productRevenue is not null.	
Hint 2: non-purchaser: totals.transactions IS NULL;  product.productRevenue is null 	
Hint 3: Avg pageview = total pageview / number unique user.	
*/
with purchaser as(
  select 
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) month
    , sum(totals.pageviews) / count(distinct fullVisitorId) as avg_pageviews_purchase

  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,unnest(hits) hits
  ,unnest(hits.product) product
  where 1=1
    and _table_suffix between '0601' and '0731'
    and totals.transactions >=1 
    and product.productRevenue is not null
  group by month
)

, non_purchaser as(
  select 
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) month
    ,sum(totals.pageviews) / count(distinct fullVisitorId) as avg_pageviews_non_purchase

  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,unnest(hits) hits
  ,unnest(hits.product) product
  where 1=1
    and _table_suffix between '0601' and '0731'
    and totals.transactions is null 
    and product.productRevenue is null
  group by month
)

select 
  p.month
  ,p.avg_pageviews_purchase
  ,np.avg_pageviews_non_purchase
from purchaser p
left join non_purchaser np using(month)
order by p.month;




/* 
Query 05: Average number of transactions per user that made a purchase in July 2017
Hint 1: purchaser: totals.transactions >=1; productRevenue is not null. fullVisitorId field is user id.
Hint 2: Add condition "product.productRevenue is not null" to calculate correctly	
*/
select
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) month  
  ,round(safe_divide(sum(totals.transactions), count(distinct fullVisitorId)), 9) as Avg_total_transactions_per_user  
 
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
,unnest(hits) hits
,unnest(hits.product) product
where 1=1
  and _table_suffix between '0701' AND '0731'  
  and totals.transactions >= 1  -- Chỉ tính người có giao dịch
  and product.productRevenue IS NOT NULL  -- Chỉ tính giao dịch có doanh thu
group by month
;




/* 
Query 06: Average amount of money spent per session. Only include purchaser data in July 2017	
Hint 1: Where clause must be include "totals.transactions IS NOT NULL" and "product.productRevenue is not null"	
Hint 2: avg_spend_per_session = total revenue/ total visit	
Hint 3: To shorten the result, productRevenue should be divided by 1000000	
***Notice: per visit is different to per visitor		
*/
select 
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) month
  ,round(safe_divide(sum(product.productRevenue) / 1000000, sum(totals.visits)), 2) as avg_revenue_by_user_per_visit
  -- , sum(totals.visits) as visits
  -- , count(totals.visits) AS visits

from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
,unnest(hits) hits
,unnest(hits.product) product
where 1=1
  and _TABLE_SUFFIX BETWEEN '0701' AND '0731'  
  and totals.transactions IS NOT NULL  -- Chỉ tính những phiên có giao dịch
  and product.productRevenue IS NOT NULL  -- Chỉ tính giao dịch có doanh thu
group by month
;






/* 
Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. 
Output should show product name and the quantity was ordered.

"Hint1: We have to   
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product to get v2ProductName."	
Hint2: Add condition "product.productRevenue is not null" to calculate correctly	
Hint3: Using productQuantity to calculate quantity.			
*/
with target_customers as (
  select distinct fullVisitorId
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,unnest(hits) hits
  ,unnest(hits.product) product
  where 1=1
    and _table_suffix BETWEEN '0701' AND '0731'
    and product.v2ProductName = "YouTube Men's Vintage Henley" -- Lấy danh sách khách hàng đã mua sản phẩm "YouTube Men's Vintage Henley"
    and product.productRevenue IS NOT NULL  -- Chỉ tính giao dịch có doanh thu
), 

other_purchases as (
  -- Tìm các sản phẩm khác được mua bởi những khách hàng trên
  select 
    product.v2ProductName as other_purchased_products
    ,sum(product.productQuantity) quantity
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,unnest(hits) hits
  ,unnest(hits.product) product
  where 1=1
    and _table_suffix BETWEEN '0701' AND '0731'
    and product.v2ProductName != "YouTube Men's Vintage Henley"  -- Loại trừ sản phẩm mục tiêu
    and product.productRevenue IS NOT NULL  -- Chỉ tính giao dịch có doanh thu 
    and fullVisitorId IN (select fullVisitorId from target_customers)
  group by other_purchased_products
)

select 
  other_purchased_products
  ,quantity
from other_purchases
order by quantity desc;




/* 
Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. 
For example, 100% product view then 40% add_to_cart and 10% purchase.
Add_to_cart_rate = number product  add to cart/number product view. 
Purchase_rate = number product purchase/number product view. The output should be calculated in product level.

Hint 1: hits.eCommerceAction.action_type = '2' is view product page; 
hits.eCommerceAction.action_type = '3' is add to cart; 
hits.eCommerceAction.action_type = '6' is purchase	
Hint 2: Add condition "product.productRevenue is not null"  for purchase to calculate correctly	
Hint 3: To access action_type, you only need unnest hits.			
*/
-- Cach 1: chatGPT
-- with product_actions as(
--   select 
--     FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) month
--     ,product.v2ProductName AS product_name
--     ,countif(hits.eCommerceAction.action_type = '2') as num_product_view
--     ,countif(hits.eCommerceAction.action_type = '3') as num_addtocart
--     ,countif(hits.eCommerceAction.action_type = '6' and product.productRevenue IS NOT NULL) as num_purchase
--   FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
--   ,unnest(hits) hits
--   ,unnest(hits.product) product
--   where _table_suffix BETWEEN '0101' AND '0331'
--   group by month, product_name
-- )

-- select 
--   month
--   ,sum(num_product_view) as num_product_view
--   ,sum(num_addtocart) as num_addtocart
--   ,sum(num_purchase) as num_purchase
--   ,round(safe_divide(sum(num_addtocart), sum(num_product_view)) * 100.0, 2) as add_to_cart_rate
--   ,round(safe_divide(sum(num_purchase), sum(num_product_view)) * 100.0, 2) as purchase_rate
-- from product_actions
-- group by month
-- order by month
-- ;



-- Cach 2: Coach Tan
with product_view as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month
    ,count(product.productSKU) as num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  ,UNNEST(hits) as hits
  ,UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '2'
  group by 1
),

add_to_cart as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month
    ,count(product.productSKU) as num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  ,UNNEST(hits) as hits
  ,UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '3'
  group by 1
),

purchase as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month
    ,count(product.productSKU) as num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  ,UNNEST(hits) as hits
  ,UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '6'
  and product.productRevenue is not null   --phải thêm điều kiện này để đảm bảo có revenue
  group by 1
)

select
    pv.*
    ,num_addtocart
    ,num_purchase
    ,round(num_addtocart*100/num_product_view,2) as add_to_cart_rate
    ,round(num_purchase*100/num_product_view,2) as purchase_rate
from product_view pv
left join add_to_cart a on pv.month = a.month
left join purchase p on pv.month = p.month
order by pv.month;

/* 
bài này k nên inner join, vì nếu như bảng purchase k có data thì sẽ k mapping đc vs bảng productview, 
từ đó kết quả sẽ k có luôn, mình nên dùng left join
lấy số product_view làm gốc, nên mình sẽ left join ra 2 bảng còn lại
*/
