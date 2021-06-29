use db_SQLCaseStudies
select * from dbo.Transactions
select * from dbo.Customer
select * from dbo.prod_cat_info

--Data Preparation and Understanding
--Q1: What is the total number of rows in each of 3 tables in the database?
select (select count(*) from dbo.Transactions) as Total_rows_transaction,
(select count(*) from dbo.Customer) as Total_rows_customers,
(select count(*) from dbo.prod_cat_info) as Total_rows_product

--Q2: what is the total number of transactions that have a return?
select total_amt, [Returns] = (Round(SUM(cast( case when Qty < 0 then total_amt else 0 end as float)),2)) from dbo.Transactions 
group by total_amt 
order by  Returns

select count(Qty) as No_of_return_transactions from dbo.Transactions where Qty<0

--Q3: As you would have noticed the dates provided across the datasets are not in a correct format. As first step please convert date variable in to valid date formats before proceeding ahead?
select FORMAT(tran_date,'dd/MM/yyyy') as Correct_date from dbo.Transactions  


--Q4: What is the time range of the transaction date available for analysis? Show the output in number of days,months and years simultaneaously in different columns.
select DATEPART(DAY,tran_date) as Day_part,
	   DATEPART(MONTH,tran_date) as Month_part,
       DATEPART(YEAR,tran_date) as Year_part
from dbo.Transactions

--Q5: Which product category does the sub-category "DIY" belong to?
select prod_cat,prod_subcat from dbo.prod_cat_info where prod_subcat='DIY'

--Data Analysis 
--Q1: Which channel is the most frequently used for transactions?
select top 1 Store_type, count(Store_type) as Most_frequently_used_Channel 
from dbo.Transactions 
group by Store_type
order by count(Store_type) desc

--Q2: What is the count of male and female customers in the database?
select(select count(gender) from dbo.Customer where Gender='M') as Male,
 (select count(gender) from dbo.Customer where Gender='F') as Female 

--Q3: From which city do we have the maximum number of customers and how many?
select top 1 city_code, count(city_code) as Maximum_number_of_customers 
from dbo.Customer
group by city_code
order by count(city_code) desc

--Q4: How many sub-catogories are there under the books category?
select prod_cat, count(prod_subcat) as No_of_sub_catogories 
from dbo.prod_cat_info 
where prod_cat='Books' 
group by prod_cat 

--Q5: What is the maximum quantity of products ever ordered? 

select TOP 1 Qty,prod_subcat_code, prod_cat_code from Transactions ORDER by Qty Desc

select prod_subcat_code, count(prod_subcat_code) as Maximum_quantity
from dbo.Transactions
group by prod_subcat_code
order by count(prod_subcat_code) desc

--Q6: What is the net total revenue generated in categories electronics and books? 
select(select sum(total_amt) from dbo.Transactions where prod_cat_code='3')as Total_revenue_of_electronics ,
(select sum(total_amt) from dbo.Transactions where prod_cat_code='5')as Total_revenue_of_books,
(select sum(total_amt) from dbo.Transactions where prod_cat_code in( 3 , 5))as Total_revenue  

--Q7: How many customers >10 transactions with us excluding returns?
SELECT cust_id, 
    SUM(total_amt) AS Total_Amount_of_Transactions, 
    COUNT(cust_id) AS Count_of_Transactions
FROM Transactions
WHERE Qty >= 0
GROUP BY cust_id
HAVING COUNT(cust_id) > 10

--Q8: What is the combined revenue earned from the "Electronics" & "Clothing" cateogories from "Flagship stores"?
select(select sum(total_amt) from dbo.Transactions where prod_cat_code='3' AND Store_type= 'Flagship store') as Total_revenue_Electronics,
(select sum(total_amt) from dbo.Transactions where prod_cat_code='1' and Store_type='Flagship store') as Total_revenue_Clothing,
(select sum(total_amt) from dbo.Transactions where prod_cat_code in (1,3) and Store_type='Flagship store')as Total_revenue 

--Q9: What is the total revenue generated from "Male" customers in "Electronics" category? Output should display total revenue by prod sub-cat?
select round(sum(total_amt),2) as Total_revenue from dbo.Transactions as T1
inner join dbo.Customer as T2 on T1.cust_id=T2.customer_Id where Gender='M' and prod_cat_code='3'

