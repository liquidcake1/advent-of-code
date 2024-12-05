drop
  table if exists input;

drop
  table if exists rules;

drop
  table if exists updates;

drop
  table if exists split_updates;

create table input (txt text);

\copy input from 'input';

-- rules is an adjacency list, just splitting the input rules.
create table rules as
select
  a[1] as before,
  a[2] as after
from
  (
    select
      regexp_split_to_array(txt, E'\\|')
    from
      input
    where
      txt like '%|%'
  ) x (a);

-- just a straight up list of arrays.
create table updates as
select
  regexp_split_to_array(txt, E',') pages
from
  input
where
  txt like '%,%';

-- Re-add the sequence of the pages so we can actually sort on it. Also add a count for convenience later.
create table split_updates as
select
  row_number() over (partition by update_number) page_seq,
  count(*) over (partition by update_number),
  update_number,
  page_number
from
  -- Just update_number, page_number. We hope that Postgres preserves our ordering!
  (
    select
      row_number() over () update_number,
      unnest(pages) page_number
    from
      updates
  ) as x;

-- nicer output mode
\x

select
  sum(page_number :: integer) sol1
from
  split_updates
where
  page_seq = ("count" + 1) / 2
and
  update_number not in (
    select
      distinct s1.update_number
    from
      split_updates s1
      -- Pick pairs of pages; s1 is the one which appears first in the update.
      -- This is somewhat overkill, we could use s1.page_seq = s2.page_seq - 1 as the adjacency list is complete.
      join split_updates s2 on s1.update_number = s2.update_number and s1.page_seq < s2.page_seq
      -- Match rules backwards -- any matched rows are violated rules.
      left join rules on rules.after = s1.page_number and rules.before = s2.page_number
    where
      -- Pairs with violations only.
      before is not null
  );

select
  sum(page_number :: int) sol2
from
  (
    select distinct
      update_number,
      page_number,
      rule_count
    from
      (
        -- Find for each update, page pair, the number of rules with that page on the left hand side.
        -- Since the rules list is complete, this is n-1 for the sorted-first page and 0 for the sorted-last page.
        -- Hence we're just numbering the pages in the updates in the (reverse) correct order.
        select
          s.update_number,
          s.page_number,
          count(s2.page_number) over (
            partition by s.update_number, s.page_number
          ) rule_count,
          s."count" page_count
        from
          rules
          join split_updates s on s.page_number = rules.before
          join split_updates s2 on s2.page_number = rules.after and s2.update_number = s.update_number
      ) x
    where
      -- Pick only the middle update.
      rule_count * 2 + 1 = page_count
    and
      -- This is the inverse of the condition above -- just find incorrectly sorted updates.
      update_number in (
        select distinct
          s1.update_number
        from
          split_updates s1
          join split_updates s2 on s1.update_number = s2.update_number and s1.page_seq < s2.page_seq
          left join rules on rules.after = s1.page_number and rules.before = s2.page_number
        where
          before is not null
      )
  ) x;
