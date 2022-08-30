-- Preparing a preliminary report
-- Focusin on the development of music industry
-- Database: albums

SELECT *
FROM albums
WHERE album_name IS NULL;

SELECT
SUM(
		CASE
			WHEN album_name IS NULL THEN 1
            ELSE 0
		END) AS count_nulls
FROM albums;

SELECT *
FROM record_labels;

SELECT *
FROM albums;

SELECT 
	CASE 
		WHEN 
			(SELECT
				COUNT(record_label_id)
			FROM albums 
			WHERE record_label_id = 13) 
			=
			(
			SELECT 
				total_no_artists
			FROM record_labels 
			WHERE record_label_id = 13)
		THEN "equal" 
        ELSE "not equal"
	END AS result;
    
SELECT
	sa.record_label_id,
	sa.albums_no_artists,
    srl.total_no_artists,
    CASE
		WHEN albums_no_artists = total_no_artists THEN "equal"
        ELSE "not equal"
	END AS coincidence
FROM 
	(SELECT 
		record_label_id,
        COUNT(record_label_id) AS albums_no_artists
	FROM albums
	GROUP BY record_label_id
    ) sa
    JOIN 
    (SELECT
		record_label_id,
        total_no_artists
	FROM record_labels 
    ) srl
    ON sa.record_label_id = srl.record_label_id;
;
    
SELECT *
FROM albums;
SELECT *
FROM artists;

SELECT
	#art.*,
    SUM(CASE 
		/*WHEN alb.release_date BETWEEN art.record_label_contract_start_date AND art.record_label_contract_end_date
        THEN "valid" ELSE "invalid"*/
        WHEN alb.release_date BETWEEN art.record_label_contract_start_date AND art.record_label_contract_end_date
        THEN "0" ELSE "1"
	END) AS validity
FROM
	artists art
    JOIN 
    albums alb ON art.artist_id=alb.artist_id
WHERE
	art.record_label_contract_start_date IS NOT NULL AND
    art.record_label_contract_end_date IS NOT NULL;
   
SELECT 
	record_label_id,
    COUNT(*)
FROM albums
WHERE
	record_label_id IS NOT NULL
GROUP BY record_label_id
ORDER BY record_label_id;

SELECT *
FROM albums;

SELECT 
	COUNT(DISTINCT(artist_id))
FROM
	albums
WHERE genre_id IN ("g03","g07","g12") AND
		release_date BETWEEN "1997-01-01" AND "2004-12-31"
ORDER BY artist_id
;
	
-- TRUNCATE remove all data from a table, whereas DELETE allows you to specify what 
-- data to remove

SELECT *
FROM artists
WHERE (timestampdiff(YEAR, record_label_contract_start_date,record_label_contract_end_date)>10) AND (no_weeks_top_100 > 15);

select * from  artists;
select * from albums;
SELECT * FROM genre;

SELECT a.artist_id, a.artist_first_name, a.artist_last_name, g.genre_name
FROM  artists a 
RIGHT JOIN albums al ON a.artist_id=al.artist_id
JOIN genre g ON al.genre_id=g.genre_id
WHERE a.artist_first_name="Keala" AND a.artist_last_name="Thompson"
GROUP BY a.artist_first_name, artist_last_name, g.genre_name
HAVING COUNT(DISTINCT(al.genre_id))>0;
    
#PREGUNTA 18
SELECT a.artist_id, a.artist_first_name, a.artist_last_name, start_date_ind_artist
FROM (
		SELECT MAX(start_date_ind_artist) as start_date_ind_artist
        FROM artists
        ) aa
        JOIN artists a ON a.start_date_ind_artist = MAX(aa.start_date_ind_artist)
WHERE dependency = 'independent artist'; 

DROP TRIGGER IF EXISTS trig_artist;
DELIMITER $$
CREATE TRIGGER trig_artist
BEFORE INSERT ON artists
FOR EACH ROW
BEGIN
	IF (YEAR(DATE(SYSDATE())) - YEAR(NEW.birth_date)<18)   THEN
    SET NEW.dependency = "Not professional"
    AND
    NEW.no_weeks_top_100 = 0;
    END IF;
END $$
DELIMITER ;
      
SELECT * FROM artists;

INSERT INTO artists
VALUES (1275, "John", "Johnson", "2009-01-18",4,10,"signed to a record label", "2014-2-2", "2018-5-14", NULL);

#PREGUNTA 23
DROP TABLE IF EXISTS artist_managers;
CREATE TABLE IF NOT EXISTS artist_manager(
	artist_id INTEGER NOT NULL,
    artist_first_name VARCHAR(30) NOT NULL,
    artist_last_name VARCHAR(30) NOT NULL,
    manager_id INTEGER NOT NULL
);

