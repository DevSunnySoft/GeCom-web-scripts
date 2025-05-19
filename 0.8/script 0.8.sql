-- Table: public.sales_campaigns

DROP TABLE IF EXISTS public.sales_campaigns;

CREATE TABLE IF NOT EXISTS public.sales_campaigns
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
    CONSTRAINT sales_campaigns_pkey PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.sales_campaigns
    OWNER to postgres;

-- Table: public.sales_campaign_items
DROP TABLE IF EXISTS public.sales_campaign_items;

CREATE TABLE IF NOT EXISTS public.sales_campaign_items
(
    _id uuid NOT NULL,
    sales_campaign_id uuid NOT NULL,
    product_variation_id uuid NOT NULL,
    sale_value numeric(12,2) NOT NULL DEFAULT '0'::numeric,
    created_at timestamp without time zone NOT NULL DEFAULT 'now()',
    updated_at timestamp without time zone,
    is_active boolean DEFAULT 'true',
    product_id uuid NOT NULL,
    CONSTRAINT sales_campaign_prices_pkey PRIMARY KEY (_id),
    CONSTRAINT fk_sales_campaign_prices_item_id FOREIGN KEY (product_variation_id)
        REFERENCES public.product_variations (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS public.sales_campaign_items
    OWNER to postgres;

INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 8, '0.8');