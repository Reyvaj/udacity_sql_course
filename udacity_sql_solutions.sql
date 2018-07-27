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

'''
On which day-channel pair did the most events occur.
'''
SELECT DATE_TRUNC('day', occurred_at) AS day, channel, COUNT(*)
FROM web_events
GROUP BY DATE_TRUNC('day', occurred_at), channel
ORDER BY COUNT(*) DESC;

'''
Now create a subquery that simply provides all of the data from your
first query.
'''
SELECT channel, AVG(count)
FROM
 (SELECT DATE_TRUNC('day', occurred_at) AS day, channel, COUNT(*)
 FROM web_events
 GROUP BY DATE_TRUNC('day', occurred_at), channel
 ORDER BY COUNT(*) DESC) AS sub
 GROUP BY 1
 ORDER BY 2 DESC;

'''
Use DATE_TRUNC to pull month level information about the first order ever
placed in the orders table.
'''
SELECT DATE_TRUNC('month', MIN(occurred_at))
FROM orders

'''
Use the result of the previous query to find only the orders that took place
in the same month and year as the first order, and then pull the average
for each type of paper qty in this month.
'''
SELECT AVG(standard_qty) avg_std,
       AVG(gloss_qty) avg_gloss, AVG(poster_qty) avg_poster
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = (SELECT DATE_TRUNC('month', MIN(occurred_at))
FROM orders);

'''
Provide the name of the sales_rep in each region with the largest
amount of total_amt_usd sales.
'''
SELECT t3.rep, t3.region, t3.total_sales
FROM (SELECT region, MAX(total_sales) total_sales
      FROM (SELECT s.name rep, r.name region, SUM(o.total_amt_usd) total_sales
            FROM sales_reps s
            JOIN accounts a
            ON a.sales_rep_id = s.id
            JOIN orders o
            ON o.account_id = a.id
            JOIN region r
            ON s.region_id = r.id
            GROUP BY 1, 2) t1
      GROUP BY 1) t2
JOIN (SELECT s.name rep, r.name region, SUM(o.total_amt_usd) total_sales
      FROM sales_reps s
      JOIN accounts a
      ON a.sales_rep_id = s.id
      JOIN orders o
      ON o.account_id = a.id
      JOIN region r
      ON s.region_id = r.id
      GROUP BY 1, 2
      ORDER BY 3) t3
ON t3.region = t2.region AND t3.total_sales = t2.total_sales;

'''
For the region with the largest sales total_amt_usd,
how many total orders were placed?
'''
SELECT t2.region, t2.total_orders
FROM (SELECT r.name region, SUM(o.total_amt_usd) total_amt_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps sr
ON a.sales_rep_id = sr.id
JOIN region r
ON sr.region_id = r.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1) t1
JOIN (SELECT r.name region, COUNT(*) total_orders
      FROM orders o
      JOIN accounts a
      ON o.account_id = a.id
      JOIN sales_reps sr
      ON a.sales_rep_id = sr.id
      JOIN region r
      ON sr.region_id = r.id
      GROUP BY 1) t2
ON t1.region = t2.region;

'''
For the name of the account that purchased the most (in total over
their lifetime as a customer) standard_qty paper, how many accounts
still had more in total purchases?
'''
SELECT COUNT(*)
FROM (
SELECT a.name AS name, SUM(o.total) total_purchases
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
HAVING SUM(o.total) > (SELECT t1.total_purchases
                       FROM (SELECT a.name AS name,
                                    SUM(o.standard_qty) total_std_qty,
                                    SUM(o.total) total_purchases
                             FROM accounts a
                             JOIN orders o
                             ON o.account_id = a.id
                             GROUP BY 1
                             ORDER BY 2 DESC
                             LIMIT 1) t1)) sub;

