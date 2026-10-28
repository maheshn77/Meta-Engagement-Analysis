/* =====================================================================
   SOCIAL MEDIA (IG CLONE) — STUDENT ANSWER TEMPLATE 
   ===================================================================== */

USE ig_clone;

/* =====================================================================
   OBJECTIVE QUESTIONS
   ===================================================================== */

-- O1.
-- Are there any tables with duplicate or missing null values? If so, how
-- would you handle them?

-- answer: * null checks (each query returns the offending rows; 0 rows = clean)
-- users
select id, username, created_at from users
where username is null or created_at is null;

-- photos 
select id, image_url, user_id, created_dat from photos
where image_url is null or user_id is null or created_dat is null;

-- comments
select id, comment_text, photo_id, user_id, created_at from comments
where comment_text is null or user_id is null or photo_id is null or created_at is null;

-- likes
select user_id, photo_id, created_at from likes
where user_id is null or photo_id is null or created_at is null;

-- follows
select follower_id, followee_id, created_at from follows
where follower_id is null or followee_id is null or created_at is null;

-- * duplicate checks (each query returns the offending rows; 0 rows = clean)
-- users
select username, count(*) as count from users
group by username having count(*) > 1;

-- photos
select image_url, user_id, count(*) as count from photos
group by image_url, user_id having count(*) > 1;

-- comments
select comment_text, user_id, photo_id, count(*) as count from comments
group by comment_text, user_id, photo_id having count(*) > 1;

-- likes
select user_id, photo_id, count(*) as count from likes
group by user_id, photo_id having count(*) > 1;

-- follows
select follower_id, followee_id, count(*) as count from follows
group by follower_id, followee_id having count(*) > 1;


-- O2.
-- What is the distribution of user activity levels (e.g., number of posts,
-- likes, comments) across the user base?

-- Answer:
WITH post_counts AS (
    SELECT user_id, COUNT(*) AS number_of_posts
    FROM photos
    GROUP BY user_id
),
like_counts AS (
    SELECT user_id, COUNT(*) AS number_of_likes
    FROM likes
    GROUP BY user_id
),
comment_counts AS (
    SELECT user_id, COUNT(*) AS number_of_comments
    FROM comments
    GROUP BY user_id
)
SELECT
    u.id as user_id,
    u.username,
    COALESCE(p.number_of_posts, 0) AS total_posts,
    COALESCE(l.number_of_likes, 0) AS total_likes_given,
    COALESCE(c.number_of_comments, 0) AS total_comments_made
FROM users u
LEFT JOIN post_counts p ON u.id = p.user_id
LEFT JOIN like_counts l ON u.id = l.user_id
LEFT JOIN comment_counts c ON u.id = c.user_id
ORDER BY u.id;

-- O3.
-- Calculate the average number of tags per post (photo_tags and photos
-- tables).

-- Answer: 
-- Average tags per post = 1.95 across all 257 photos (67 photos have no tags; among the 190 tagged photos the average is 2.64).
-- A left join includes photos with zero tags; Therefore, the average is calculated across all photos, not only photos that have tags.

with photo_tag_counts as (select 
p.id, 
count(pt.tag_id) as totl_tags
 from photos p 
left join photo_tags pt 
on p.id = pt.photo_id
group by p.id)
select  round(avg(totl_tags),2) as AverageTags from photo_tag_counts;


-- O4.
-- Identify the top users with the highest engagement rates (likes, comments)
-- on their posts and rank them.

-- Answer: 

with like_counts as (
    select photo_id, count(*) as total_likes from likes group by photo_id
),
comment_counts as (
    select photo_id, count(*) as total_comments from comments group by photo_id
),
eng as (
    select p.user_id, l.total_likes + c.total_comments as engagement
    from photos p
    join like_counts l    on l.photo_id = p.id
    join comment_counts c on c.photo_id = p.id
)
select user_id, sum(engagement) as total,
       rank() over (order by sum(engagement) desc) as rnk
from eng
group by user_id
order by rnk;


-- O5.
-- Which users have the highest number of followers and followings?

