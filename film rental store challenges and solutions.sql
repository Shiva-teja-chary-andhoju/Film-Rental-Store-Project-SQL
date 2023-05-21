1.Task: Create a list of all the different (distinct) replacement costs of the films.

Question: Whats the lowest replacement cost?
Answer: 9.99

SELECT DISTINCT replacement_cost 
FROM film
ORDER BY 1


2.Task: Write a query that gives an overview of how many films have replacements costs in the following cost ranges
        low: 9.99 - 19.99
        medium: 20.00 - 24.99
        high: 25.00 - 29.99

Question: How many films have a replacement cost in the "low" group?
Answer: 514

SELECT 
CASE 
WHEN replacement_cost BETWEEN 9.99 AND 19.99
THEN 'low'
WHEN replacement_cost BETWEEN 20 AND 24.99
THEN 'medium'
ELSE 'high'
END as cost_range,
COUNT(*)
FROM film
GROUP BY cost_range


3.Task: Create a list of the film titles including their title, length and category name ordered descendingly by the length.
Filter the results to only the movies in the category 'Drama' or 'Sports'.

Question: In which category is the longest film and how long is it?
Answer: Sports and 184

SELECT 
title,
name,
length
FROM film f
LEFT JOIN film_category fc
ON f.film_id=fc.film_id
LEFT JOIN category c
ON c.category_id=fc.category_id
WHERE name = 'Sports' OR name = 'Drama'
ORDER BY length DESC

4.Task: Create an overview of how many movies (titles) there are in each category (name).

Question: Which category (name) is the most common among the films?
Answer: Sports with 74 titles

SELECT
name,
COUNT(title)
FROM film f
INNER JOIN film_category fc
ON f.film_id=fc.film_id
INNER JOIN category c
ON c.category_id=fc.category_id
GROUP BY name
ORDER BY 2 DESC


5.Task: Create an overview of the actors first and last names and in  how many movies they appear.

Question: Which actor is part of most movies??
Answer: Susan Davis with 54 movies

SELECT 
first_name,
last_name,
COUNT(*)
FROM actor a
LEFT JOIN film_actor fa
ON fa.actor_id=a.actor_id
LEFT JOIN film f
ON fa.film_id=f.film_id
GROUP BY first_name, last_name
ORDER BY COUNT(*) DESC


6.Task: Create an overview of the addresses that are not associated to any customer.

Question: How many addresses are that?
Answer: 4

SELECT COUNT(*) FROM address a
LEFT JOIN customer c
ON c.address_id = a.address_id
WHERE c.first_name is null


7.Task: Create an overview of the cities and how much sales (sum of amount) have occured there.

Question: Which city has the most sales?
Answer: Cape Coral with a total amount of 221.55

SELECT 
city,
SUM(amount)
FROM payment p
LEFT JOIN customer c
ON p.customer_id=c.customer_id
LEFT JOIN address a
ON a.address_id=c.address_id
LEFT JOIN city ci
ON ci.city_id=a.city_id
GROUP BY city
ORDER BY SUM(amount) DESC


8.Task: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".

Question: Which country, city has the least sales?
Answer: United States, Tallahassee with a total amount of 50.85.

SELECT 
co.country ||', ' ||ci.city,
SUM(amount)
FROM payment p
LEFT JOIN customer c
ON p.customer_id=c.customer_id
LEFT JOIN address a
ON a.address_id=c.address_id
LEFT JOIN city ci
ON ci.city_id=a.city_id
LEFT JOIN country co
ON co.country_id=ci.country_id
GROUP BY co.country ||', ' ||ci.city
ORDER BY 2 ASC


9.Task: Create a list with the average of the sales amount each staff_id has per customer.

Question: Which staff_id makes in average more revenue per customer?
Answer: staff_id 2 with an average revenue of 56.64 per customer.

SELECT 
staff_id,
ROUND(AVG(total),2) as avg_amount 
FROM (
SELECT SUM(amount) as total,customer_id,staff_id
FROM payment
GROUP BY customer_id, staff_id) a
GROUP BY staff_id

10.Task: Create a query that shows average daily revenue of all Sundays.

Question: What is the daily average revenue of all Sundays?
Answer: 1410.65

SELECT 
AVG(total)
FROM 
	(SELECT
	 SUM(amount) as total,
	 DATE(payment_date),
	 EXTRACT(dow from payment_date) as weekday
	 FROM payment
	 WHERE EXTRACT(dow from payment_date)=0
	 GROUP BY DATE(payment_date),weekday) daily


11.Task: Create a list of movies - with their length and their replacement cost -
that are longer than the average length in each replacement cost group.

Question: Which two movies are the shortest in that list and how long are they?
Answer: CELEBRITY HORN and SEATTLE EXPECATIONS with 110 minutes

SELECT 
title,
length
FROM film f1
WHERE length > (SELECT AVG(length) FROM film f2
			   WHERE f1.replacement_cost=f2.replacement_cost)
ORDER BY length ASC


12.Task: Create a list that shows how much the average customer spent in 
total (customer life-time value) grouped by the different districts.

Question: Which district has the highest average customer life-time value?
Answer: Saint-Denis with an average customer life-time value of 216.54.

SELECT
district,
ROUND(AVG(total),2) avg_customer_spent
FROM
(SELECT 
c.customer_id,
district,
SUM(amount) total
FROM payment p
INNER JOIN customer c
ON c.customer_id=p.customer_id
INNER JOIN address a
ON c.address_id=a.address_id
GROUP BY district, c.customer_id) sub
GROUP BY district
ORDER BY 2 DESC


13.Task: Create a list that shows all payments including the payment_id, amount and the 
film category (name) plus the total amount that was made in this category. Order the results 
ascendingly by the category (name) and as second order criterion by the payment_id ascendingly.

Question: What is the total revenue of the category 'Action' and what is the lowest payment_id in that category 'Action'?
Answer: Total revenue in the category 'Action' is 4375.85 and the lowest payment_id in that category is 16055.

SELECT
title,
amount,
name,
payment_id,
(SELECT SUM(amount) FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c1
ON c1.category_id=fc.category_id
WHERE c1.name=c.name)
FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c
ON c.category_id=fc.category_id
ORDER BY name

14.Task: Create a list with the top overall revenue of a film title (sum of amount per title) for each category (name).

Question: Which is the top performing film in the animation category?
Answer: DOGMA FAMILY with 178.70.

SELECT
title,
name,
SUM(amount) as total
FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c
ON c.category_id=fc.category_id
GROUP BY name,title
HAVING SUM(amount) =     (SELECT MAX(total)
			  FROM 
                                (SELECT
			          title,
                                  name,
			          SUM(amount) as total
			          FROM payment p
			          LEFT JOIN rental r
			          ON r.rental_id=p.rental_id
			          LEFT JOIN inventory i
			          ON i.inventory_id=r.inventory_id
				  LEFT JOIN film f
				  ON f.film_id=i.film_id
				  LEFT JOIN film_category fc
				  ON fc.film_id=f.film_id
				  LEFT JOIN category c1
				  ON c1.category_id=fc.category_id
				  GROUP BY name,title) sub
			   WHERE c.name=sub.name)

                           
