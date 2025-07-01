-- 1. Find actors first and last name, whose last name starts with MO.

SELECT
	first_name, 
	last_name
FROM 
	actor
WHERE 
	last_name LIKE 'MO%';

-- Output:
-- PENELOPE	MONROE
-- LISA	MONROE
-- GRACE	MOSTEL
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


-- 4. List the last names of actors, as well as how many actors have that last name.

SELECT 
    last_name,
    COUNT(last_name) AS actors_count
FROM 
    actor
GROUP BY 
    last_name
ORDER BY 
    actors_count DESC,
    last_name ASC;

-- Output: 
-- KILMER	5
-- NOLTE	4
-- TEMPLE	4
-- AKROYD	3
-- ALLEN	3


-- 5. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

SELECT
	last_name, 
	COUNT(last_name) AS actors_count 
FROM 
	actor  
GROUP BY 
	last_name 
HAVING 
	COUNT(last_name) > 2
ORDER BY
	actors_count DESC;

-- Output:
-- AKROYD		3
-- ALLEN		3
-- BERRY		3
-- DAVIS		3
-- DEGENERES	3


-- 6. Find the number of films per month, rented to a customer by the staff member Mike Hillyer in 2005.

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
	MONTH(r.rental_date)
ORDER BY 
	rental_month; 

-- Output:
-- 5	558
-- 6	1163
-- 7	3342
-- 8	2892


-- 7. List each film and its actor count.

SELECT 
    f.title,
    COUNT(fa.actor_id) AS actors_count
FROM 
    film AS f
INNER JOIN 
    film_actor AS fa ON f.film_id = fa.film_id
GROUP BY 
    f.title
ORDER BY 
    actors_count DESC,
    f.title;

-- Output:
-- LAMBS CINCINATTI		15
-- BOONDOCK BALLROOM	13
-- CHITTY 		LOCK	13
-- CRAZY 		HOME	13
-- DRACULA 	CRYSTAL		13


-- 8: Find the films title, rental date, rental rate and replacement cost that are rented by inactive customers that live in the country “Virgin Islands, U.S.”.

SELECT 
    f.title AS film_title,
    r.rental_date,
    f.rental_rate,
    f.replacement_cost,
    co.country
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


-- 9: Find the number of unique customers that returned a film in 9 days or more

SELECT 
	COUNT(DISTINCT r.customer_id) AS unique_customers
FROM 
	rental AS r
WHERE 
	DATEDIFF(r.return_date, r.rental_date) >= 9
  	AND r.return_date IS NOT NULL; -- Only count completed returns
  	
-- Output: 
-- 567
 	
  	
-- 10a. Use subqueries to display all actors who appear in the film Alone Trip.
  	
SELECT 
    a.first_name, 
    a.last_name 
FROM 
    actor AS a
WHERE 
    a.actor_id IN (
        SELECT 
            fa.actor_id 
        FROM 
            film_actor AS fa
        WHERE 
            fa.film_id = (
                SELECT 
                    f.film_id 
                FROM 
                    film AS f 
                WHERE 
                    f.title = 'Alone Trip'
            )
    )
ORDER BY 
    a.last_name, 
    a.first_name;

-- 10b. Now, instead of using subqueries, use INNER JOIN to display all actors who appear in the film Alone Trip.

SELECT 
    a.first_name, 
    a.last_name 
FROM 
    actor AS a
INNER JOIN 
    film_actor AS fa ON a.actor_id = fa.actor_id
INNER JOIN 
    film AS f ON fa.film_id = f.film_id
WHERE 
    f.title = 'Alone Trip'
ORDER BY 
    a.last_name, 
    a.first_name;

-- Output:
-- RENEE		BALL
-- KARL			BERRY
-- LAURENCE		BULLOCK
-- ED			CHASE
-- CHRIS		DEPP


-- 11: You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 

SELECT 
    cu.last_name,
    cu.first_name,
    COALESCE(cu.email, 'No Email Available') AS email
FROM 
    customer AS cu
INNER JOIN 
    address AS a
    ON cu.address_id = a.address_id
INNER JOIN 
    city AS ci
    ON a.city_id = ci.city_id
