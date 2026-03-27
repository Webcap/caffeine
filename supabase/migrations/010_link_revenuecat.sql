alter table public.plans add column if not exists revenue_cat_identifier text;

update public.plans set revenue_cat_identifier = 'monthly' where title = 'Monthly Plan';
update public.plans set revenue_cat_identifier = 'yearly' where title = 'Yearly Plan';
