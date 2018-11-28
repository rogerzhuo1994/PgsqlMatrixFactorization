-- samll set
-- sample business table
drop table if exists business_small;
create table business_small as
select 		* 
from 		business 
where 		city = 'Las Vegas' 
order by 	review_count desc 
limit 		1000;

select count(distinct business_id) from business_small;

-- filter reviews
drop table if exists review_small;
create table review_small as
select 		* 
from 		review 
where 		business_id in (select business_id from business_small);

select count(distinct business_id) from review_small;
select count(distinct user_id) from review_small;

-- sample users
drop table if exists yelp_user_small;
create table yelp_user_small as
select 		yu.* 
from 		yelp_user yu
inner join	(
				select 	user_id
						, count(distinct business_id) as count 
				from 	review_small 
				group by user_id 
				order by count desc 
				limit 5000
			) u
on 			u.user_id = yu.user_id;

select count(distinct user_id) from yelp_user_small;

drop table if exists review_small;
create table review_small as
select 		* 
from 		review 
where 		business_id in (select business_id from business_small)
and			user_id in (select user_id from yelp_user_small);

-- combine reviews
drop table if exists user_review_samll;
create table user_review_samll as
select 		business_id
			, user_id
			, avg(stars) 
from 		review_small
group by	business_id
			, user_id;
			
select count(*) from user_review_samll;


-- nano set
-- sample business table
drop table if exists business_nano;
create table business_nano as
select 		* 
from 		business 
where 		city = 'Las Vegas' 
order by 	review_count desc 
limit 		500;

select * from business_small limit 20;

-- filter reviews
drop table if exists review_nano;
create table review_nano as
select 		* 
from 		review 
where 		business_id in (select business_id from business_nano);

select count(*) from review_nano;

-- sample users
drop table if exists yelp_user_nano;
create table yelp_user_nano as
select 		yu.* 
from 		yelp_user yu
inner join	(
				select 	user_id
						, count(distinct business_id) as count 
				from 	review_nano
				group by user_id 
				order by count desc 
				limit 1000
			) u
on 			u.user_id = yu.user_id;

drop table if exists review_nano;
create table review_nano as
select 		* 
from 		review 
where 		business_id in (select business_id from business_nano)
and			user_id in (select user_id from yelp_user_nano);

-- combine reviews
drop table if exists user_review_nano;
create table user_review_nano as
select 		business_id
			, user_id
			, avg(stars) 
from 		review_nano
group by	business_id
			, user_id;


-- micro set
-- sample business table
drop table if exists business_micro;
create table business_micro as
select 		* 
from 		business 
where 		city = 'Las Vegas' 
order by 	review_count desc 
limit 		100;

select * from business_micro limit 20;

-- filter reviews
drop table if exists review_micro;
create table review_micro as
select 		* 
from 		review 
where 		business_id in (select business_id from business_micro);

select count(*) from review_micro;

-- sample users
drop table if exists yelp_user_micro;
create table yelp_user_micro as
select 		yu.* 
from 		yelp_user yu
inner join	(
				select 	user_id
						, count(distinct business_id) as count 
				from 	review_micro
				group by user_id 
				order by count desc 
				limit 500
			) u
on 			u.user_id = yu.user_id;

drop table if exists review_micro;
create table review_micro as
select 		* 
from 		review 
where 		business_id in (select business_id from business_micro)
and			user_id in (select user_id from yelp_user_micro);

-- combine reviews
drop table if exists user_review_micro cascade;
create table user_review_micro as
select 		business_id
			, user_id
			, avg(stars) 
from 		review_micro
group by	business_id
			, user_id
order by 	business_id
			, user_id;
			
-- check
-- small: 5000 user, 1000 business, 156915 reviews
select count(distinct business_id), count(*) from business_small;
select count(distinct business_id), count(*) from review_small;
select count(distinct user_id), count(*) from review_small;
select count(distinct user_id), count(*) from yelp_user_small;
select count(distinct business_id), count(*) from user_review_samll;
select count(distinct user_id), count(*) from user_review_samll;

-- nano: 1000 user, 500 business, 45053 reviews
select count(distinct business_id), count(*) from business_nano;
select count(distinct business_id), count(*) from review_nano;
select count(distinct user_id), count(*) from review_nano;
select count(distinct user_id), count(*) from yelp_user_nano;
select count(distinct business_id), count(*) from user_review_nano;
select count(distinct user_id), count(*) from user_review_nano;

-- micro: 500 user, 100 business, 10689 reviews
select count(distinct business_id), count(*) from business_micro;
select count(distinct business_id), count(*) from review_micro;
select count(distinct user_id), count(*) from review_micro;
select count(distinct user_id), count(*) from yelp_user_micro;
select count(distinct business_id), count(*) from user_review_micro;
select count(distinct user_id), count(*) from user_review_micro;




create view all_user_rating as
select 		fst.business_id
			, fst.user_id
			, case when ur.avg is null then 0 else ur.avg end as rating 
from 		(
				select 		b.business_id
							, y.user_id 
				from 		business_micro b 
				cross join 	yelp_user_micro y
			) fst
left join 	user_review_micro ur 
	on 		fst.business_id = ur.business_id 
	and 	fst.user_id = ur.user_id
order by 	business_id
			, user_id;

drop table if exists user_review_matrix;
create table user_review_matrix as
select 		user_id
			, array_agg(rating order by business_id) as review
from 		all_user_rating
group by 	user_id
order by 	user_id;

drop table if exists user_recommend_table;
create table user_recommend_table(
	user_id text,
	business_id text,
	rating numeric
);

drop table if exists training_checkpoint;
create table training_checkpoint (
	param text,
	val numeric[],
	iter integer
);

-- select array_agg(business_id) from (select distinct business_id from user_review_micro order by business_id) tmp;
-- select array_agg(user_id) from (select distinct user_id from user_review_micro order by user_id) tmp;

-- select * from all_user_rating limit 10;























