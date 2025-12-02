-- Read input
drop table if exists input;
create table input (line text not null);
\copy input from stdin;
INPUT_GOES_HERE
\.

-- Parse it
drop table if exists parsed;
create table parsed as (select regexp_matches(line, '([^,]+)-([^,]+)', 'g') range from input);

-- naive solution
-- with all_ids (id) as (
-- 	select generate_series(range[1]::bigint, range[2]::bigint) from parsed
-- )
-- select
-- 	sum(case when id::text ~ E'^(.*)(?:\\1)$' then id end) as part1,
-- 	sum(case when id::text ~ E'^(.*)(?:\\1)+$' then id end) as part2
-- from all_ids;

create or replace function factors(i integer) returns table(f integer) language sql as $$
	select f from generate_series(1, i - 1) x (f) where i % f = 0;
$$;

-- Win
with
	split_problems(lt, rt) as (
			select range[1]::bigint, range[2]::bigint from parsed where length(range[1]) = length(range[2])
		union
			select range[1]::bigint, pow(10, length(range[1]))::bigint - 1 from parsed where length(range[1]) = length(range[2]) - 1
		union
			select pow(10, length(range[1]))::bigint, range[2]::bigint from parsed where length(range[1]) = length(range[2]) - 1
	),
	with_factors as (
		select lt, rt, factors(length(lt::text)) f from split_problems
	),
	subproblems as (
		select length(lt::text) / f reps, substring(lt::text, 1, f)::integer lowest, substring(rt::text, 1, f)::integer biggest, lt, rt from with_factors
	),
	with_candidates as (
		select *, generate_series(lowest, biggest) candidate_sub from subproblems
	),
	generated as (
		select *, repeat(candidate_sub::text, reps)::bigint candidate from with_candidates
	)
select
	sum(distinct case when reps = 2 then candidate end),
	sum(distinct candidate)
from generated where candidate between lt and rt;
