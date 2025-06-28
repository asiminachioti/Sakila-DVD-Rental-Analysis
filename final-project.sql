-- 1. Find Actors first and last name, whose last name starts with MO.

SELECT
	first_name, 
	last_name
FROM 
	actor
WHERE 
	last_name LIKE 'MO%';

-- Output:
-- PENELOPE MONROE
-- LISA	MONROE
-- GRACE MOSTEL
-- JIM	MOSTEL


-- 2. Find staffs email living in city Lethbridge.

SELECT 
	s.email AS StaffsEmail
FROM 
	staff AS s
INNER JOIN 
	address as a ON s.address_id = a.address_id
INNER JOIN 
	city as c ON a.city_id = c.city_id
WHERE 
	c.city = 'Lethbridge';

-- Ouput:
-- Mike.Hillyer@sakilastaff.com


-- 3. Find the number of rentals returned the same day.

SELECT 
	COUNT(*) AS returned_within_24h
FROM 
	rental 
WHERE 
	DATE(rental_date) = DATE(return_date);

-- Ouput: 
-- 105


-- 4. Find the number of films per month, rented to a customer by the staff member Mike Hillyer in 2005.

SELECT
	MONTH(r.rental_date) AS rental_month,
	COUNT(*) AS films_rented
FROM 
	rental AS r
INNER JOIN
	staff AS s ON r.staff_id = s.staff_id
WHERE 
	YEAR(r.rental_date) = 2005
	AND s.first_name = 'Mike'
	AND s.last_name = 'Hillyer'
GROUP BY 
	MONTH(r.rental_date) -- Group results by month to get monthly rental counts
ORDER BY 
	rental_month; 

-- Ouput:
-- 5	558
-- 6	1163
-- 7	3342
-- 8	2892


-- 5: Find the films title, rental date, rental rate and replacement cost that are rented by inactive customers that live in the country “Virgin Islands, U.S.”.

SELECT 
    f.title AS film_title,
    r.rental_date,
    f.rental_rate,
    f.replacement_cost
FROM
    rental AS r
INNER JOIN 
    inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN 
    film AS f ON i.film_id = f.film_id
    
INNER JOIN 
    customer AS cu ON r.customer_id = cu.customer_id
INNER JOIN 
    address AS a ON cu.address_id = a.address_id
INNER JOIN	 
    city AS ci ON a.city_id = ci.city_id 
INNER JOIN 
    country AS co ON ci.country_id = co.country_id
WHERE 
    cu.active = 0
    AND co.country = 'Virgin Islands, U.S.'
ORDER BY 
	r.rental_date DESC;

-- Output: (LIMIT 5)
-- CAPER MOTIONS	2005-08-21 17:45:52	0.99	22.99
-- WASTELAND DIVINE	2005-08-21 11:20:21	2.99	18.99
-- BIKINI BORROWERS	2005-08-21 03:57:15	4.99	26.99
-- SOMETHING DUCK	2005-08-18 13:17:30	4.99	17.99
-- STRANGER STRANGERS 2005-08-17 03:22:10 4.99	12.99


-- 6: Find the number of unique customers that returned a film in 9 days or more

SELECT 
	COUNT(DISTINCT r.customer_id) AS unique_customers
FROM 
	rental AS r
WHERE 
	DATEDIFF(r.return_date, r.rental_date) >= 9
  	AND r.return_date IS NOT NULL; -- Only count completed returns
  	
-- Output: 
-- 567
 	
 	
-- 7: Find the total length of the unique films rented by customers whose first name starts with G and the returned date happened in the first 6 months of 2005.

SELECT 
    SUM(DISTINCT f.length) AS total_unique_film_length
FROM 
    rental AS r 
INNER JOIN 
    inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN 
    film AS f ON i.film_id = f.film_id
INNER JOIN
    customer AS c ON r.customer_id = c.customer_id
WHERE
    c.first_name LIKE 'G%'
    AND r.return_date BETWEEN '2005-01-01' AND '2005-06-30';

-- Ouput:
-- 10139


-- 8: Total number of rentals and amount per store, city, and film category by month in 2005

SELECT 
    DATE_FORMAT(r.rental_date, '%m') AS rental_month, 
    s.store_id,
    ci.city,
    cat.name AS category,
    COUNT(*) AS total_rentals,
    SUM(p.amount) AS total_amount
FROM 
    rental AS r  -- Base table
-- Join with payment to get amounts
INNER JOIN payment AS p 
    ON r.rental_id = p.rental_id 
-- Joins to get film category information
INNER JOIN inventory AS i 
    ON r.inventory_id = i.inventory_id 
INNER JOIN film AS f 
    ON i.film_id = f.film_id
INNER JOIN film_category AS fc 
    ON f.film_id = fc.film_id
INNER JOIN category cat 
    ON fc.category_id = cat.category_id
-- Joins to get store information
INNER JOIN staff AS st 
    ON r.staff_id = st.staff_id
INNER JOIN store AS s 
    ON st.store_id = s.store_id 
-- Joins to get city information
INNER JOIN address AS a 
    ON s.address_id = a.address_id
INNER JOIN city AS ci 
    ON a.city_id = ci.city_id
WHERE 
    YEAR(r.rental_date) = 2005  
    AND r.rental_date IS NOT NULL  
GROUP BY 
    rental_month, s.store_id, ci.city, cat.name
ORDER BY
	rental_month, s.store_id, ci.city, cat.name;

-- Ouput: (LIMIT 5)
-- 05	1	Lethbridge	Action	    40	179.60
-- 05	1	Lethbridge	Animation	34	141.66
-- 05	1	Lethbridge	Children	36	155.64
-- 05	1	Lethbridge	Classics	29	101.71
-- 05	1	Lethbridge	Comedy	    37	140.63


