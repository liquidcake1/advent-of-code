\copy input from 'input';
drop table rules;
drop table updates ;
drop table split_updates ;
create table rules as select a[1] as before, a[2] as after from (select regexp_split_to_array(txt, E'\\|') from input where txt like '%|%')x (a) ;
create table updates as select regexp_split_to_array(txt, E',') pages from input where txt like '%,%';
create table split_updates as select row_number() over (partition by update_number) page_seq, count(*) over (partition by update_number), update_number, page_number from (select row_number() over () update_number, unnest(pages) page_number from updates) as x;
select sum(page_number::integer) from split_updates where update_number not in (select distinct s1.update_number from split_updates s1 join split_updates s2 on s1.update_number = s2.update_number and s1.page_seq < s2.page_seq left join rules on rules.after = s1.page_number and rules.before = s2.page_number where before is not null order by 1) and page_seq = (count + 1) / 2;
with recursive x as (select before, after from rules union select rules.before, rules.after from rules join x on x.before = rules.after) select * from x;
select sum(page_number::int) from (select distinct update_number, page_number, rule_count from (select s.update_number, s.page_number, count(s2.page_number) over (partition by s.update_number, s.page_number) rule_count, s."count" page_count from split_updates s join rules on s.page_number = rules.before join split_updates s2 on s2.page_number = rules.after and s2.update_number = s.update_number)x where rule_count * 2 + 1 = page_count and update_number in (select distinct s1.update_number from split_updates s1 join split_updates s2 on s1.update_number = s2.update_number and s1.page_seq < s2.page_seq left join rules on rules.after = s1.page_number and rules.before = s2.page_number where before is not null order by 1)) x;