'''
For the customer that spent the most (in total over their lifetime
as a customer) total_amt_usd, how many web_events did they have
for each channel?
'''
SELECT sub.name, sub.id, we.channel, COUNT(*)
FROM web_events we
JOIN (SELECT a.name AS name, a.id AS id, SUM(o.total_amt_usd) total_spent
      FROM accounts a
      JOIN orders o
      ON a.id = o.account_id
      GROUP BY 1, 2
      ORDER BY 3 DESC
      LIMIT 1) sub
ON we.account_id = sub.id
GROUP BY 1,2,3
ORDER BY 4 DESC;

'''
What is the lifetime average amount spent in terms of total_amt_usd
for the top 10 total spending accounts?
'''
SELECT AVG(total_spent)
FROM (SELECT a.id AS id, SUM(o.total_amt_usd) total_spent
      FROM accounts a
      JOIN orders o
      ON a.id = o.account_id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 10) sub;

'''
What is the lifetime average amount spent in terms of total_amt_usd
for only the companies that spent more than the average of all orders.
'''
SELECT AVG(total_spent)
FROM (SELECT a.name, AVG(o.total_amt_usd) total_spent
      FROM accounts a
      JOIN orders o
      ON a.id = o.account_id
      GROUP BY 1
      HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd)
                                     FROM orders o)
      ORDER BY 2) sub 

'''
Provide the name of the sales_rep in each region with the largest
amount of total_amt_usd sales.
'''
WITH t1 AS
        (SELECT sr.name rep, r.name region, SUM(o.total_amt_usd) AS total_sales
          FROM orders o
          JOIN accounts a
          ON o.account_id = a.id
          JOIN sales_reps sr
          ON a.sales_rep_id = sr.id
          JOIN region r
          ON sr.region_id = r.id
          GROUP BY 1, 2),
     t2 AS
        (SELECT region, MAX(total_sales) AS total_sales
          FROM t1
          GROUP BY 1)
SELECT t1.rep, t1.region, t1.total_sales
FROM t1
JOIN t2
ON t1.total_sales = t2.total_sales AND t1.region = t2.region

'''
For the region with the largest sales total_amt_usd,
how many total orders were placed?
'''
SELECT r.name, SUM(o.total_amt_usd), COUNT(*)
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps sr
ON a.sales_rep_id = sr.id
JOIN region r
ON sr.region_id = r.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

'''
For the account that purchased the most (in total over their
lifetime as a customer) standard_qty paper, how many accounts
still had more in total purchases?
'''
WITH t1 AS
      (SELECT a.name, SUM(o.standard_qty) total_std,
              SUM(o.total) total_purchases
      FROM orders o
      JOIN accounts a
      ON o.account_id = a.id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 1),
    t2 AS
      (SELECT a.name
      FROM orders o
      JOIN accounts a
      ON o.account_id = a.id
      GROUP BY 1
      HAVING SUM(o.total) > (SELECT total_purchases FROM t1))
SELECT COUNT(*)
FROM t2;

'''
For the customer that spent the most (in total over their lifetime
as a customer) total_amt_usd, how many web_events did they have for
each channel?
'''
WITH t1 AS (
          SELECT a.id AS id, SUM(o.total_amt_usd) total_spent
          FROM orders o
          JOIN accounts a
          ON o.account_id = a.id
          GROUP BY 1
          ORDER BY 2 DESC
          LIMIT 1)
SELECT channel, COUNT(*)
FROM web_events we
JOIN t1
ON t1.id = we.account_id
GROUP BY 1
ORDER BY 2;

'''
What is the lifetime average amount spent in terms of total_amt_usd
for the top 10 total spending accounts?
'''
WITH t1 AS (
          SELECT a.name, SUM(o.total_amt_usd) total_spent
          FROM orders o
          JOIN accounts a
          ON o.account_id = a.id
          GROUP BY 1
          ORDER BY 2 DESC
          LIMIT 10)
SELECT AVG(total_spent)
FROM t1;