select T1.prod_cat_code,T1.prod_subcat_code, round(sum(total_amt),2) as Total_revenue from dbo.Transactions as T1
join dbo.Customer as T2 on T1.cust_id=T2.customer_Id where T2.Gender='M' and T1.prod_cat_code='3' Group BY T1.prod_cat_code,T1.prod_subcat_code
ORDER BY T1.prod_subcat_code


--Q10: What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales? 
select top 5
[Subcategory] = P.prod_subcat,
[Sales] =   Round(SUM(cast( case when T.Qty > 0 then total_amt else 0 end as float)),2) , 
[Returns] = Round(SUM(cast( case when T.Qty < 0 then total_amt else 0 end as float)),2) , 
[Profit] =  Round(SUM(cast(total_amt as float)),2) 
from Transactions as T
INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_sub_cat_code
group by P.prod_subcat

 select top 5
     P.prod_subcat [Subcategory] ,
      Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)[Sales]  , 
     Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2) [Returns] ,
    Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)[total_qty],
    ((Round(SUM(cast( case when T.Qty < 0 then T.Qty  else 0 end as float)),2))/
                  (Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)))*100[%_Returs],
    ((Round(SUM(cast( case when T.Qty > 0 then T.Qty  else 0 end as float)),2))/
                  (Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)))*100[%_sales]
    from Transactions as T
    INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_sub_cat_code
    group by P.prod_subcat
    order by [%_sales] desc


--Q11: For all Customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?
SELECT SUM(t.total_amt) as net_total_revenue
FROM (SELECT t.*,
             MAX(t.tran_date) OVER () as max_tran_date
      FROM Transactions t
     ) t JOIN
     Customer c
     ON t.cust_id = c.customer_Id
WHERE t.tran_date >= DATEADD(day, -30, t.max_tran_date) AND 
      t.tran_date >= DATEADD(YEAR, 25, c.DOB) AND
      t.tran_date < DATEADD(YEAR, 31, c.DOB);

--Q12: Which product category has seen the max value of returns in the last 3 months of transactions?
SELECT TOP 1 prod_cat_code,SUM(Total_amt) as totalreturns
    FROM Transactions
WHERE Tran_date >= DATEADD(day, -90, '2014-02-28')
    AND Total_amt < 0
GROUP BY prod_cat_code
ORDER BY totalreturns 

--Q13: Which store-type sells the maximum products;by value of sales amount and by quantity sold?
select top 1 store_type, 
MAX(total_amt) AS max_total_amt, 
MAX(Qty) AS max_Qty
from Transactions 
group by Store_type

--Q14: What are the categories for which average revenue is above average. 
SELECT p.prod_cat, AVG(t.total_amt) AS average 
FROM (SELECT t.*, AVG(t.total_amt) OVER () as overall_average
      FROM Transactions T
     ) t JOIN
     prod_cat_info P 
     ON T.prod_cat_code = P.prod_cat_code
GROUP BY p.prod_cat, overall_average
HAVING AVG(t.total_amt) > overall_average;

--Q15: Find the average and total revenue by each sub-category for the categories which are among top 5 categories in terms of quantites sold?

select prod_cat_code, SUM(Qty) AS Qty INTO #TEMP from Transactions  Group By prod_cat_code 

SELECT TOP 5 
    AVG(total_amt) AS 'Average Revenue',
    SUM(total_amt) as 'Total Revenue',
    prod_cat as 'Product Category',
    prod_subcat as 'Product Sub Category'
FROM Transactions
JOIN prod_cat_info
    ON prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
WHERE Transactions.prod_cat_code IN (select TOP 5 prod_cat_code from #TEMP ORDER BY  Qty DESC)
GROUP BY prod_subcat,prod_cat
ORDER BY MAX(Qty) desc,AVG(total_amt) desc ,SUM(total_amt) desc


SELECT TOP 5 
    MAX(Qty) AS Quantity,
    AVG(total_amt) AS 'Average Revenue',
    SUM(total_amt) as 'Total Revenue',
    prod_cat as 'Product Category',
    prod_subcat as 'Product Sub Category'
FROM Transactions
LEFT JOIN prod_cat_info
    ON prod_cat_info.prod_sub_cat_code=Transactions.prod_subcat_code
GROUP BY prod_subcat,prod_cat
ORDER BY MAX(Qty) desc,AVG(total_amt) desc ,SUM(total_amt) desc
