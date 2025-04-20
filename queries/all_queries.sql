
-- ==========================================================================================================
-- 🎨 Query 1: Identify the museums which are open on both Sunday and Monday. Display museum name, city
-- ==========================================================================================================

    select distinct mu.name,mu.city from museum_hours mhr
    join museum mu on mu.museum_id=mhr.museum_id
    where mu.museum_id in (select museum_id from museum_hours
    						where day in ('Sunday','Monday')
    						Group by museum_id
                            having count(*)=2);
                        
-- ===============================================================================
-- 🎨 Query 2:  Fetch all the paintings which are not displayed on any museums?	
-- ===============================================================================

    select * from work
    where museum_id is null
    order by name;

-- =====================================================
-- 🏛️ Query 3: Are there museums without any paintings 
-- =====================================================

    select museum_id from museum 
    where museum_id not in ( 
    	select distinct museum_id from work
        where museum_id is not null
        );

-- ==========================================================================================
-- 💰 Query 4: How many paintings have an asking price of more than their regular price?
-- ==========================================================================================
    
    select count(*) from product_size
    where sale_price>regular_price;

-- ===============================================================================================
-- 💸 Query 5:  Identify the paintings whose asking price is less than 50% of its regular price
-- ===============================================================================================

    select p.work_id,w.name from product_size p
    Join work w on w.work_id=p.work_id
    where p.sale_price < p.regular_price/2;

-- =====================================================
-- 🖼️ Query 6: Which canva size costs the most?
-- =====================================================

    select c.size_id,max(sale_price) as saleprice_cost, max(regular_price) as regular_cost from  canvas_size c
    Join product_size p on c.size_id=p.size_id
    Group by c.size_id
    order by saleprice_cost desc
    limit 1;

-- =====================================================================================
-- 🏙️ Query 7: Identify the museums with invalid city information in the given dataset;
-- =====================================================================================

    select name,city from museum
    where city is null or trim(city)='' or city in ('N/A','Unknown','123');

-- ================================================================================
-- 📅 Query 8: Museum_Hours table has 1 invalid entry. Identify it and remove it
-- ================================================================================

    select * from museum_hours
    where museum_id is null Or 
     day is null or trim(day)=''
     Or open is null
     Or close is null;

-- ========================================================================================================
-- 🧠 Query 9:  Identify the museums which are open on both Sunday and Monday. Display museum name, city.
-- ========================================================================================================
 
    select subject,Count(*) as subject_count from subject 
    Group by subject
    Order by subject_count desc
    limit 10;

-- ==========================================================
-- 🕖 Query 10: How many museums are open every single day
-- ==========================================================
 
     select count(*) as no_of_museums from(
    	select museum_id, row_number() over(partition by museum_id order by museum_id) as opening_days from museum_hours 
    ) as x
    where x.opening_days=7;
    
    -- Or
    
    select Count(*) from (
    	select museum_id from museum_hours
    	group by museum_id
    	Having Count(distinct day)=7
    ) as x;

-- ==========================================================================================================================
-- 🖼️ Query 11: Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
-- ==========================================================================================================================

     select w.museum_id,m.name,Count(*) as no_of_paintings from work w
     Join museum m on m.museum_id=w.museum_id
     where w.museum_id is not null
     group by w.museum_id,m.name
     order by no_of_paintings desc 
     limit 5;

-- ==============================================================================================================================
-- 👨‍🎨 Query 12: Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
-- ==============================================================================================================================
 
     select a.artist_id,a.full_name,Count(*) as no_of_paintings from artist a 
     Join work w on w.artist_id=a.artist_id
     group by a.artist_id,a.full_name
     order by no_of_paintings desc
     limit 5;

-- ========================================================
-- 📏 Query 13:  Display the 3 least popular canva sizes
-- ========================================================
 
    select c.size_id,Count(p.work_id) as no_of_paintings  from canvas_size c 
    Left Join product_size p on p.size_id=c.size_id
    group by c.size_id 
    Order by no_of_paintings 
    limit 3;