INNER JOIN 
    country AS co
    ON ci.country_id = co.country_id
WHERE 
    co.country = 'Canada'
ORDER BY
	last_name;

-- Output:
-- BOURQUE		DERRICK	DERRICK.BOURQUE@sakilacustomer.org
-- CARPENTER	LORETTA	LORETTA.CARPENTER@sakilacustomer.org
-- IRBY			CURTIS	CURTIS.IRBY@sakilacustomer.org
-- POWER		DARRELL	DARRELL.POWER@sakilacustomer.org
-- QUIGLEY		TROY	TROY.QUIGLEY@sakilacustomer.org
  	

-- 12: Write a query to display how much business, in dollars, each store brought in.

SELECT 
    s.store_id,
    c.city AS store_name,
    COALESCE(CONCAT('$', FORMAT(SUM(p.amount), 2)), '$0') AS total_business
FROM 
    store AS s
INNER JOIN 
    staff ON s.store_id = staff.store_id
INNER JOIN 
    payment AS p ON staff.staff_id = p.staff_id
INNER JOIN 
    address AS a ON s.address_id = a.address_id
INNER JOIN 
    city AS c
    ON a.city_id = c.city_id
GROUP BY 
    s.store_id, 
    c.city
ORDER BY 
    s.store_id;

-- Output:
-- 1	Lethbridge	$33,482.50
-- 2	Woodridge	$33,924.06


-- 13: Find the total length of the unique films rented by customers whose first name starts with G and the returned date happened in the first 6 months of 2005.

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

-- Output:
-- 10139


-- 14: Total number of rentals and amount per store, city, and film category by month in 2005

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

-- Output: (LIMIT 5)
-- 05	1	Lethbridge	Action	    40	179.60
-- 05	1	Lethbridge	Animation	34	141.66
-- 05	1	Lethbridge	Children	36	155.64
-- 05	1	Lethbridge	Classics	29	101.71
-- 05	1	Lethbridge	Comedy	    37	140.63


-- 15: Find the most rented movie in each category.

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


-- 16: Write a query to show daily, weekly, and monthly active users. Make the assumption that the current date is 2005-08-30. 

-- 1. Daily (1-30 August)
SELECT 
    DATE(rental_date) AS period_date,
    COUNT(*) AS rental_count,
    COUNT(DISTINCT customer_id) AS active_users,
    'daily' AS period_type,
    NULL AS week_info
FROM 
    rental
WHERE 
    DATE(rental_date) BETWEEN '2005-08-01' AND '2005-08-30'
GROUP BY 
    DATE(rental_date)
UNION ALL
-- 2. Weekly
SELECT 
    NULL AS period_date,
    COUNT(r.rental_id) AS rental_count,
    COUNT(DISTINCT r.customer_id) AS active_users,
    'weekly' AS period_type,
    CONCAT('Week ', w.week_num) AS week_info
FROM 
    (SELECT 1 AS week_num UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) w
LEFT JOIN 
    rental AS r ON 
        w.week_num = WEEK(r.rental_date, 3) - 30 AND
        DATE(r.rental_date) BETWEEN '2005-08-01' AND '2005-08-30'
LEFT JOIN
    customer AS c ON r.customer_id = c.customer_id
WHERE
    c.customer_id IS NOT NULL OR r.rental_id IS NULL 
GROUP BY 
    w.week_num
UNION ALL
-- 3. Monthly (August 1-30)
SELECT 
    NULL AS period_date,
    COUNT(*) AS rental_count,
    COUNT(DISTINCT customer_id) AS active_users,
    'monthly' AS period_type,
    'Full Month' AS week_info
FROM 
    rental
WHERE 
    DATE(rental_date) BETWEEN '2005-08-01' AND '2005-08-30'
ORDER BY 
    CASE period_type
        WHEN 'daily' THEN 1
        WHEN 'weekly' THEN 2
        ELSE 3
    END,
    period_date;


-- 17: Calculate the cumulative Payment Amount per Customer and Payment Date.

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


-- 18: Rank top 100 customers based on their total revenue. (Make use of window functions)

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

-- Output: 
-- 526	221.55	1
-- 148	216.54	2
-- 144	195.58	3
-- 137	194.61	4
-- 178	194.61	4