-- Answer: 

with followers as (select 
u.id as user_id, 
u.username, 
count(f.follower_id) as total_followers 
 from users u 
join follows f 
on u.id = f.followee_id
group by u.id, 
u.username)

, following as 
(select 
u.id as user_id, 
u.username, 
count(f.followee_id) as total_following 
 from users u 
join follows f 
on u.id = f.follower_id
group by u.id, 
u.username)

select u.id as user_id, u.username, 
coalesce(fr.total_followers,0) as Followers,
coalesce(fe.total_following,0) as Following
from users u 
left join followers fr 
on u.id = fr.user_id
left join following fe
on u.id = fe.user_id
order by Followers desc, Following desc;


-- O6.
-- Calculate the average engagement rate (likes, comments) per post for each
-- user.

-- Answer: 
-- Engagement per post = likes received + comments received. 
with like_counts as (
    select photo_id, count(*) as n from likes group by photo_id
),
comment_counts as (
    select photo_id, count(*) as n from comments group by photo_id
)
select u.id, u.username,
       round(avg(coalesce(l.n, 0) + coalesce(c.n, 0)), 2) as avg_engagement
from users u
join photos p on p.user_id = u.id
left join like_counts l    on l.photo_id = p.id
left join comment_counts c on c.photo_id = p.id
group by u.id, u.username
order by avg_engagement desc;


-- O7.
-- Get the list of users who have never liked any post (users and likes
-- tables)

-- Answer: 

select u.id, u.username
from users u
where not exists 
(select 1 from likes l where l.user_id = u.id)
;


-- O8.
-- How can you leverage user-generated content (posts, hashtags, photo tags)
-- to create more personalized and engaging ad campaigns?
  
-- Answer: 

with like_counts as (
select photo_id, count(*) as likes from likes group by photo_id
),
comment_counts as (
select photo_id, count(*) as comments from comments group by photo_id
)
select u.id as user_id,
u.username,
t.tag_name,
count(t.id) as tag_usage,
coalesce(sum(l.likes), 0)    as total_likes_received,
coalesce(sum(c.comments), 0) as total_comments_received,
coalesce(sum(l.likes), 0) + coalesce(sum(c.comments), 0) as total_engagement
from users u
left join photos p         
on p.user_id = u.id
left join photo_tags pt    
on pt.photo_id = p.id
left join tags t           
on t.id = pt.tag_id
left join like_counts l    
on l.photo_id = p.id
left join comment_counts c 
on c.photo_id = p.id
group by u.id, u.username, t.tag_name
order by total_engagement desc
;



-- O9.
-- Are there any correlations between user activity levels and specific
-- content types (e.g., photos, videos, reels)? How can this information
-- guide content creation and curation strategies?

-- Answer:
-- Correlations I calculated from this output
--  Pair	                                     --    Correlation
-- Total posts vs total engagement                    	0.998
-- Total likes vs total comments                     	0.992


With like_counts as (
    Select photo_id, COUNT(*) as likes
    FROM likes
    GROUP BY photo_id
),
comment_counts as (
    Select photo_id, COUNT(*) as comments
    FROM comments
    group by photo_id
)
Select p.user_id,
       COUNT(p.id) AS total_posts,
       COALESCE(SUM(l.likes), 0)    AS total_likes,
       COALESCE(SUM(c.comments), 0) AS total_comments,
       COALESCE(SUM(l.likes), 0) + COALESCE(SUM(c.comments), 0) AS total_engagement
from photos p
left join like_counts l    ON l.photo_id = p.id
left join comment_counts c ON c.photo_id = p.id
group by  p.user_id
order by  total_engagement desc;


-- O10.
-- Calculate the total number of likes, comments, and photo tags for each
-- user.