-- ========================================================================================================================
-- ⏰ Query 14: Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day
-- ========================================================================================================================

    SELECT m.name,m.state,
    mh.day,
      Cast(TIMESTAMPDIFF(
        MINUTE,
        STR_TO_DATE(mh.open, '%h:%i:%p'),
        STR_TO_DATE(mh.close, '%h:%i:%p')
      ) / 60 AS decimal(5,2)) as opening_hours
    FROM museum_hours mh
    Join museum m on m.museum_id=mh.museum_id
    order by opening_hours desc 
    limit 1;

-- =============================================================================
-- 🎨 Query 15:  Which museum has the most no of most popular painting style?
-- =============================================================================

    select w.museum_id,m.name,Count(*) as no_of_painting_style from work w 
    Join museum m on m.museum_id=w.museum_id
    where w.style=(
    	select style 
        from work 
        where style is not null
        Group by style 
        order by Count(*) desc 
        limit 1 
        )
    Group by w.museum_id,m.name
    Order by no_of_painting_style desc;

-- ========================================================================================
-- 🌍 Query 16: Identify the artists whose paintings are displayed in multiple countries
-- ========================================================================================

    select a.artist_id,a.full_name,Count(distinct m.country) as countries from artist a 
    Join work w on a.artist_id=w.artist_id 
    Join museum m on m.museum_id=w.museum_id
    Group by a.artist_id,a.full_name
    having countries>1 
    Order by countries desc;

-- =======================================================================================================================================================================
-- 💎 Query 17: Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, 
-- museum name, museum city and canvas labe
-- =======================================================================================================================================================================
 
    (select a.full_name,
    p.sale_price,
    w.name,
    m.name,
    m.city,
    c.size_id from artist a 
    Join work w on w.artist_id=a.artist_id
    Join product_size p on p.work_id=w.work_id
    Join museum m on m.museum_id=w.museum_id
    Join canvas_size c on p.size_id=c.size_id
    Order by p.sale_price desc 
    limit 1
    )
    
    Union 
    
    (select a.full_name,
    p.sale_price,
    w.name,
    m.name,
    m.city,
    c.size_id from artist a 
    Join work w on w.artist_id=a.artist_id
    Join product_size p on p.work_id=w.work_id
    Join museum m on m.museum_id=w.museum_id
    Join canvas_size c on p.size_id=c.size_id
    Order by p.sale_price 
    limit 1 
    );

-- ===================================================================
-- 🌐 Query 18:  Which country has the 5th highest no of paintings?
-- ===================================================================

    select country from (
    	select m.country as country, Count(*) as no_of_paintings from museum m 
    	Join work w on w.museum_id=m.museum_id
    	group by 1
    	Order by no_of_paintings desc 
    	limit 5
    ) as x 
    Order by x.no_of_paintings 
    limit 1;
    
    -- Or
    
    select m.country as country, Count(*) as no_of_paintings from museum m 
    Join work w on w.museum_id=m.museum_id
    group by 1
    Order by no_of_paintings desc 
    limit 1 offset 4;

-- ==============================================================================================
-- 🎭 Query 19:hich artist has the most no of Portraits paintings outside USA?. Display artist 
-- name, no of paintings and the artist nationality 
-- ==============================================================================================

    select a.full_name, Count(*) as no_of_portraits, m.country from artist a 
    Join work w on w.artist_id=a.artist_id
    Join subject s on s.work_id=w.work_id
    Join museum m on m.museum_id=w.museum_id
    where s.subject='Portraits' and m.country !='USA'
    Group by 1
    Order by 2 desc 
    limit 1;

-- ===============================================================================
-- 🎨 Query 20:  Which are the 3 most popular and 3 least popular painting styles
-- ===============================================================================

    (select w.style  from work w 
    where style is not null 
    group by 1 
    order by count(*) desc
    limit 3) 
    Union All
    (select w.style  from work w 
    where style is not null 
    group by 1 
    order by count(*) ASC
    limit 3);
    
    -- Or
    WITH style_counts AS (
        SELECT 
            style,
            COUNT(*) AS total,
            ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS top_rank,
            ROW_NUMBER() OVER (ORDER BY COUNT(*) ASC) AS bottom_rank
        FROM work
        WHERE style IS NOT NULL
        GROUP BY style
    )
    SELECT style, total, 'Top' AS category
    FROM style_counts
    WHERE top_rank <= 3
    
    UNION ALL
    
    SELECT style, total, 'Bottom' AS category
    FROM style_counts
    WHERE bottom_rank <= 3;
    
    
    
    
    
