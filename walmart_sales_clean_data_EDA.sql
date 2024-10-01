
create table if not exists Walmartsales(
invoice_id varchar(30) not null primary key,
branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10, 2) not null,
quantity int not null,
VAT float(6, 4) not null,
total decimal(12, 4) not null,
date DATETIME not null,
time TIME not NULL,
payment_method varchar(15) not null,
cogs decimal (10, 2) not null,
gross_margin_pct float(11, 9),
gross_income decimal(12, 4) not null,
rating float(2, 1)
); 

-- ---------------------------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------FEATURE ENGINEERING----------------------------------------------------------------------

-- CREATE time_of_day column

select time,
case
	when `time` between '00:00:00' and '12:00:00' then 'Morning'
    when `time` between '12:01:00' and '16:00:00' then 'Afternoon'
    else 'Evening'
end as time_of_day
from walmartsales;

alter table walmartsales add column time_of_day varchar(20);

select *
from walmartsales;

update walmartsales
set time_of_day = (case
	when `time` between '00:00:00' and '12:00:00' then 'Morning'
    when `time` between '12:01:00' and '16:00:00' then 'Afternoon'
    else 'Evening'
end
);

-- CREATE day_name column

select dayname(date)
from walmartsales;

alter table walmartsales add column day_name varchar(20);
select *
from walmartsales;

update walmartsales
set day_name = dayname(date);


-- CREATE month_name column
select monthname(date)
from walmartsales;

alter table walmartsales add column month_name varchar(20);

update walmartsales
set month_name = monthname(date);

select *
from walmartsales;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------GENERIC DATA ANALYSIS-------------------------------------------------------------------------------------

-- How many distinct city does the dataset contain?
select distinct(city)
from walmartsales;

select distinct(branch)
from walmartsales;

-- In which city is each branch?
select distinct city,branch
from walmartsales;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------- ------------------PRODUCT ------------------------------------------------------------------------

-- How many unique product lines does the data have?

select count(distinct(product_line))
from walmartsales;

-- What is the most common payment method?

select payment_method, count(payment_method)
from walmartsales
group by payment_method
order by count(payment_method) desc;

-- what is the most selling product line?

select product_line, count(product_line) 
from walmartsales
group by product_line
order by count(product_line) desc;

-- what is the total revenue by month?

select month_name as month, 
sum(total) as total_revenue
from walmartsales
group by month;

-- What month had the highest COGS?
select month_name, sum(cogs)
from walmartsales
group by month_name
order by sum(cogs) desc;

-- what product line had the highest revenue?
select product_line, sum(total) as revenue
from walmartsales
group by product_line
order by revenue desc;

-- What is the city with the highest revenue?
select city, sum(total) as revenue
from walmartsales
group by city
order by revenue;

-- What product line had the highest VAT?
select product_line, sum(VAT) 
from walmartsales
group by product_line
order by sum(VAT) desc;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if it is greater than average sales
select product_line, sum(quantity)
from walmartsales
group by product_line
order by sum(quantity);

create temporary table walmartsalestemp1
(select product_line, sum(quantity)
from walmartsales
group by product_line
order by sum(quantity));

select *
from walmartsalestemp1;

select avg(`sum(quantity)`)
from walmartsalestemp1;


select product_line,`sum(quantity)` as total_quantity,
case
	when `sum(quantity)` > '912.0000'
 then 'Good'
    else 'Bad'
end as sales_performance
from walmartsalestemp1
group by product_line, `sum(quantity)`
order by `sum(quantity)` desc;

-- Which branch sold more products than average product sold
select branch, sum(quantity) as qty
from walmartsales
group by branch
having sum(quantity)>(select avg(quantity) from walmartsales);

-- What is the most common product line by gender?

select product_line, gender, count(gender)
from walmartsales
group by product_line,gender
order by count(gender)desc;

-- What is the average rating for each product line?
select product_line, avg(rating)
from walmartsales
group by product_line
order by avg(rating) desc;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------CUSTOMER RELATED QUESTION------------------------------------------------------------------------

-- How many unique customer types does the data have?
select distinct(customer_type)
from walmartsales;

-- How many unique payment methods does the data have?
select distinct(payment_method)
from walmartsales;

-- What is the most common customer type?
select customer_type, count(customer_type)
from walmartsales
group by customer_type
order by count(customer_type) desc;

-- which customer_type buys the most?
select customer_type, sum(quantity) as total_qty_purchased
from walmartsales
group by customer_type
order by sum(quantity) desc;

-- What is the gender of most of the customers?
select gender, count(gender) as gender_count
from walmartsales
group by gender
order by count(gender) desc;

-- What is the gender distribution per branch?
select branch, gender, count(gender)
from walmartsales
group by branch, gender
order by branch;

-- What time of the day do customer give most ratings?

select time_of_day, avg(rating)
from walmartsales
group by time_of_day
order by avg(rating) desc;

-- What time of the day do customer give most ratings per branch?
select time_of_day,branch, avg(rating)
from walmartsales
group by time_of_day, branch
order by branch, avg(rating) desc;

-- What day of the week has the best average ratings?
select day_name, avg(rating)
from walmartsales
group by day_name
order by avg(rating) desc;

-- What day of the week has the best average ratings per branch?
select branch,day_name,  avg(rating) as max_avg_rating
from walmartsales
group by branch, day_name
order by branch, avg(rating) desc;

-- --------------------------------------------------------------ALL DONE!!!---------------------------------------------------------------------------
-- ---------------------------------------------PROFIT AND REVENUE CALCULATIONS----------------------------------------------------------------------------------

select unit_price * quantity as cogs
from walmartsales;

select cogs
from walmartsales;