-- Answer:
with like_counts as (
    select p.user_id, count(*) as total_likes
    from photos p
    join likes l on l.photo_id = p.id
    group by p.user_id
),
comment_counts as (
    select p.user_id, count(*) as total_comments
    from photos p
    join comments c on c.photo_id = p.id
    group by p.user_id
),
tag_counts as (
    select p.user_id, count(*) as total_tags
    from photos p
    join photo_tags pt on pt.photo_id = p.id
    group by p.user_id
)
select
    u.id as user_id,
    u.username,
    coalesce(l.total_likes, 0) as total_likes,
    coalesce(c.total_comments, 0) as total_comments,
    coalesce(t.total_tags, 0) as total_tags
from users u
left join like_counts l on l.user_id = u.id
left join comment_counts c on c.user_id = u.id
left join tag_counts t on t.user_id = u.id
order by u.id;

-- O11.
-- Rank users based on their total engagement (likes, comments, shares) over a
-- month.

-- Answer:

with user_likes as (
    select user_id, count(*) as likes_given from likes
    group by user_id),
user_comments as (
    select user_id, count(*) as comments_made from comments 
    group by user_id),
user_engagement as (
    select u.id as user_id, u.username,
        coalesce(l.likes_given, 0) as likes_given,
        coalesce(c.comments_made, 0) as comments_made,
        coalesce(l.likes_given, 0) + coalesce(c.comments_made, 0) as total_engagement
    from users u
    left join user_likes l
        on u.id = l.user_id
    left join user_comments c
        on u.id = c.user_id )
select
    user_id, username, likes_given, comments_made, total_engagement,
    dense_rank() over ( order by total_engagement desc) as engagement_rank from user_engagement
order by engagement_rank, user_id;
 
 
-- O12.
-- Retrieve the hashtags that have been used in posts with the highest average
-- number of likes. Use a CTE to calculate the average likes for each
-- hashtag first.

with hashTAG as (
    select t.id as tag_id, t.tag_name,
        round(count(l.user_id) / count(distinct pt.photo_id), 2) as avg_likes_per_photo,
        count(l.user_id) as total_likes,
        count(distinct pt.photo_id) as total_photos
    from tags t
    join photo_tags pt on t.id = pt.tag_id
    left join likes l on pt.photo_id = l.photo_id
    group by t.id, t.tag_name
)
select 
tag_id, tag_name, avg_likes_per_photo, total_likes, total_photos
from hashTAG
order by avg_likes_per_photo desc
limit 10;

-- O13.
-- Retrieve the users who have started following someone after being followed
-- by that person.

-- Answer:

Select Distinct u.id, u.username
from users u
join follows f1 
on f1.follower_id = u.id            
join follows f2 
on f2.follower_id = f1.followee_id     
and f2.followee_id = f1.follower_id   
where f1.created_at >= f2.created_at                  
Order by u.id;
 
 

/* =====================================================================
   SUBJECTIVE QUESTIONS
   ===================================================================== */

-- S1.
-- Based on user engagement and activity levels, which users would you
-- consider the most loyal or valuable? How would you reward or incentivize
-- these users?


with like_given as (
    select user_id, count(*) as likes_given from likes group by user_id
),
comment_given as (
    select user_id, count(*) as comments_made from comments group by user_id
),
post_count as (
    select user_id, count(*) as posts from photos group by user_id
),
likes_on_photo as (
    select photo_id, count(*) as photo_likes from likes group by photo_id
),
comments_on_photo as (
    select photo_id, count(*) as photo_comments from comments group by photo_id
),
received as (
    select p.user_id,
           sum(coalesce(l.photo_likes, 0) + coalesce(c.photo_comments, 0)) as engagement_received,
           round(avg(coalesce(l.photo_likes, 0) + coalesce(c.photo_comments, 0)), 2) as avg_engagement_per_post
    from photos p
    left join likes_on_photo l    on l.photo_id = p.id
    left join comments_on_photo c on c.photo_id = p.id
    group by p.user_id
),
scored as (
    select u.id as user_id,
           u.username,
           coalesce(pc.posts, 0) as posts,
           coalesce(lg.likes_given, 0) as likes_given,
           coalesce(cg.comments_made, 0) as comments_made,
           coalesce(lg.likes_given, 0) + coalesce(cg.comments_made, 0) as reactions_given,
           coalesce(r.engagement_received, 0) as engagement_received,
           coalesce(r.avg_engagement_per_post, 0) as avg_engagement_per_post
    from users u
    left join post_count pc  on pc.user_id = u.id
    left join like_given lg  on lg.user_id = u.id
    left join comment_given cg on cg.user_id = u.id
    left join received r     on r.user_id = u.id
),
ranked as (
    select *,
           dense_rank() over (order by engagement_received desc) as creator_rank,
           dense_rank() over (order by reactions_given desc)     as participant_rank
    from scored
)
select user_id, username, posts, likes_given, comments_made,
       reactions_given, engagement_received, avg_engagement_per_post,
       creator_rank, participant_rank,
       case
           when creator_rank <= 10 and participant_rank = 1 then 'Top creator + loyal participant'
           when creator_rank <= 10 then 'Top creator'
           when participant_rank = 1 then 'Loyal participant'
           else 'Other'
       end as value_segment
