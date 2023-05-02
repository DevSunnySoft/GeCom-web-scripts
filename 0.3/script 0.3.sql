CREATE TABLE public.professionals
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    name character varying NOT NULL,
    is_active boolean NOT NULL,
    company_id uuid NOT NULL,
    professional_type smallint[] NOT NULL,
    PRIMARY KEY (_id),
    CONSTRAINT professionals_companies_fk FOREIGN KEY (company_id)
        REFERENCES public.companies (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS public.professionals
    OWNER to postgres;

CREATE TABLE public.users
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    is_active boolean NOT NULL,
    name character varying NOT NULL,
    professional_id uuid,
    username character varying NOT NULL,
    pin character varying(4),
    email character varying,
    company_id uuid,
    PRIMARY KEY (_id),
    CONSTRAINT users_username_company_id_uq UNIQUE (username, company_id),
    CONSTRAINT users_companies_fk FOREIGN KEY (company_id)
        REFERENCES public.companies (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT users_professionals_fk FOREIGN KEY (professional_id)
        REFERENCES public.professionals (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS public.users
    OWNER to postgres;

INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 3, '0.3');