--SQL Advance Case Study

use db_SQLCaseStudies2 

--Q1 List all the states in which we have customers who have bought cellphones from 2005 till today.

select [State], IDCustomer, IDModel[Cellphone ModelID], [Date] from FACT_TRANSACTIONS ft inner join DIM_LOCATION dl on ft.IDLocation = dl.IDLocation
where Quantity>0 and [Date]>='2005'
group by IDCustomer, [Date], [State], IDModel
order by  [Date] 

--Q1





--Q2 What state in the US is buying the most 'Samsung' cell phones?

select top 1 Country,[State],sum(Quantity)[Quantity] from FACT_TRANSACTIONS ft inner join DIM_LOCATION dl on ft.IDLocation = dl.IDLocation
									join DIM_MODEL dm on ft.IDModel	= dm.IDModel
where Country = 'US' and IDManufacturer = 12
group by Country,[State]
Order by [Quantity] desc

--Q2





--Q3 Show the number of transactions for each model per zip code per state.

select distinct IDModel, ZipCode,[State],TotalPrice, Quantity from FACT_TRANSACTIONS ft inner join DIM_LOCATION dl on ft.IDLocation = dl.IDLocation

--Q3





--Q4 Show the cheapest cellphone (Output should contain the price also)

select top 1 Model_Name[Cellphone Name], min(Unit_price)[Cellphone Price] from DIM_MODEL
group by Model_Name
order by [Cellphone Price] asc

--Q4





--Q5 5.	Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.

select distinct top 5 Manufacturer_Name, count(Quantity)[Sales Quantity], round(avg(TotalPrice),2)[Average Price] from FACT_TRANSACTIONS ft inner join DIM_MODEL dm on ft.IDModel = dm.IDModel
							inner join DIM_MANUFACTURER de on dm.IDManufacturer = de.IDManufacturer
group by  Manufacturer_Name
order by [Average Price]

--Q5





--Q6 List the names of the customers and the average amount spent in 2009, where the average is higher than 500.

select Customer_Name, avg(TotalPrice)[Average Spending] from DIM_CUSTOMER dc inner join FACT_TRANSACTIONS ft on dc.IDCustomer = ft.IDCustomer
where year(Date) = 2009
group by Customer_Name 
having avg(TotalPrice)>500

--Q6





--Q7 List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010.

Select * from (select top 5 Model_Name from FACT_TRANSACTIONS inner join DIM_MODEL  on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
where year(Date) in (2008)
group by Model_Name
order by sum(Quantity) desc)t1

intersect 

Select * from (select top 5 Model_Name from FACT_TRANSACTIONS inner join DIM_MODEL  on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
where year(Date) in (2009)
group by Model_Name 
order by sum(Quantity) desc)t2

intersect

Select * from (select top 5 Model_Name from FACT_TRANSACTIONS inner join DIM_MODEL  on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
where year(Date) in (2010)
group by Model_Name
order by sum(Quantity) desc)t3


--Q7





--Q8 Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.

select Manufacturer_Name[2nd Top Manufacturer in 2009],(select  Manufacturer_Name from FACT_TRANSACTIONS join DIM_MODEL on FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
inner join  DIM_MANUFACTURER on DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer
where year(Date)in(2010)
group by Manufacturer_Name
order by Sum(TotalPrice) desc
offset 1 row
fetch first 1 row only)[2nd Top Manufacturer in 2010] from FACT_TRANSACTIONS join DIM_MODEL on FACT_TRANSACTIONS.IDModel=DIM_MODEL.IDModel
inner join  DIM_MANUFACTURER on DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer
where year(Date)in(2009)
group by Manufacturer_Name
order by Sum(TotalPrice) desc
offset 1 row
fetch first 1 row only

--Q8





--Q9 Show the manufacturers that sold cellphones in 2010 but did not in 2009.

Select distinct Manufacturer_Name from FACT_TRANSACTIONS ft join DIM_MODEL dm on ft.IDModel = dm.IDModel
								join DIM_MANUFACTURER de on dm.IDManufacturer = de.IDManufacturer
where year(Date) in (2010) 

except 

Select distinct Manufacturer_Name from FACT_TRANSACTIONS ft join DIM_MODEL dm on ft.IDModel = dm.IDModel
								join DIM_MANUFACTURER de on dm.IDManufacturer = de.IDManufacturer
where year(Date) in (2009) 

--Q9





--Q10 Find top 100 customers and their average spend, average quantity by each year.
      Also find the percentage of change in their spend.

select top 100 IDCustomer,year(Date)[Year], avg(TotalPrice)[Average Spend], avg(Quantity)[Average Quantity]
,(avg(TotalPrice) - lag(avg(TotalPrice),1)over(order by IDCustomer,year(Date))) / lag(avg(TotalPrice),1)over(order by IDCustomer,year(Date))[Percentage of change in Average Spend]
from FACT_TRANSACTIONS
group by year(Date), IDCustomer
order by IDCustomer,[year]

--Q10	