from ranked
order by case when creator_rank <= 10 or participant_rank = 1 then 0 else 1 end,
         engagement_received desc, reactions_given desc
		;


-- S2.
-- For inactive users, what strategies would you recommend to re-engage them
-- and encourage them to start posting or engaging again?

select u.id as user_id, u.username, u.created_at,
       (select count(*) from photos   where user_id = u.id)    as posts,
       (select count(*) from likes    where user_id = u.id)  as likes_given,
       (select count(*) from comments where user_id = u.id)  as comments_made,
       (select count(*) from follows  where follower_id = u.id) as following,
       (select count(*) from follows  where followee_id = u.id)  as followers
from users u
where not exists (select 1 from likes    where user_id = u.id)
  and not exists (select 1 from comments where user_id = u.id)
order by posts, u.id;

with base as (
    select u.id,
           (select count(*) from follows  where follower_id = u.id) as following,
           (select count(*) from likes    where user_id = u.id)
         + (select count(*) from comments where user_id = u.id)     as reactions from users u )  
         
select case when following = 0 then 'follows nobody' else 'follows someone' end as follow_status,
       count(*) as users,
       sum(case when reactions > 0 then 1 else 0 end) as users_who_react from base
group by follow_status;

-- S3.
-- Which hashtags or content topics have the highest engagement rates? How can
-- this information guide content strategy and ad campaigns?

with like_counts as (
    select photo_id, count(*) as like_count from likes
    group by photo_id
),
comment_counts as (
    select photo_id, count(*) as comment_count from comments
    group by photo_id),
    
photo_engagement as (
    select p.id as photo_id, pt.tag_id,
        coalesce(l.like_count, 0) as likes,
        coalesce(c.comment_count, 0) as comments
    from photos p
    join photo_tags pt
        on p.id = pt.photo_id
    left join like_counts l
        on p.id = l.photo_id
    left join comment_counts c
        on p.id = c.photo_id)
select
    t.id as tag_id,
    t.tag_name,
    count(*) as tag_usage,
    sum(pe.likes) as total_likes,
    sum(pe.comments) as total_comments,
    sum(pe.likes + pe.comments) as total_engagement,
    round(avg(pe.likes + pe.comments), 2) as avg_engagement_per_photo
from photo_engagement pe
join tags t
    on t.id = pe.tag_id
group by t.id, t.tag_name
order by avg_engagement_per_photo desc;
 


-- S4.
-- Are there any patterns or trends in user engagement based on demographics
-- (age, location, gender) or posting times? How can these insights inform
-- targeted marketing campaigns?

with act as 
(select u.id,
        u.created_at,
        (select count(*)
         from photos
         where user_id = u.id) as posts,

        (select count(*)
         from likes
         where user_id = u.id)
        +
        (select count(*)
         from comments
         where user_id = u.id) as reactions_given,
        coalesce((select sum((select count(*) from likes
	     where photo_id = p.id)
                +
		(select count(*) from comments
		where photo_id = p.id))
            from photos p
            where p.user_id = u.id
        ), 0) as engagement_received from users u)
 
 select concat(year(created_at), '-Q', 
 quarter(created_at)) as signup_cohort, 
 count(*) as users,
    round(
        100.0 * sum(reactions_given > 0) / count(*), 1) as pct_who_react,
    round( 100.0 * sum(posts > 0) / count(*), 1) as pct_who_post,
    round(avg(reactions_given), 1) as avg_reactions_given,
    round(sum(engagement_received) / nullif(sum(posts), 0), 1) as avg_engagement_per_post
