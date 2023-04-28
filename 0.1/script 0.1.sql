CREATE TABLE public.versions
(
    _id uuid NOT NULL,
    created_at timestamp,
    updated_at timestamp,
    build integer unique,
    description character varying,
    CONSTRAINT pk_versions PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.versions
    OWNER to postgres;
	
INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 1, '0.1');