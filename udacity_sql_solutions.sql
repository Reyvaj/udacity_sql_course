'''
Each company in the accounts table wants to create an email
address for each primary_poc. The email address should be the f
irst name of the primary_poc . last name primary_poc @ company
name .com.
'''
WITH t1 AS (
  SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name,
         RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' '))
         AS last_name,
         name AS company
  FROM accounts
)
SELECT CONCAT(t1.first_name, '.', t1.last_name, '@', t1.company,
       '.com') AS email
FROM t1;

'''
You may have noticed that in the previous solution some of the company
names include spaces, which will certainly not work in an email address.
See if you can create an email address that will work by removing all of
the spaces in the account name, but otherwise your solution should be just
as in question 1. Some helpful documentation is here.
'''
WITH t1 AS (
  SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name,
         RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' '))
         AS last_name,
         name AS company
  FROM accounts
)
SELECT CONCAT(t1.first_name, '.', t1.last_name, '@',
       REPLACE(t1.company, ' ', ''),
       '.com') AS email
FROM t1;

'''
We would also like to create an initial password, which they will change
after their first log in. The first password will be the first letter of
the primary_poc\'s first name (lowercase), then the last letter of their
first name (lowercase), the first letter of their last name (lowercase),
the last letter of their last name (lowercase), the number of letters in
their first name, the number of letters in their last name, and then the
name of the company they are working with, all capitalized with no spaces.
'''
WITH t1 AS (
  SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name,
         RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS
         last_name, name
  FROM accounts
)
SELECT LOWER(LEFT(first_name, 1)) || LOWER(RIGHT(first_name, 1)) ||
       LOWER(LEFT(last_name, 1)) || LOWER(RIGHT(last_name, 1)) ||
       LENGTH(first_name) || LENGTH(last_name) || UPPER(REPLACE(name, ' ', ''))
FROM t1;

'''
Use DISTINCT to test if there are any accounts associated
with more than one region.
'''
SELECT a.id, r.name
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id;

SELECT DISTINCT a.id
FROM accounts a;

"Both queries give 351 results which mean there are no repeated id associated
to two regions."

'''
Have any sales reps worked on more than one account?
'''
SELECT s.id, COUNT(a.id) AS num_accounts
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.id
ORDER BY num_accounts;

'''
How many of the sales reps have more than 5 accounts that they manage?
'''
SELECT s.id, COUNT(*) AS num_accounts
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.id
HAVING COUNT(*) > 5;

'''
How many accounts have more than 20 orders?
'''
SELECT a.id, COUNT(*)
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id
HAVING COUNT(*) > 20;

'''
Which account has the most orders?
'''
SELECT a.id, a.name, COUNT(*)
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY COUNT(*) DESC;

'''
How many accounts spent more than 30,000 usd total across all orders?
'''
SELECT a.id, a.name, SUM(o.total_amt_usd)
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 30000;

'''
How many accounts spent less than 1,000 usd total across all orders?
'''
SELECT a.id, a.name, SUM(o.total_amt_usd)
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000;

'''
Which account has spent the most with us?
'''
SELECT a.id, a.name, SUM(o.total_amt_usd)
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY SUM(o.total_amt_usd) DESC;

'''
Which account has spent the least with us?
'''
SELECT a.id, a.name, SUM(o.total_amt_usd)
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY SUM(o.total_amt_usd);

'''
Which accounts used facebook as a channel to contact customers more
than 6 times?
'''
SELECT a.id, a.name, w.channel, COUNT(w.channel)
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
HAVING COUNT(w.channel) > 6;

'''
Which account used facebook most as a channel?
'''
SELECT a.id, a.name, w.channel, COUNT(w.channel)
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY COUNT(w.channel) DESC;

'''
Which channel was most frequently used by most accounts?
'''
SELECT channel, COUNT(channel)
FROM web_events
GROUP BY channel
ORDER BY COUNT(channel) DESC;