from act
group by signup_cohort
order by signup_cohort;



-- S5.
-- Based on follower counts and engagement rates, which users would be ideal
-- candidates for influencer marketing campaigns? How would you approach
-- and collaborate with these influencers?

with follower_count as (
    select f.followee_id as user_id,
           count(*) as total_followers
    from follows f
    group by f.followee_id
),
like_counts as (
    select photo_id, count(*) as like_count
    from likes
    group by photo_id
),
comment_counts as (
    select photo_id, count(*) as comment_count
    from comments
    group by photo_id
),
post_engagement as (
    select p.user_id,
           p.id as photo_id,
           coalesce(l.like_count, 0) as likes,
           coalesce(c.comment_count, 0) as comments
    from photos p
    left join like_counts l    on p.id = l.photo_id
    left join comment_counts c on p.id = c.photo_id
),
user_engagement as (
    select user_id,
           count(*) as total_posts,
           sum(likes) as total_likes,
           sum(comments) as total_comments,
           sum(likes + comments) as total_engagement,
           round(avg(likes + comments), 2) as avg_engagement_per_post
    from post_engagement
    group by user_id
)
select u.id as user_id,
       u.username,
       coalesce(f.total_followers, 0) as total_followers,
       e.total_posts,
       e.total_engagement,
       e.avg_engagement_per_post,
       (select count(*) from likes    where user_id = u.id)
     + (select count(*) from comments where user_id = u.id) as reactions_given
from users u
join user_engagement e     on u.id = e.user_id
left join follower_count f on f.user_id = u.id
where e.total_posts >= 3
order by e.avg_engagement_per_post desc, e.total_posts desc
;

-- S6.
-- Based on user behavior and engagement data, how would you segment the user
-- base for targeted marketing campaigns or personalized recommendations?

with activity as (
    select u.id as user_id, u.username,
(select count(*) from photos where user_id = u.id) as total_posts,
(select count(*) from likes where user_id = u.id) + (select count(*) from comments where user_id = u.id) as reactions_given
    from users u )
select user_id, username, total_posts, reactions_given,
       case when total_posts = 0 and reactions_given = 0 then 'Silent'
		when total_posts = 0 then 'Watchers'
		when reactions_given = 0  then 'Broadcasters'
		when total_posts >= 4  then 'Regular posters'
            else 'Occasional posters' end as user_segment from activity
order by user_segment, user_id;

-- S7.
-- If data on ad campaigns (impressions, clicks, conversions) is available,
-- how would you measure their effectiveness and optimize future campaigns?

-- Answer:

-- I would judge a campaign like a bet: before it runs, write down the number that would make
-- us scale it up and the number that would make us shut it off.
-- 1. Find where people drop off. Lots of views but no clicks means the ad itself is weak.
--    Clicks but no purchases means the page or the offer is the problem. Different fix each time.
-- 2. Prove the ad caused the sales. Keep a small group from seeing it and compare their
--    purchases with the group that did. Only the difference counts as the ad's work.
-- 3. Clean the audience first. In our data 23 of 100 users follow nobody, so their feed is
--    empty and an ad shown there is wasted. And 13 users give 41% of all reactions, so I would
--    re-check results without them, or a campaign can look good just because they tap everything.
-- 4. Know what noise looks like. A normal post here gets about 63 reactions, and most land within
--    5 of that. So a campaign that moves reactions by 10 or more is real; a shift of 2 or 3 is
--    noise and not worth celebrating.
-- 5. Spend only where it pays. Money coming in must beat money going out, we wait for enough
--    sales before calling a winner, and we cap repeat views so people do not get tired of the ad.
-- 6. For the next campaign, reuse what worked for each audience group  and content theme,
--    and keep a small slice of budget for trying new ideas.



