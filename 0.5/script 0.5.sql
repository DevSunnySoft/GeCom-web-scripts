ALTER TABLE public.users ADD COLUMN cps_id character varying;

INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 5, '0.5');