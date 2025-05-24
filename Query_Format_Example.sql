#standardSQL
with 
raw_data as(    --lấy data từ tất cả các source
SELECT
  format_timestamp("%Y%V",install_time) as week,
  format_timestamp("%Y%m",install_time) as month,
  Case
    when media_source like '%Facebook Ads%' then 'Facebook'
    when media_source like '%googleadwords_int%' then 'Google'
    when media_source like '%rtbhouse_int%' then 'Retargeting RTBHouse'
    when media_source like '%criteonew_int%' then 'Retargeting Criteo'
    when media_source like '%organic%' then 'Organic'
    when media_source like '%Web - Xu Trigger%' then 'Web - Xu Trigger'
    else 'Others'
  end as media_source,
  platform,
  Count(*) as num_install
FROM `tiki-dwh.appsflyer.installs_*`
where 1=1
and (_table_suffix < format_date("%Y%m%d", current_date('+7'))
      and _table_suffix >= format_date("%Y%m%d", DATE_SUB(date_trunc(current_date('+7'), MONTH), interval 3 MONTH)))
OR (_table_suffix < format_date("%Y%m%d", DATE_SUB(current_date('+7'), interval 1 YEAR))
      and _table_suffix >= format_date("%Y%m%d", DATE_SUB(date_trunc(current_date('+7'), MONTH), interval 15 MONTH)))
group by 1,2,3,4
),

week_data as (
  select
    Case
      when week = format_date("%Y%V", current_date('+7')) then 'WTD'
      when week = format_date("%Y%V", date_sub(current_date('+7'), interval 1 week)) then 'W-1'
      when week = format_date("%Y%V", date_sub(current_date('+7'), interval 2 week)) then 'W-2'
      when week = format_date("%Y%V", date_sub(current_date('+7'), interval 3 week)) then 'W-3'
      when week = format_date("%Y%V", date_sub(current_date('+7'), interval 4 week)) then 'W-4'
      when week = format_date("%Y%V", date_sub(current_date('+7'), interval 5 week)) then 'W-5'
    end as time,
    week,
    media_source,
    platform,
    sum(num_install) as num_install
  from raw_data
  where week >= format_date("%Y%V", date_sub(current_date('+7'), interval 5 week))
  group by 1,2,3,4
),

month_data as (
  select
    Case
      when month = format_date("%Y%m", current_date('+7')) then 'MTD'
      when month = format_date("%Y%m", date_sub(current_date('+7'), interval 1 month)) then 'M-1'
      when month = format_date("%Y%m", date_sub(current_date('+7'), interval 2 month)) then 'M-2'
      when month = format_date("%Y%m", date_sub(current_date('+7'), interval 3 month)) then 'M-3'
    end as time,
    month,
    media_source,
    platform,
    sum(num_install) as num_install
  from raw_data
  where month >= format_date("%Y%m", date_sub(current_date('+7'), interval 3 month))
  group by 1,2,3,4
),

week_data_ly as (
  select
    Case
      when week = format_date("%Y%V", date_sub(current_date('+7'), interval 1 year)) then 'WTD LY'
      when week = format_date("%Y%V", date_sub(date_sub(current_date('+7'), interval 1 year), interval 1 week)) then 'W-1 LY'
      when week = format_date("%Y%V", date_sub(date_sub(current_date('+7'), interval 1 year), interval 2 week)) then 'W-2 LY'
      when week = format_date("%Y%V", date_sub(date_sub(current_date('+7'), interval 1 year), interval 3 week)) then 'W-3 LY'
      when week = format_date("%Y%V", date_sub(date_sub(current_date('+7'), interval 1 year), interval 4 week)) then 'W-4 LY'
      when week = format_date("%Y%V", date_sub(date_sub(current_date('+7'), interval 1 year), interval 5 week)) then 'W-5 LY'
    end as time,
    week,
    media_source,
    platform,
    sum(num_install) as num_install
  from raw_data
  where week >= format_date("%Y%V", date_sub(date_sub(current_date('+7'), interval 1 year), interval 5 week))
  and week <= format_date("%Y%V", date_sub(current_date('+7'), interval 1 year))
  group by 1,2,3,4
),

month_data_ly as (
  select
    Case
      when month = format_date("%Y%m", date_sub(current_date('+7'), interval 1 year)) then 'MTD LY'
      when month = format_date("%Y%m", date_sub(date_sub(current_date('+7'), interval 1 year), interval 1 month)) then 'M-1 LY'
      when month = format_date("%Y%m", date_sub(date_sub(current_date('+7'), interval 1 year), interval 2 month)) then 'M-2 LY'
      when month = format_date("%Y%m", date_sub(date_sub(current_date('+7'), interval 1 year), interval 3 month)) then 'M-3 LY'
    end as time,
    month,
    media_source,
    platform,
    sum(num_install) as num_install
  from raw_data
  where week >= format_date("%Y%m", date_sub(date_sub(current_date('+7'), interval 1 year), interval 3 month))
  and week <= format_date("%Y%m", date_sub(current_date('+7'), interval 1 year))
  group by 1,2,3,4
)


select * from week_data
union all
select * from month_data
UNION aLL
select * from week_data_ly
UNION aLL
select * from month_data_ly

-- CTE
-- Bước 1: Xử lý dataraw
-- Bước: Xử lý dữ liệu theo từng timeframe
-- Bước 3: Combine các kết quả của từng timeframe