-- S8.
-- How can you use user activity data to identify potential brand ambassadors
-- or advocates who could help promote Instagram's initiatives or events?

with like_counts as (
    select photo_id, count(*) as like_count 
    from likes 
    group by photo_id
),
comment_counts as (
    select photo_id, count(*) as comment_count 
    from comments 
    group by photo_id
),
photo_eng as (
    select p.id as photo_id, p.user_id, 
           coalesce(l.like_count, 0) + coalesce(c.comment_count, 0) as eng
    from photos p
    left join like_counts l on l.photo_id = p.id
    left join comment_counts c on c.photo_id = p.id
),
user_stats as (
    select user_id, count(*) as total_posts, round(avg(eng), 2) as avg_engagement_per_post
    from photo_eng 
    group by user_id
),
given as (
    select u.id as user_id,
           (select count(*) from likes where user_id = u.id)
         + (select count(*) from comments where user_id = u.id) as reactions_given
    from users u
),
tag_use as (
    select p.user_id, t.tag_name,
           row_number() over (partition by p.user_id order by count(*) desc, t.tag_name) as rn
    from photos p
    join photo_tags pt on pt.photo_id = p.id
    join tags t on t.id = pt.tag_id
    group by p.user_id, t.tag_name
),
platform as (
    select avg(eng) as platform_avg 
    from photo_eng
)
select u.id as user_id, u.username, s.total_posts, g.reactions_given,
       s.avg_engagement_per_post, tu.tag_name as top_tag
from users u
join user_stats s on s.user_id = u.id
join given g on g.user_id = u.id
left join tag_use tu on tu.user_id = u.id and tu.rn = 1
cross join platform pl
where s.total_posts >= 4
  and g.reactions_given >= 150
  and s.avg_engagement_per_post >= pl.platform_avg
order by s.avg_engagement_per_post desc, g.reactions_given desc;

-- S9.
-- How would you approach this problem, if the objective and subjective
-- questions weren't given?

-- Answer:

-- I would treat the database as a suspect before I treat it as a source of truth.
-- 1. Ask what decision Marketing must make (more users, more activity, fewer people leaving)
--    and agree one success measure before touching the data.
-- 2. Find out what the data cannot tell me. Counting rows, gaps and duplicates takes minutes
--    and shows that only signup dates are real, and that age, location, content type and ad
--    data are missing. That decides which questions can be answered at all.
-- 3. A number that is the same for everyone points away from the lever:
--    every user has 76 or 77 followers and every post earns about 63 reactions. A pattern that
--    lines up perfectly points toward it: all 23 users who follow nobody never react.
--    These two checks alone give the best findings in this data.
-- 4. See who carries the platform. The top 10% of users give 31.6% of all reactions and the
--    bottom 20% give none, so losing a few people would hurt far more than losing a few random ones.
-- 5. Group users by what they do (post, react, both, neither), size each group, and give each
--    a different action.
-- 6. Turn each finding into a small test with a success measure and a stop rule.
-- 7. Report on one page: finding, number, action, who owns it, how we would know it worked.
--    Rank by impact against effort, and list the extra data I would ask for.


-- S10.
-- Assuming there's a "User_Interactions" table tracking user engagements, how
-- can you update the "Engagement_Type" column to change all instances of
-- "Like" to "Heart" to align with Instagram's terminology?

-- Answer: 

-- Only needed if engagement_type is an ENUM (replace the list with your existing values)
-- alter table user_interactions
--     modify engagement_type enum('Like', 'Heart', 'Comment', 'Share') not null;

start transaction;

select engagement_type, count(*) as row_count
from user_interactions
group by engagement_type;

update user_interactions
set engagement_type = 'Heart'
where engagement_type = 'Like';

select engagement_type, count(*) as row_count
from user_interactions
group by engagement_type;
commit;

/* ===================================== END OF FILE ===================================== */