-- 9: Find the most rented movie in each category.

SELECT 
    c.name AS category_name,
    f.title AS film_title,
    COUNT(*) AS rental_count
FROM 
    rental AS r
INNER JOIN 
    inventory i ON r.inventory_id = i.inventory_id
INNER JOIN 
    film f ON i.film_id = f.film_id
INNER JOIN 
    film_category fc ON f.film_id = fc.film_id
INNER JOIN 
    category c ON fc.category_id = c.category_id
GROUP BY 
    c.name, f.title, fc.category_id  
HAVING 
    COUNT(*) = (
        SELECT 
        	COUNT(*)
        FROM rental AS r2
        INNER JOIN 
        	inventory i2 ON r2.inventory_id = i2.inventory_id
        INNER JOIN 
        	film f2 ON i2.film_id = f2.film_id
        INNER JOIN 
        	film_category fc2 ON f2.film_id = fc2.film_id
        WHERE 
        	fc2.category_id = fc.category_id 
        GROUP BY f2.title
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )
ORDER BY 
    c.name;

-- Output:
-- Action	RUGRATS SHAKESPEARE	30
-- Action	SUSPECTS QUILLS	    30
-- Animation	JUGGLER HARDLY	32
-- Children	ROBBERS JOON	    31
-- Classics	TIMBERLAND SKY   	31


-- 10: Write a query to show daily, weekly, and monthly active users. Make the assumption that the current date is 2005-08-30. 

SELECT 
	'Daily' AS period, 
	COUNT(DISTINCT customer_id) AS active_users
FROM 
	rental 
WHERE 
	DATE(rental_date) = '2005-08-30'
UNION ALL  
SELECT 
	'Weekly', 
	COUNT(DISTINCT customer_id) AS active_users
FROM 
	rental
WHERE 
	rental_date BETWEEN '2005-08-24' AND '2005-08-30' -- αν βάλω 2005-08-23 τότε παίρνω ouput 374. δεν ειμαι σιγουρη για το ποια ημερομηνια βαζω αρχικη 
UNION ALL
SELECT 
	'Monthly', 
	COUNT(DISTINCT customer_id) AS active_users
FROM 
	rental
WHERE 
    DATE(rental_date) BETWEEN '2005-08-01' AND '2005-08-30';

-- Ouput:
-- Daily	0
-- Weekly	0
-- Monthly	599


-- 11: Calculate the cumulative Payment Amount per Customer and Payment Date.

SELECT 
    p1.customer_id,
    p1.payment_date,
    p1.amount,
    (
        SELECT SUM(p2.amount)
        FROM payment AS p2
        WHERE p2.customer_id = p1.customer_id
          AND p2.payment_date <= p1.payment_date
    ) AS cumulative_amount
FROM 
    payment AS p1
ORDER BY 
    p1.customer_id, 
    p1.payment_date;

-- Output: 
-- 1	2005-05-25 11:30:37	2.99	2.99
-- 1	2005-05-28 10:35:23	0.99	3.98
-- 1	2005-06-15 00:54:12	5.99	9.97
-- 1	2005-06-15 18:02:53	0.99	10.96
-- 1	2005-06-15 21:08:46	9.99	20.95


-- 12: Rank top 100 customers based on their total revenue. (Make use of window functions)

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    rd.total_revenue,
    RANK() OVER (ORDER BY rd.total_revenue DESC) AS revenue_rank
FROM (
    -- Subquery to calculate total revenue per customer
    SELECT 
        p.customer_id,
        SUM(p.amount) AS total_revenue
    FROM 
        payment AS p
    GROUP BY 
        p.customer_id
) AS rd
JOIN customer AS c ON rd.customer_id = c.customer_id
ORDER BY 
    revenue_rank
LIMIT 100;

-- Ouput: 
-- 526	221.55	1
-- 148	216.54	2
-- 144	195.58	3
-- 137	194.61	4
-- 178	194.61	4


-- 13: Find the most popular actor by each Category, based on the number of times their movies are rented. (Make use of CTEs)

WITH ActorRentalsByCategory AS (
    SELECT 
        c.name AS category_name,
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        COUNT(*) AS rental_count,
        RANK() OVER (
            PARTITION BY c.name 
            ORDER BY COUNT(*) DESC
        ) AS actor_rank
    FROM 
        rental AS r
    INNER JOIN inventory AS i 
        ON r.inventory_id = i.inventory_id
    INNER JOIN film AS f 
        ON i.film_id = f.film_id
    INNER JOIN film_category AS fc 
        ON f.film_id = fc.film_id
    INNER JOIN category AS c 
        ON fc.category_id = c.category_id
    INNER JOIN film_actor AS fa 
        ON f.film_id = fa.film_id
    INNER JOIN actor AS a 
        ON fa.actor_id = a.actor_id
    GROUP BY 
        c.name, 
        a.actor_id, 
        a.first_name, 
        a.last_name
)
SELECT 
    category_name,
    actor_name,
    rental_count
FROM 
    ActorRentalsByCategory
WHERE 
    actor_rank = 1
ORDER BY 
    category_name;
/* Comedy appears twice because two actors have the same rental count in this category. */

-- Ouput: (LIMIT 5)
-- Action	NATALIE HOPKINS	122
-- Animation	JAYNE NOLTE	133
-- Children	HELEN VOIGHT	97
-- Classics	DARYL CRAWFORD	86
-- Comedy CHRISTIAN AKROYD	87
