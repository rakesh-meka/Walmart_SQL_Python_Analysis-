SELECT * FROM walmart_db.walmart;

#Business_Problems
#Q1: Find Different Payment Method and number of transcations, number of qty sold 

select payment_method, 
count(*) as no_of_transaction,
sum(quantity) as qty_sold from walmart
group by payment_method;

#Q2: Which category received the highest average rating in each branch?

select *
from
( select branch, category, avg(rating) as avg_rating,
Rank() over(partition by branch order by avg(rating) desc) as ranking
from walmart
group by branch, category
 ) as subquery
where ranking = 1


#Q3: What is the busiest day of the week for each branch based on transaction volume?

 select * from 
 ( 
  select branch, 
  dayname (STR_TO_DATE(date, '%d/%m/%y')) as day_name,
  count(*)  as no_of_transcations,
  rank() over(partition by branch order by count(*) desc) as ranking
  from walmart
  group by
  branch, day_name
) as subquery
where ranking= 1;

#Q4: How many items were sold through each payment method?

select payment_method, 
sum(quantity) as qty_sold from walmart
group by payment_method;

#Q5: What are the average, minimum, and maximum ratings for each category in each city?

select city, category, min(rating) as min_rating, max(rating) as max_rating, avg(rating) as avg_rating from walmart
group by city, category;

#Q6: What is the total profit for each category, ranked from highest to lowest?

select category, sum(total) as total_revenue, 
sum( total * profit_margin) as profit from walmart
group by category
order by profit desc

#Q7: What is the most frequently used payment method in each branch?

with cte as ( select branch, 
payment_method,
count(*) as no_of_transcations,
rank() over(partition by branch order by count(*) desc) as ranking
from walmart
group by branch, payment_method )
select *from cte where ranking = 1

#Q8: How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT 
    branch, 
    COUNT(*) AS no_of_transactions,
    CASE 
        WHEN EXTRACT(HOUR FROM STR_TO_DATE(time, '%H:%i')) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM STR_TO_DATE(time, '%H:%i')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM walmart
GROUP BY branch, time_of_day
order by branch, time_of_day desc;

#Q9: : Which branches experienced the largest decrease in revenue compared to the previous year?


#2022 Sales
with revenue_2022 as
(
select branch,
sum(total) as revenue from walmart
where year(STR_TO_DATE(date, '%d/%m/%y'))= 2022
group by branch
),
revenue_2023 as
(
select branch,
sum(total) as revenue from walmart
where year(STR_TO_DATE(date, '%d/%m/%y'))= 2023
group by branch
)

select ls.branch, ls.revenue as last_year_revenue, 
cs.revenue as current_year_revenue,
ROUND(((ls.revenue - cs.revenue) / ls.revenue) * 100, 2) AS revenue_dec_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch
where ls.revenue > cs.revenue
order by revenue_dec_ratio desc
limit 5