#ASSIGN ARTIST ID 1012 AS A MANAGER TO ID<1025
#ASSIGN ARTID ID 1022 AS A MANAGER TO ID >1250


SELECT A.*
FROM
	(SELECT 
		art.artist_id,
		artist_first_name,
		artist_last_name,
		(SELECT 
			artist_id
			FROM artists
			WHERE artist_id=1012) AS manager_id
	FROM artists as art
    JOIN albums as alb ON art.artist_id = alb.artist_id
	WHERE art.artist_id < 1025
	GROUP BY art.artist_id
	ORDER BY art.artist_id) AS A
UNION SELECT B.*
FROM
	(SELECT 
		art.artist_id,
		artist_first_name,
		artist_last_name,
		(SELECT 
			artist_id
			FROM artists
			WHERE artist_id=1022) AS manager_id
	FROM artists as art
    JOIN albums as alb ON art.artist_id = alb.artist_id
	WHERE art.artist_id > 1250
	GROUP BY art.artist_id
	ORDER BY art.artist_id) AS B
;

#Creating a view to add rows to other table
CREATE OR REPLACE VIEW v_manager AS
SELECT A.*
FROM
	(SELECT 
		art.artist_id,
		artist_first_name,
		artist_last_name,
		(SELECT 
			artist_id
			FROM artists
			WHERE artist_id=1012) AS manager_id
	FROM artists as art
    JOIN albums as alb ON art.artist_id = alb.artist_id
	WHERE art.artist_id < 1025
	GROUP BY art.artist_id
	ORDER BY art.artist_id) AS A
UNION SELECT B.*
FROM
	(SELECT 
		art.artist_id,
		artist_first_name,
		artist_last_name,
		(SELECT 
			artist_id
			FROM artists
			WHERE artist_id=1022) AS manager_id
	FROM artists as art
    JOIN albums as alb ON art.artist_id = alb.artist_id
	WHERE art.artist_id > 1250
	GROUP BY art.artist_id
	ORDER BY art.artist_id) AS B
;

INSERT INTO artist_manager (artist_id,artist_first_name,artist_last_name,manager_id)
SELECT *
FROM v_manager;

SELECT * FROM artist_manager;

DROP VIEW IF EXISTS v_manager;

SELECT COUNT(DISTINCT(artist_id))
FROM artist_manager;

SELECT * FROM artist_manager;

SELECT m1.*
FROM artist_manager m1
JOIN artist_manager m2 ON m1.artist_id = m2.manager_id
WHERE m2.manager_id IN(
						SELECT artist_id
                        FROM artist_manager
                        WHERE artist_id IN (1012,1022))
GROUP BY artist_id;

SELECT * FROM artists;

SELECT 
a.artist_first_name,
a.artist_last_name,
rl.record_label_name
FROM 
artists a
CROSS JOIN 
record_labels rl 
WHERE artist_id<1016;

SELECT * FROM record_labels;
SELECT * FROM  artists;
SELECT * FROM albums;

SELECT 
alb.artist_id,
artist_first_name, 
artist_last_name, 
no_weeks_top_100 
FROM artists art
JOIN albums alb ON art.artist_id=alb.artist_id
GROUP BY alb.artist_id
ORDER BY no_weeks_top_100 DESC;

SELECT
art.artist_id,
art.artist_first_name, 
art.artist_last_name, 
art.no_weeks_top_100
FROM artists art
WHERE art.artist_id in(SELECT
						alb.artist_id
                        FROM albums alb)
ORDER BY no_weeks_top_100 DESC;

SELECT COUNT(DISTINCT(artist_id))
FROM albums;

SELECT COUNT(DISTINCT(artist_id))
FROM artists;

DROP FUNCTION IF EXISTS f_avg_no_weeks_100;

DELIMITER $$
CREATE FUNCTION f_avg_no_weeks_100 (p_start_year INTEGER, p_end_year INTEGER) RETURNS DECIMAL(10,4)
DETERMINISTIC
BEGIN
	DECLARE v_avg_no_weeks_100 DECIMAL (10,4);
    
    SELECT
		AVG(no_weeks_top_100)
    INTO  v_avg_no_weeks_100
    FROM  artists
    WHERE YEAR(birth_date) BETWEEN p_start_year AND p_end_year;
    
    RETURN  v_avg_no_weeks_100;
END$$
DELIMITER ;

SELECT f_avg_no_weeks_100(1991,2000);

SELECT * FROM record_labels; 
SELECT * FROM genre;
SELECT * FROM albums;

DROP VIEW IF EXISTS v_artist_genres;

CREATE OR REPLACE VIEW v_album_multiple_genres AS
SELECT art.artist_id, COUNT(DISTINCT(alb.genre_id)) AS no_of_genres
FROM albums alb
JOIN artists art ON alb.artist_id=art.artist_id
GROUP BY art.artist_id
HAVING no_of_genres>1;