'''
What is the lifetime average amount spent in terms of total_amt_usd
for only the companies that spent more than the average of all accounts.
'''
WITH t1 AS (
  SELECT AVG(o.total_amt_usd) avg_all
  FROM orders o),
     t2 AS (
  SELECT a.name, AVG(o.total_amt_usd) avg_spent
  FROM orders o
  JOIN accounts a
  ON o.account_id = a.id
  GROUP BY 1
  HAVING AVG(o.total_amt_usd) > (SELECT avg_all FROM t1))
SELECT AVG(avg_spent)
FROM t2;

/* LEFT & RIGHT */
'''
In the accounts table, there is a column holding the
website for each company. The last three digits specify
what type of web address they are using. A list of extensions
(and pricing) is provided here. Pull these extensions and
provide how many of each website type exist in the accounts table.
'''
SELECT RIGHT(website, 4) AS extensions, COUNT(*)
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

'''
There is much debate about how much the name (or even
the first letter of a company name) matters. Use the
accounts table to pull the first letter of each company
name to see the distribution of company names that begin
with each letter (or number).
'''
SELECT LEFT(UPPER(name), 1) AS first_letter, COUNT(*)
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

'''
Use the accounts table and a CASE statement to create two groups:
one group of company names that start with a number and a second
group of those company names that start with a letter. What
proportion of company names start with a letter?
'''
WITH t1 AS (
      SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN
                ('1','2','3','4','5','6','7','8','9','0')
            THEN 1 ELSE 0 END names_with_num,
            CASE WHEN LEFT(UPPER(name), 1) IN
                ('1','2','3','4','5','6','7','8','9','0')
            THEN 0 ELSE 1 END names_with_letters
      FROM accounts)
SELECT SUM(names_with_num) AS nums, SUM(names_with_letters) AS letters
FROM t1

'''
Consider vowels as a, e, i, o, and u. What proportion of company names
start with a vowel, and what percent start with anything else?
'''
SELECT SUM(vowels) v, SUM(everything_else) e
FROM (
SELECT name, CASE WHEN LEFT(name, 1) in
                  ('a','e','i','o','u') THEN 1 ELSE 0 END vowels,
             CASE WHEN LEFT(name, 1) in
                  ('a','e','i','o','u') THEN 0 ELSE 1 END everything_else
FROM accounts) sub;

/* POSITION & STRPOS */
'''
Use the accounts table to create first and last name columns 
that hold the first and last names for the primary_poc. 
'''
SELECT LEFT(primary_poc, POSITION(' ' in primary_poc)) AS first_name, 
       RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) 
       AS last_name
FROM accounts

'''
Now see if you can do the same thing for every rep name in the 
sales_reps table. Again provide first and last name columns.
'''
SELECT LEFT(name, POSITION(' ' IN name)) AS first_name,
       RIGHT(name, LENGTH(name)-POSITION(' ' IN name)) AS last_name
FROM sales_reps

/*CONCAT*/
'''
Each company in the accounts table wants to create an email address
for each primary_poc. The email address should be the first name of
the primary_poc . last name primary_poc @ company name .com.
'''
WITH t1 AS(
  SELECT lower(name) AS name,
        LEFT(lower(primary_poc), POSITION(' ' in primary_poc)-1) AS first_name,
        RIGHT(lower(primary_poc), LENGTH(primary_poc)-POSITION(' ' in primary_poc)) AS last_name
  FROM accounts)
SELECT CONCAT(CONCAT(CONCAT(first_name, last_name), '@'), name)
FROM t1;

'''
You may have noticed that in the previous solution some of the
company names include spaces, which will certainly not work in an
email address. See if you can create an email address that will
work by removing all of the spaces in the account name, but
otherwise your solution should be just as in question 1.
'''
WITH t1 AS(
  SELECT lower(replace(name, ' ', '')) AS name,
        LEFT(lower(primary_poc), POSITION(' ' in primary_poc)-1) AS first_name,
        RIGHT(lower(primary_poc), LENGTH(primary_poc)-POSITION(' ' in primary_poc)) AS last_name
  FROM accounts)
SELECT CONCAT(CONCAT(CONCAT(first_name, last_name), '@'), name)
FROM t1;

