# Data_analysis_with_MySQL_and_Power_BI_for_retail_store_sales_data
This project aims to demonstrate the use of MySQL for creating a database and querying the database before visualization with Power BI

### INTRODUCTION
The dataset is a WALMART sales dataset and we will be using mysql to query this dataset to answer important business questions and then power bi to visualize the results.
here's a quick snapshot of the dataset below in Excel
![image](https://github.com/user-attachments/assets/36a3fadc-2d4f-40d5-afb1-80faf6a3e09b)
*1001 rows and 17 columns*
Table name is 'Walmartsalesrawdata.csv'

### PROBLEM STATEMENT
The following information are to be extracted from the dataset using mysql;
1. How many distinct city does the dataset contain?
2. In which city is each branch?
   #### PRODUCT RELATED QUESTIONS
3. How many unique product lines does the data have?
4. What is the most common payment method?
5. what is the most selling product line?
6. what is the total revenue by month?
7. What month had the highest COGS?
8. what product line had the highest revenue?
9. What is the city with the highest revenue?
10. What product line had the highest VAT?
11. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if it is greater than average sales
12. Which branch sold more products than average product sold
13. What is the most common product line by gender?
14. What is the average rating for each product line?
    #### CUSTOMER RELATED QUESTIONS
15. How many unique customer types does the data have?
16. How many unique payment methods does the data have?
17. What is the most common customer type?
18. which customer_type buys the most?
19. What is the gender of most of the customers?
20. What is the gender distribution per branch?
21. What time of the day do customer give most ratings?
22. What time of the day do customer give most ratings per branch?
23. What day of the week has the best average ratings?
24. What day of the week has the best average ratings per branch?

### SUMMARY OF WORK FLOW
1. Create a database for the project
2. Create a table with all the appropriate data types for dates, integers, decimals and so on- as well as the constraints (primary key, foreign key, not null, e.t.c)
3. Perform basic data cleaning- checking for nulls, duplicates, e.t.c (the constraints in step 2 should help us avoid nulls)
4. Perform "Feature Engineering" - adding some conditional columns and calculated fields to help us better analyse the dataset
5. Perform Data analysis and answer key questions
6. Design Dashboard to visualize findings
7. prepare and publish insights from the data set

### STEP 1: Create a database for the project
```MySQL
create database if not exists salesdatawalmart;
-- This will create a database with the name salesdatawalmart
```
### STEP 2: Create a table with all the appropriate data types for dates, integers, decimals and so on- as well as the constraints (primary key, foreign key, not null, e.t.c)
```MySQL
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
-- This creates the empty table named 'Walmartsales' with all the specified constraints-
the not null contraint helps to prevent null data from being populated in the specified column
```
Now to insert the rows from the raw data into our new table which has all the defined constraints
```MySQL
insert Walmartsales
select *
from Walmartsalesrawdata;
-- This will then insert all of the rows from the 'Walmartsalesrawdata' to our newly created empty table 'Walmartsales'
```
#### STEP 3: Perform basic data cleaning- checking for nulls, duplicates, e.t.c (the constraints in step 2 should help us avoid nulls)
we check to see if there are any duplicated invoice id
```MySQL
with cte as (
SELECT *, row_number() over(partition by invoice_id) as row_num
from walmartsales
)
select *
from cte
where row_num > 1;
```
![image](https://github.com/user-attachments/assets/41b4829a-b77d-420f-8440-01a8ecdbf9b6)
The blank result shows that there are no duplicated invoice id(primary key) in this dataset

#### STEP 4: Perform "Feature Engineering" - adding some conditional columns and calculated fields to help us better analyse the dataset

**CREATE *time_of_day* column**
```MySQL
select time,
case
	when `time` between '00:00:00' and '12:00:00' then 'Morning'
    	when `time` between '12:01:00' and '16:00:00' then 'Afternoon'
    else 'Evening'
end as time_of_day
from walmartsales; -- this query displays the different time of day

alter table walmartsales add column time_of_day varchar(20); -- creates the column for time_of_day but leaves it empty

update walmartsales
set time_of_day = (case
	when `time` between '00:00:00' and '12:00:00' then 'Morning'
    when `time` between '12:01:00' and '16:00:00' then 'Afternoon'
    else 'Evening'
end
);
This adds data to the time_of_day column
```
![image](https://github.com/user-attachments/assets/367bba4f-8196-4495-9a20-be25bb7cb5df)

**CREATE day_name column**
we follow a similar process like the time_of_day

```MySQL
select dayname(date)
from walmartsales;

alter table walmartsales add column day_name varchar(20);
select *
from walmartsales;

update walmartsales
set day_name = dayname(date);

select *
from walmartsales
```
![image](https://github.com/user-attachments/assets/15fc4095-997c-47a0-a8c1-e49d2a4a345f)

**CREATE month_name column**

```MySQL
select monthname(date)
from walmartsales;

alter table walmartsales add column month_name varchar(20);

update walmartsales
set month_name = monthname(date);

select *
from walmartsales;
```
![image](https://github.com/user-attachments/assets/958dba93-ceec-4ac1-b9f2-1299c6dd8334)

#### STEP 5: Perform Data analysis and answer key questions
1. How many distinct city does the dataset contain?
   ```MySQL
   select distinct(city)
   from walmartsales;
   ```
   ![image](https://github.com/user-attachments/assets/5025115a-5c84-412d-a993-bc4754ebe032)

2. In which city is each branch?
   ```MySQL
   select distinct city,branch
   from walmartsales;
   ```
   ![image](https://github.com/user-attachments/assets/5eff549a-9074-4e6f-9c03-e83b8031e013)

##### PRODUCT RELATED QUESTIONS

3. How many unique product lines does the data have?
   ```MySQL
   select count(distinct(product_line))
   from walmartsales;
   ```
   ![image](https://github.com/user-attachments/assets/ab01598e-118a-4c55-9f81-1df567a8a30f)

4. What is the most common payment method?
   ```MySQL
   select payment_method, count(payment_method)
   from walmartsales
   group by payment_method
   order by count(payment_method) desc;
   ```
  ![image](https://github.com/user-attachments/assets/5bf116de-29e0-4f2e-9c16-bef652cbfb2b)

5. What is the most selling product line?
   ```MySQL
   select product_line, count(product_line) 
   from walmartsales
   group by product_line
   order by count(product_line) desc;
   ```
  ![image](https://github.com/user-attachments/assets/812e328d-c56b-4779-9e69-7fae4ea827db)
  *Fashion Accessories seems to be the best selling product line*

6. What is the total revenue by month?
   ```MySQL
   select month_name as month, 
   sum(total) as total_revenue
   from walmartsales
   group by month;
   ```
  ![image](https://github.com/user-attachments/assets/9ad3c50f-706f-491c-ae3d-f8fc5d2d77af)
  
  *January and February are the best and worst performing months respectively, in terms of total revenue generated*

7. What month had the highest COGS?
   ```MySQL
   select month_name, sum(cogs)
   from walmartsales
   group by month_name
   order by sum(cogs) desc;
   ```
  ![image](https://github.com/user-attachments/assets/e37479be-6b63-4800-ae2e-ee0b047c7af6)
  
  *January and February are the best and worst performing months respectively, in terms of COGS*

8. what product line had the highest revenue?
   ```MySQL
   select product_line, sum(total) as revenue
   from walmartsales
   group by product_line
   order by revenue desc;
   ```
 ![image](https://github.com/user-attachments/assets/b5839194-c048-4a29-a2e7-c565126f1e77)
 
 *Food and beverages is the best performing product line, in terms of revenue generated*
 
 *Health and beauty is the least performing product line, in terms of revenue generated*

9. What is the city with the highest revenue?
   ```MySQL
   select city, sum(total) as revenue
   from walmartsales
   group by city
   order by revenue desc;
   ```
![image](https://github.com/user-attachments/assets/326c335d-3e6e-42fb-a0dc-7c73805684b4)

*Naypyitaw is the best performing city, in terms of revenue generated*

*Mandalay is the best performing city, in terms of revenue generated*

10.  What product line had the highest VAT?
   ```MySQL
   select product_line, sum(VAT) 
   from walmartsales
   group by product_line
   order by sum(VAT) desc;
   ```
![image](https://github.com/user-attachments/assets/8aa5ae5e-f3c6-4299-81e8-72dde04b33d1)

*Food and beverage is the product line with the highest VAT*

*Health and beauty is the product line with the lowest VAT*

11. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if it is greater than average sales
    
    ```MySQL
    create temporary table walmartsalestemp1
    (select product_line, sum(quantity)
    from walmartsales
    group by product_line
    order by sum(quantity));
    -- creates and displays a simple temporary table showing the distinct product lines and the total number of goods sold for each
    ```
    
    ```MySQL
    select avg(`sum(quantity)`)
    from walmartsalestemp1;
    -- displays the average value (912.000) of the total goods sold in the table above this one 
    ```
    ![image](https://github.com/user-attachments/assets/c801f4df-29ca-498a-abb1-f5a5b63aa8bf)

    ```MySQL
    select product_line,`sum(quantity)` as total_quantity,
    case
	when `sum(quantity)` > '912.0000'
   	then 'Good'
   	else 'Bad'
   	end as sales_performance
    from walmartsalestemp1
    group by product_line, `sum(quantity)`
    order by `sum(quantity)` desc;
    -- displays the result as required
    ```
    ![image](https://github.com/user-attachments/assets/00254bd6-539d-44a0-9d82-76fb0a9b8fcf)
    
12. Which branch sold more products than average product sold?
    
     ```MySQL
     create temporary table temp2 (
     select branch, sum(quantity) as total_product_sold
     from walmartsales
     group by branch);
     -- Creates a temporary table showing each branch with the total number of goods sold per branch
     ```
     
     ```MySQL
     select avg(total_product_sold)
     from temp2;
     -- displays the avg_product_sold value as '1824.0000'
     ```
     ![image](https://github.com/user-attachments/assets/0e790f20-ae61-4112-8c13-fd64ea480b12)

     ```MySQL
     select *
     from temp2
     where total_product_sold > '1824.0000';
     -- displays the result as required
     ```
     ![image](https://github.com/user-attachments/assets/28e13171-56e3-4b44-b8f6-750e06033c3d)


13. What is the most common product line by gender?
    
     ```MySQL
     select gender, product_line, count(product_line) as head_count
     from walmartsales
     group by  gender, product_line
     order by gender, head_count desc;
     -- Females preferred "Fashion accessories" and had 96 customers
     -- Males preferred "Health and beauty"alter and had 88 customers
     ```
     ![image](https://github.com/user-attachments/assets/9de9ef44-bb64-4ac6-9fa0-875873e32c6c)

14. What is the average rating for each product line?
    
    ```MySQL
    select product_line, avg(rating)
    from walmartsales
    group by product_line
    order by avg(rating) desc;
    ```
    ![image](https://github.com/user-attachments/assets/4487df2a-bbea-4e51-b979-3713089947b1)

15.  How many unique customer types does the data have?
    
     ```MySQL
     select distinct(customer_type)
     from walmartsales;
     ```
     ![image](https://github.com/user-attachments/assets/2b39f0eb-88f9-48da-82d4-0845377e918b)


16. How many unique payment methods does the data have and what are they?
    
    ```MySQL
    select distinct(payment_method)
    from walmartsales;
    ```
    ![image](https://github.com/user-attachments/assets/27d767a9-3936-4dd9-b6af-06c8f5692f1a)

17. What is the most common customer type?
    
    ```MySQL
    select distinct(payment_method)
    from walmartsales;
    ```
    ![image](https://github.com/user-attachments/assets/27d767a9-3936-4dd9-b6af-06c8f5692f1a)
    
    *There are 499 customers that are Member customer type*
    
    *There are 496 customers that are Normal customer type*
    
18. Which customer_type buys the most?
    
    ```MySQL
    select customer_type, sum(quantity) as total_qty_purchased
    from walmartsales
    group by customer_type
    order by sum(quantity) desc;
    ```
    ![image](https://github.com/user-attachments/assets/78393bf9-f72e-4077-9f04-b3a96610a582)
 
19. What is the gender of most of the customers?
    
    ```MySQL
    select gender, count(gender) as gender_count
    from walmartsales
    group by gender
    order by count(gender) desc;
    ```
    ![image](https://github.com/user-attachments/assets/e8c9550b-00f7-43ff-b687-59f182f27a22)

20. What is the gender distribution per branch?
    ```MySQL
    select branch, gender, count(gender)
    from walmartsales
    group by branch, gender
    order by branch;
    ```
   ![image](https://github.com/user-attachments/assets/769ab039-2019-47a8-a4ab-d60d7fbf7aac)

21. What time of the day do customer give most ratings?
    ```MySQL
    select time_of_day, avg(rating)
    from walmartsales
    group by time_of_day
    order by avg(rating) desc;
    ```
   ![image](https://github.com/user-attachments/assets/8619534f-b167-4304-ba85-fdabeb269c94)

22. What time of the day do customer give most ratings per branch?
    ```MySQL
    select time_of_day,branch, avg(rating)
    from walmartsales
    group by time_of_day, branch
    order by branch, avg(rating) desc;
    ```
    ![image](https://github.com/user-attachments/assets/b47b263e-1ab5-484b-b546-2677e5e6a1de)

23. What day of the week has the best average ratings?
    ```MySQL
    select day_name, avg(rating)
    from walmartsales
    group by day_name
    order by avg(rating) desc;
    ```
    ![image](https://github.com/user-attachments/assets/69ffb466-7f17-4598-bc35-02ade196a7d3)

24. What day of the week has the best average ratings per branch?
    ```MySQL
    select branch,day_name,  avg(rating) as max_avg_rating
    from walmartsales
    group by branch, day_name
    order by branch, avg(rating) desc;
    ```
    ![image](https://github.com/user-attachments/assets/69ffb466-7f17-4598-bc35-02ade196a7d3)
    

#### **STEP 6: Design Dashboard to visualize findings**

![image](https://github.com/user-attachments/assets/70bece36-5423-4e93-b835-9536b3457f21)



#### KEY INSIGHTS AND RECOMMENDATIONS

# END