'''
Find the sales in terms of total dollars for all orders
in each year, ordered from greatest to least. Do you
notice any trends in the yearly sales totals?
'''
SELECT DATE_PART('year', occurred_at), SUM(total_amt_usd)
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

'''
Which month did Parch & Posey have the greatest sales
in terms of total dollars? Are all months evenly
represented by the dataset?
'''
SELECT DATE_PART('month', occurred_at), SUM(total_amt_usd)
FROM orders
GROUP BY 1
ORDER BY 1;

'''
Which year did Parch & Posey have the greatest sales
in terms of total number of orders? Are all years
evenly represented by the dataset?
'''
SELECT DATE_PART('year', occurred_at), SUM(total_amt_usd)
FROM orders
GROUP BY 1
ORDER BY 1;

'''
Which month did Parch & Posey have the greatest sales
in terms of total number of orders? Are all months
evenly represented by the dataset?
'''
SELECT DATE_PART('month', occurred_at), COUNT(*)
FROM orders
GROUP BY 1
ORDER BY 1;

'''
In which month of which year did Walmart spend the most on
gloss paper in terms of dollars?
'''
SELECT DATE_PART('month', o.occurred_at), SUM(o.gloss_amt_usd)
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC;

'''
We would like to understand 3 different levels of customers based
on the amount associated with their purchases. The top branch includes
anyone with a Lifetime Value (total sales of all orders) greater than
200,000 usd. The second branch is between 200,000 and 100,000 usd. The
lowest branch is anyone under 100,000 usd. Provide a table that includes
the level associated with each account. You should provide the account name,
the total sales of all orders for the customer, and the level. Order with
the top spending customers listed first.
'''
SELECT a.id, a.name, SUM(o.total_amt_usd) as total_sales,
CASE WHEN SUM(o.total_amt_usd)>200000 THEN 'top'
     WHEN SUM(o.total_amt_usd)>100000 THEN 'middle'
     ELSE 'low' END AS customer_level
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_sales;

'''
We would now like to perform a similar calculation to the first,
but we want to obtain the total amount spent by customers only in
2016 and 2017. Keep the same levels as in the previous question.
Order with the top spending customers listed first.
'''
SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_sales,
       CASE WHEN SUM(o.total_amt_usd)>200000 THEN 'top'
            WHEN SUM(o.total_amt_usd)>100000 THEN 'middle'
            ELSE 'low' END AS customer_level
FROM accounts a
JOIN orders o
ON a.id = o.account_id
WHERE o.occurred_at > '2015-12-31'
GROUP BY a.id, a.name
ORDER BY total_sales DESC;

'''
We would like to identify top performing sales reps, which are sales
reps associated with more than 200 orders. Create a table with the sales
rep name, the total number of orders, and a column with top or not
depending on if they have more than 200 orders. Place the top sales
people first in your final table.
'''
SELECT s.name, COUNT(*) AS total_orders,
       CASE WHEN COUNT(*) > 200 THEN 'top'
       ELSE 'bottom' END AS rep_level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1
ORDER BY 2 DESC;

"""
The previous didn't account for the middle, nor the dollar amount associated
with the sales. Management decides they want to see these characteristics
represented as well. We would like to identify top performing sales reps,
which are sales reps associated with more than 200 orders or more than
750000 in total sales. The middle group has any rep with more than 150
orders or 500000 in sales. Create a table with the sales rep name, the
total number of orders, total sales across all orders, and a column with top,
middle, or low depending on this criteria. Place the top sales people based on
dollar amount of sales first in your final table.
"""
SELECT s.name, COUNT(*) AS total_orders, SUM(total_amt_usd) AS total_sales,
       CASE WHEN COUNT(*) > 200 OR SUM(total_amt_usd) > 750000 THEN 'top'
            WHEN COUNT(*) > 150 OR SUM(total_amt_usd) > 500000 THEN 'middle'
            ELSE 'bottom' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1
ORDER BY 3 DESC;
