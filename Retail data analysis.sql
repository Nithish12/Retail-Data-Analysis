create database Retail_Data

use Retail_Data

--Q1. What is the total number of rows in each of the 3 tables in the database?
--A1. The total number of rows in Customer Table is 5647, in the product_Cateor_info tale it is 23 rows and in Transactions table it is 23053 rows

select count(customer_id)[Total Customer rows],(select count(prod_cat_code) 
from prod_cat_info)[Total Product rows],(select count(transaction_id) 
from Transactions)[Total Transactions rows]
from Customer

--Q1



--Q2. What is the total number of transactions that have a return?

select * from Transactions
where Qty<0

--Q2



--Q3. As you would have noticed, the dates provided across the datasets are not in a correct format.
      As first steps, pls convert the date variables into valid date formats before proceeding ahead. 

Update Transactions
set tran_date=convert(date,tran_date,105)

--Q3



--Q4. What is the time range of the transaction data available for analysis?
      Show the output in number of days, months and years simultaneously in different columns.

select tran_date, year(tran_date)[Year], datename(month,tran_date)[Month], day(tran_date)[Day] from Transactions
--The time range available for analysis is from January 25th, 2011 till February 28th 2014

--Q4



--Q5. Which product category does the sub-category “DIY” belong to?

select * from prod_cat_info
where prod_subcat='DIY'

--Q5



--Analysis


--Q1 Which channel is most frequently used for transactions?

select distinct Store_type
from Transactions

--Q1



--Q2 What is the count of Male and Female customers in the database?

select count(Gender)[Male Customers],
(select count(Gender)
from Customer
where gender = 'F')[Female Customers]
from Customer
where gender = 'M'

--Q2



--Q3 From which city do we have the maximum number of customers and how many?

select city_code, count(customer_id)[No of Customers]
from Customer
group by city_code 
Order by [No of Customers] desc

--Q3



--Q4 How many sub-categories are there under the Books category?

select count(prod_subcat)
from prod_cat_info
where prod_cat='Books'

--Q4



--Q5 What is the maximum quantity of products ever ordered?

select max(Qty) [Max Quantity of products ordered]
from Transactions

--Q5



--Q6 What is the net total revenue generated in categories Electronics and Books?

select prod_cat, round(sum(cast(total_amt as float)),2)[Total Revenue] from prod_cat_info p inner join Transactions t on p.prod_cat_code = t.prod_cat_code
where prod_cat in ('Electronics','Books')
group by prod_cat

--Q6



--Q7 How many customers have >10 transactions with us, excluding returns?

select distinct cust_id[Customers], count(transaction_id)[No of Transactions]
from Transactions
group by cust_id
having count(transaction_id)>10

--Q7



--Q8 What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

select Store_type,sum(cast(total_amt as float))[Total Revenue from Clothing & Electronics]
from Transactions
where prod_cat_code in ('1','3') and Store_type = 'Flagship store'
group by Store_type

--Q8



--Q9 What is the total revenue generated from “Male” customers in “Electronics” category?
     Output should display total revenue by prod sub-cat.

select Gender, prod_subcat[Electronics], sum(cast(total_amt as float))[Total Revenue from Electronics]
from Transactions t inner join Customer c on c.customer_Id = t.cust_id 
				inner join prod_cat_info p on  p.prod_cat_code = t.prod_cat_code
where Gender = 'M' and prod_cat = 'Electronics'
group by Gender, prod_subcat

--Q9



--Q10 What is percentage of sales and returns by product sub category;
      display only top 5 sub categories in terms of sales?

select  top 5 prod_subcat, sum(cast(Rate as float))[Returns],  round(sum(cast(total_amt as float)),2)[Total Sales],
sum(cast(total_amt as float))*100/(select sum(cast(total_amt as float)) from Transactions)[Percentage of Sales]
from prod_cat_info p inner join Transactions t on p.prod_cat_code = t.prod_cat_code
group by prod_subcat
order by [Total Sales] desc

--Q10



--Q11 For all customers aged between 25 to 35 years find what is the net total revenue generated
      by these consumers in last 30 days of transactions from max transaction date available in the data?

select datediff(YEAR,DOB,GETDATE())[Age], sum(cast(total_amt as float))[Total Revenue], max(tran_date)[Transaction Date]
from Customer c inner join Transactions t on c.customer_Id = t.cust_id
where tran_date >= (select dateadd(day, -30, max(tran_date)) from Transactions)
group by DOB
having datediff(YEAR,DOB,GETDATE()) between '25' and '35'

--Q11



--Q12 Which product category has seen the max value of returns in the last 3 months of transactions?

select prod_cat, min(cast(Qty as float))[Maximum Returns], tran_date
from prod_cat_info p inner join Transactions t on p.prod_cat_code = t.prod_cat_code
where tran_date >= (select dateadd(month, -3, max(tran_date)) from Transactions) and Qty<0
group by prod_cat, tran_date
order by [Maximum Returns], tran_date desc

--Q12



--Q13 Which store-type sells the maximum products; by value of sales amount and by quantity sold?

select Store_type, round(sum(cast(total_amt as float)),2)[Sales Amount], sum(cast(Qty as int))[Quantity Sold]
from Transactions
group by  Store_type
order by [Sales Amount] desc

--Q13



--Q14 What are the categories for which average revenue is above the overall average.

select prod_cat,round(avg(cast(total_amt as float)),2)[Average Revenue of Product Category],(select round(avg(cast(total_amt as float)),2) from Transactions)[Overall Average Revenue] 
from prod_cat_info p inner join Transactions t on p.prod_cat_code = t.prod_cat_code
group by prod_cat
having avg(cast(total_amt as float))>(select avg(cast(total_amt as float)) from Transactions)
order by [Average Revenue of Product Category] desc

--Q14



--Q15 Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.

select top 5 prod_subcat, round(avg(cast(total_amt as float)),2)[Average Revenue], round(sum(cast(total_amt as float)),2)[Sales Amount], sum(cast(Qty as int))[Quantity Sold]
from prod_cat_info p inner join Transactions t on p.prod_cat_code = t.prod_cat_code
where p.prod_cat in (select top 5 prod_cat 
from prod_cat_info p inner join Transactions t on p.prod_cat_code = t.prod_cat_code
group by  prod_cat
order by sum(cast(Qty as int)) desc)
group by prod_subcat

--Q15
