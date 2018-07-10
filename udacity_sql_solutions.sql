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