-- 19: Find the most popular actor by each Category, based on the number of times their movies are rented. (Make use of CTEs)

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

-- Output: (LIMIT 5)
-- Action	NATALIE HOPKINS	122
-- Animation	JAYNE NOLTE	133
-- Children	HELEN VOIGHT	97
-- Classics	DARYL CRAWFORD	86
-- Comedy CHRISTIAN AKROYD	87


-- 20: What are the top 3 most rented film categories per store in 2005, based on rental count, revenue, and unique customers?

WITH StoreCategoryPerformance AS (
    SELECT 
        s.store_id,
        ci.city AS store_city, 
        c.name AS category_name,
        COUNT(r.rental_id) AS rental_count,
        SUM(p.amount) AS total_revenue,
        COUNT(DISTINCT r.customer_id) AS unique_customers,
        RANK() OVER (PARTITION BY s.store_id ORDER BY COUNT(r.rental_id) DESC) AS category_rank
    FROM 
        rental AS r
    INNER JOIN 
        payment AS p ON r.rental_id = p.rental_id
    INNER JOIN 
        inventory AS i ON r.inventory_id = i.inventory_id
    INNER JOIN 
        store AS s ON i.store_id = s.store_id
    INNER JOIN 
        address AS a ON s.address_id = a.address_id
    INNER JOIN 
        city AS ci ON a.city_id = ci.city_id  
    INNER JOIN 
        film_category AS fc ON i.film_id = fc.film_id
    INNER JOIN 
        category AS c ON fc.category_id = c.category_id
    WHERE 
        YEAR(r.rental_date) = 2005
    GROUP BY 
        s.store_id, 
        ci.city, 
        c.category_id
)
SELECT 
    store_id,
    store_city,
    category_name,
    rental_count,
    CONCAT('$', FORMAT(total_revenue, 2)) AS revenue,
    unique_customers
FROM 
    StoreCategoryPerformance
WHERE 
    category_rank <= 3
ORDER BY 
    store_id,
    category_rank;

-- Output: 
-- 1	Lethbridge	Action		587	$2,317.13	381
-- 1	Lethbridge	Drama		573	$2,560.27	367
-- 1	Lethbridge	Animation	556	$2,258.44	355
-- 2	Woodridge	Sports		616	$2,798.84	388
-- 2	Woodridge	Documentary	599	$2,348.01	378
-- 2	Woodridge	Animation	589	$2,331.11	357


-- 21. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT 
    c.name AS genre,
    CONCAT('$', FORMAT(SUM(p.amount), 2)) AS gross_revenue
FROM 
    category AS c
INNER JOIN 
    film_category AS fc ON c.category_id = fc.category_id
INNER JOIN 
    inventory AS i ON fc.film_id = i.film_id
INNER JOIN 
    rental AS r ON i.inventory_id = r.inventory_id
INNER JOIN 
    payment AS p ON r.rental_id = p.rental_id
GROUP BY 
    c.name
ORDER BY 
    SUM(p.amount) DESC
LIMIT 5;

-- Output:
-- Sports	 $5,314.21
-- Sci-Fi	 $4,756.98
-- Animation $4,656.30
-- Drama	 $4,587.39
-- Comedy	 $4,383.58


-- 22: Find the top 10 customers with the most late returns (films returned after rental duration).

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(*) AS total_late_returns,
    MAX(DATEDIFF(r.return_date, r.rental_date) - f.rental_duration) AS max_days_late -- Calculates the single worst late return case (in days)
FROM 
    rental AS r
INNER JOIN 
    customer AS c ON r.customer_id = c.customer_id
INNER JOIN 
    inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN 
    film AS f ON i.film_id = f.film_id
WHERE 
    r.return_date IS NOT NULL
    AND DATEDIFF(r.return_date, r.rental_date) > f.rental_duration
GROUP BY 
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY 
    total_late_returns DESC,
    max_days_late DESC
LIMIT 10;

-- Ouput:
-- 526	KARL SEAL		25	6
-- 469	WESLEY BULL		24	6
-- 295	DAISY BATES		24	5
-- 148	ELEANOR HUNT	23	6
-- 176	JUNE CARROLL	22	6