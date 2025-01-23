-- Table: public.sales_promotions

DROP TABLE IF EXISTS public.sales_promotions;

CREATE TABLE IF NOT EXISTS public.sales_promotions
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    is_active boolean NOT NULL DEFAULT 'false',
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    keywords character varying COLLATE pg_catalog."default" NOT NULL,
    company_id uuid,
    CONSTRAINT sales_promotions_pkey PRIMARY KEY (_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sales_promotions
    OWNER to postgres;

-- Table: public.sales_promotion_items
DROP TABLE IF EXISTS public.sales_promotion_items;

CREATE TABLE IF NOT EXISTS public.sales_promotion_items
(
    _id uuid NOT NULL,
    sales_promotion_id uuid NOT NULL,
    product_variation_id uuid NOT NULL,
    sale_value numeric(12,2) NOT NULL DEFAULT '0'::numeric,
    created_at timestamp without time zone NOT NULL DEFAULT 'now()',
    updated_at timestamp without time zone,
    is_active boolean DEFAULT 'true',
    product_id uuid NOT NULL,
    CONSTRAINT sales_promotion_prices_pkey PRIMARY KEY (_id),
    CONSTRAINT fk_sales_promotion_prices_item_id FOREIGN KEY (product_variation_id)
        REFERENCES public.product_variations (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sales_promotion_items
    OWNER to postgres;

INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 8, '0.8');