"""
We would also like to create an initial password, which they will
change after their first log in. The first password will be the first
letter of the primary_poc's first name (lowercase), then the last
letter of their first name (lowercase), the first letter of their
last name (lowercase), the last letter of their last name (lowercase),
the number of letters in their first name, the number of letters in
their last name, and then the name of the company they are working
with, all capitalized with no spaces.
"""
WITH t1 AS(
  SELECT lower(replace(name, ' ', '')) AS company,
        LEFT(lower(primary_poc), POSITION(' ' in primary_poc)-1) AS first_name,
        RIGHT(lower(primary_poc), LENGTH(primary_poc)-POSITION(' ' in primary_poc)) AS last_name
  FROM accounts)
SELECT UPPER(LEFT(first_name, 1) || RIGHT(first_name, 1) || LEFT(last_name, 1) ||
        RIGHT(last_name, 1) || LENGTH(first_name) || LENGTH(last_name) ||
        company)
FROM t1

'''
Write a query to change the date into the correct SQL date format.
'''
WITH t1 AS (
      SELECT SUBSTR(date, 1, 2) AS month, SUBSTR(date, 4, 2) AS day,
              SUBSTR(date, 7, 4) AS year
      FROM sf_crime_data)
SELECT (year || month || day)::DATE AS sql_date_format
FROM t1;

/*COALESCE*/
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty, 0) gloss_qty,
COALESCE(o.poster_qty, 0) poster_qty,
COALESCE(o.total, 0) total,
COALESCE(o.standard_amt_usd, 0) standard_amt_usd,
COALESCE(o.gloss_amt_usd, 0) gloss_amt_usd,
COALESCE(o.poster_amt_usd, 0) poster_amt_usd,
COALESCE(o.total_amt_usd, 0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*WINDOW FUNCTIONS 1*/
'''
This time, create a running total of standard_amt_usd
(in the orders table) over order time with no date truncation.
Your final table should have two columns: one with the amount
being added for each new row, and a second with the running total.
'''
SELECT standard_amt_usd,
		SUM(standard_amt_usd) OVER(ORDER BY occurred_at) AS running_total
FROM orders

'''
Now, modify your query from the previous quiz to include partitions.
Still create a running total of standard_amt_usd (in the orders table)
over order time, but this time, date truncate occurred_at by year
and partition by that same year-truncated occurred_at variable.
Your final table should have three columns: One with the amount
being added for each row, one for the truncated date, and a final
columns with the running total within each year.
'''
SELECT standard_amt_usd,
		DATE_TRUNC('year', occurred_at) AS year,
        SUM(standard_amt_usd) OVER(PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders

'''
Select the id, account_id, and total variable from the orders table,
then create a column called total_rank that ranks this total
amount of paper ordered (from highest to lowest) for each
account using a partition. Your final table should have these
four columns.
'''
SELECT id, account_id, total,
       RANK() OVER(PARTITION BY account_id ORDER BY total DESC) AS rank
FROM orders

/* FULL OUTER JOIN AND COMPARISON OPERATORS*/
'''
Each account who has a sales rep and each sales rep that has an 
account (all of the columns in these returned rows will be full),
but also each account that does not have a sales rep and each 
sales rep that does not have an account (some of the columns 
in these returned rows will be empty)
'''
SELECT a.id AS account, sr.id AS sales_rep
FROM accounts a
FULL OUTER JOIN sales_reps sr
ON a.sales_rep_id = sr.id

"""
In the following SQL Explorer, write a query that left joins 
the accounts table and the sales_reps tables on each sale 
rep's ID number and joins it using the < comparison operator 
on accounts.primary_poc and sales_reps.name
"""
SELECT a.name AS account, 
	   a.primary_poc AS poc, 
       sr.name AS sales_rep
FROM accounts a
LEFT JOIN sales_reps sr
ON a.sales_rep_id = sr.id
AND a.primary_poc < sr.name

