CREATE TABLE public.companies
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    is_active boolean NOT NULL,
    cps_company_id character varying(24) NOT NULL,
    name character varying NOT NULL,
    legal_name character varying,
    PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.companies
    OWNER to postgres;

INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 2, '0.2');