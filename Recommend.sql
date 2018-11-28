drop function if exists recommend;
create function recommend(uid text) returns 
	table (
		business_id varchar(22),
		name varchar(100),
		address text,
		stars numeric(2,1),
		categories text
	) as
$$
declare
	query text;
begin
	return query
		select 		b.business_id
					, b.name
					, b.address
					, b.stars
					, b.categories 
		from 		business_micro b
		left join 	user_recommend_table mtx
		on			mtx.business_id = b.business_id
		where		mtx.user_id = uid
		order by	mtx.rating desc 
		limit		10;
end;
$$
language plpgsql;









