/* 1. reward some user’s who have been with us for a long period of time */

SELECT * FROM users
ORDER BY created_at
LIMIT 5;

/* 2. Launch AD Campaign on day :  which day would be the best day to launch ADs. on that day most users registers */

SELECT Dayname(created_at) as day_week 
FROM users
GROUP BY day_week
ORDER BY COUNT(*)
LIMIT 2;

/*3. What is the average number of posts per user?
*/
SELECT COUNT(content_ID)/(SELECT COUNT(*) FROM users) AS 'Average number of post'
FROM content_post ;

/* The  users who neither comment nor like on any content
*/
SELECT t1.username from
(SELECT u.username, c.comment_text
FROM users u
LEFT JOIN comments c ON u.user_id = c.user_id
GROUP BY u.user_id , c.comment_text
HAVING comment_text IS NULL ) as t1
INNER JOIN 
(SELECT u.username ,content_id
FROM users u
LEFT JOIN likes l USING(user_id)
GROUP BY u.username,content_id
HAVING content_id IS NULL) AS t2
ON t1.username =t2.username;

/* Number of  users who never post any content .
*/
-- use filter users filtered the bots 

SELECT count(u.user_id) FROM filtered_users u
LEFT JOIN content_post c
USING(user_id)
WHERE content_id is NULL;

/* 3 check for bot in social media who likes every post */

SELECT user_id
FROM   likes
GROUP  BY user_id
HAVING COUNT(content_id)= (SELECT Count(content_id) FROM  content_post);

/* 4.  users who have the most follwers : most popular face of the social media  */

SELECT follower_id , username,COUNT(followee_id) as `no of followers`
FROM follows f join users u 
on f.follower_id = u.user_id
GROUP BY follower_id
ORDER BY COUNT(followee_id) DESC;


SELECT follower_id , username,COUNT(followee_id) as `no of followers`
FROM follows f join filtered_users u 
on f.follower_id = u.user_id
GROUP BY follower_id,username
ORDER BY COUNT(followee_id) DESC;

/* 5 most engage users , who likes and comments most  */

SELECT u.user_id,  COUNT(c.content_id) as 'no of comments'
FROM filtered_users u 
JOIN comments c
USING(user_id)
GROUP BY user_id
ORDER BY COUNT(c.content_id) DESC LIMIT 10;

SELECT u.user_id,  COUNT(l.content_id) as 'no of likes'
FROM filtered_users u 
JOIN likes l
USING(user_id)
GROUP BY user_id
ORDER BY COUNT(l.content_id) DESC LIMIT 10;

-- users afterfilterring all bots out

create table filtered_users as
select * from users
where user_id not in ( SELECT user_id
FROM   likes
GROUP  BY user_id
HAVING COUNT(content_id)= (SELECT Count(content_id) FROM  content_post));


/* 6. The number of photos posted by most active users*/

SELECT u.username AS 'Username',COUNT(p.content_id) AS 'Number of Posts'
FROM users u JOIN content_post p ON u.user_id = p.user_id
GROUP BY u.user_id
ORDER BY 2 DESC
LIMIT 5;

/*7. most used tags */

SELECT t2.tag_name, COUNT(*) AS total 
FROM post_tags t JOIN tags t2
USING(tag_id) 
GROUP  BY tag_name
ORDER  BY total DESC 
LIMIT  5; 

/* common interst */
-- form mutual followers 
SELECT distinct( PT1.tag_id) AS common_tag_id, T.tag_name AS common_tag_name
FROM follows AS F1
JOIN follows AS F2 ON F1.follower_id = F2.followee_id AND F1.followee_id = F2.follower_id
JOIN users AS U1 ON F1.follower_id = U1.user_id
JOIN users AS U2 ON F1.followee_id = U2.user_id
JOIN content_post AS UP1 ON F1.follower_id = UP1.user_id
JOIN content_post AS UP2 ON F1.followee_id = UP2.user_id
JOIN post_tags AS PT1 ON UP1.content_id = PT1.content_id
JOIN post_tags AS PT2 ON UP2.content_id = PT2.content_id
JOIN tags AS T ON PT1.tag_id = T.tag_id AND PT2.tag_id = T.tag_id
WHERE F1.follower_id < F1.followee_id ;


/* Who are the top 10 users with the highest number of likes on their posts? */
SELECT U.username AS user_username,COUNT(L.content_id) AS total_likes
FROM filtered_users AS U
JOIN content_post AS CP ON U.user_id = CP.user_id
LEFT JOIN likes AS L ON CP.content_id = L.content_id
GROUP BY U.username
ORDER BY total_likes DESC
LIMIT 10;

-- users nevercomment never likes 
SELECT 
    tableA.total_A AS 'Number Of Users who never commented',(tableA.total_A / (SELECT COUNT(*) FROM users u)) * 100 AS '%',
    tableB.total_B AS 'Number of Users who likes every photos',(tableB.total_B / (SELECT COUNT(*) FROM users u)) * 100 AS '%' FROM
    (SELECT COUNT(*) AS total_A
    FROM
	(SELECT u.username, c.comment_text
    FROM
	users u
    LEFT JOIN comments c ON u.user_id = c.user_id
    GROUP BY u.user_id , c.comment_text
    HAVING comment_text IS NULL) AS total_number_of_users_without_comments) AS tableA
        JOIN
    (SELECT COUNT(*) AS total_B
    FROM
	(SELECT 
    u.user_id, u.username, COUNT(u.user_id) AS total_likes_by_user
    FROM users u
    JOIN likes l ON u.user_id = l.user_id
    GROUP BY u.user_id , u.username
    HAVING total_likes_by_user = (SELECT COUNT(*)
        FROM photos p)) AS total_number_users_likes_every_photos) AS tableB;
            
            
/* What is the average number of likes and comments per post?
 */
 
            
-- Total number of comments by the users on the platform */

CREATE PROCEDURE `countUserComments`()
BEGIN 
SELECT 
COUNT(*)  as 'Total Number of Comments'
FROM (
    SELECT c.user_id, u.username
	FROM users u
	JOIN comments c ON u.user_id = c.user_id
    WHERE c.comment_text IS NOT NULL
    GROUP BY u.username , c.user_id) as t
END 

CALL`spUserComments`();



