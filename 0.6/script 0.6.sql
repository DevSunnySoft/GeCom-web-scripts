CREATE TABLE IF NOT EXISTS public.variations
(
    _id uuid NOT NULL,
    name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    company_id uuid,
    CONSTRAINT variations_pkey PRIMARY KEY (_id),
    CONSTRAINT fk_variation_company_id FOREIGN KEY (company_id)
        REFERENCES public.companies (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS public.variations
    OWNER to postgres;

CREATE TABLE public.variations_items
(
    _id uuid NOT NULL,
    name character varying(30) COLLATE pg_catalog."default" NOT NULL,
    max_division smallint NOT NULL DEFAULT '1'::smallint,
    variation_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    company_id uuid,
    updated_at timestamp without time zone,
    CONSTRAINT variations_items_pkey PRIMARY KEY (_id),
    CONSTRAINT fk_variation_items_company_id FOREIGN KEY (company_id)
        REFERENCES public.companies (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT fk_variation_items_variation_id FOREIGN KEY (variation_id)
        REFERENCES public.variations (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID
);

ALTER TABLE IF EXISTS public.variations_items
    OWNER to postgres;
    
CREATE TABLE IF NOT EXISTS public.categories
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    complete_description character varying(100) COLLATE pg_catalog."default",
    main_category_id uuid,
    company_id uuid NOT NULL,
    CONSTRAINT categories_pkey PRIMARY KEY (_id),
    CONSTRAINT fk_categories_company_id FOREIGN KEY (company_id)
        REFERENCES public.companies (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT fk_categories_main_category_id FOREIGN KEY (_id)
        REFERENCES public.categories (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS public.categories
    OWNER to postgres;

CREATE TABLE IF NOT EXISTS public.products
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    name character varying(255) COLLATE pg_catalog."default",
    description character varying(255) COLLATE pg_catalog."default",
    category_id uuid,
    is_active boolean NOT NULL DEFAULT 'true',
    cost_value numeric(12,2) NOT NULL DEFAULT '0'::numeric,
    sale_value numeric(12,2) NOT NULL DEFAULT '0'::numeric,
    product_type smallint NOT NULL DEFAULT '0'::smallint,
    measure character varying(3) COLLATE pg_catalog."default" NOT NULL DEFAULT 'UN'::character varying,
    enable_delivery boolean NOT NULL DEFAULT 'true',
    enable_local boolean NOT NULL DEFAULT 'true',
    is_available boolean NOT NULL DEFAULT 'true',
    gtin character varying(15) COLLATE pg_catalog."default",
    id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    keywords character varying COLLATE pg_catalog."default",
    enable_online_sale boolean NOT NULL DEFAULT 'true',
    company_id uuid,
    enable_stock_control boolean DEFAULT 'false',
    stock_movement_event smallint NOT NULL DEFAULT 0,
    CONSTRAINT products_pkey PRIMARY KEY (_id),
    CONSTRAINT fk_products_category_id FOREIGN KEY (category_id)
        REFERENCES public.categories (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fk_products_company_id FOREIGN KEY (company_id)
        REFERENCES public.companies (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS public.products
    OWNER to postgres;

CREATE SEQUENCE public.seq_product_id
    INCREMENT 1
    MINVALUE 1
    OWNED BY products.id;

ALTER SEQUENCE public.seq_product_id
    OWNER TO postgres;

CREATE TABLE IF NOT EXISTS public.product_variations
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    variation_id uuid NOT NULL,
    variation_item_id uuid NOT NULL,
    sale_value numeric(12,2) NOT NULL DEFAULT 0,
    product_id uuid NOT NULL,
    name character varying(30) COLLATE pg_catalog."default",
    variation_name character varying(30) COLLATE pg_catalog."default",
    cost_value numeric(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT product_variations_pkey PRIMARY KEY (_id),
    CONSTRAINT fk_product_variaion_item_id FOREIGN KEY (variation_item_id)
        REFERENCES public.variations_items (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT fk_product_variation_id FOREIGN KEY (variation_id)
        REFERENCES public.variations (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT fk_product_variation_product_id FOREIGN KEY (product_id)
        REFERENCES public.products (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID
);

ALTER TABLE IF EXISTS public.product_variations
    OWNER to postgres;

-- Table: public.config

-- DROP TABLE IF EXISTS public.config;

CREATE TABLE IF NOT EXISTS public.config
(
    _id uuid NOT NULL,
    value character varying(255) COLLATE pg_catalog."default",
    description character varying(255) COLLATE pg_catalog."default",
    company_id uuid,
    param character varying(40) COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT fk_config_id PRIMARY KEY (_id),
    CONSTRAINT fk_config_company_id FOREIGN KEY (company_id)
        REFERENCES public.companies (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID
);

ALTER TABLE IF EXISTS public.config
    OWNER to postgres;


-- Table: public.product_ingredients

-- DROP TABLE IF EXISTS public.product_ingredients;

CREATE TABLE IF NOT EXISTS public.product_ingredients
(
    _id uuid NOT NULL,
    product_id uuid NOT NULL,
    quantity numeric(12,3) NOT NULL DEFAULT '0'::numeric,
    group_name character varying(30) COLLATE pg_catalog."default",
    is_active boolean NOT NULL DEFAULT 'true',
    is_visible boolean NOT NULL DEFAULT 'true',
    created_at date NOT NULL,
    updated_at date,
    product_variation_id uuid NOT NULL,
    ingredient_id uuid NOT NULL,
    cost_value numeric(12,2),
    CONSTRAINT product_ingredients_pkey PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.product_ingredients
    OWNER to postgres;

INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 6, '0.6');