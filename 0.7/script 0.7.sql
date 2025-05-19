-- Install the uuid-ossp extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP PROCEDURE IF EXISTS public.create_company;

-- creates a postrgres procedure to insert a company
CREATE OR REPLACE PROCEDURE public.create_company(
    company_name character varying,
    company_legal_name character varying,
    company_cps_id character varying,
    is_active boolean
)
LANGUAGE plpgsql
AS $$
-- creates a variable that holds company_id
DECLARE company_id uuid;
-- creates a variable that holds variation_id
DECLARE variation_id uuid;
BEGIN
    -- generates a random uuid
    company_id = uuid_generate_v4();
    variation_id = uuid_generate_v4();

    INSERT INTO public.companies 
    (_id, created_at, is_active, cps_company_id, name, legal_name) 
    VALUES 
    (company_id, CURRENT_TIMESTAMP, is_active, company_cps_id, company_name, company_legal_name);

    
    -- Inserts a default variation for unique size
    INSERT INTO public.variations (_id, name, created_at, company_id) 
    VALUES (variation_id, 'Padrão', CURRENT_TIMESTAMP, null);

    -- Inserts a default size for unique size
    INSERT INTO public.variations_items (_id, name, created_at, variation_id, max_division, company_id) 
    VALUES (uuid_generate_v4(), 'Tamanho único', CURRENT_TIMESTAMP, variation_id, 1, null);

    -- creates a default config parameter setting the default variation
    INSERT INTO public.config (_id, value, description, company_id, param, created_at) 
    VALUES (uuid_generate_v4(), variation_id, 'Variação padrão', company_id, 'defaultVariation', CURRENT_TIMESTAMP);
    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE public.create_config_default()
LANGUAGE plpgsql
AS $$
-- creates a variable that holds company_id
DECLARE company_id uuid;
-- creates a variable that holds variation_id
DECLARE variation_id uuid;
BEGIN
    -- generates a random uuid
    variation_id = uuid_generate_v4();

    -- gets the first company
    SELECT _id INTO company_id FROM public.companies LIMIT 1;
    
    -- Inserts a default variation for unique size
    INSERT INTO public.variations (_id, name, created_at, company_id) 
    VALUES (variation_id, 'Padrão', CURRENT_TIMESTAMP, null);

    -- Inserts a default size for unique size
    INSERT INTO public.variations_items (_id, name, created_at, variation_id, max_division, company_id) 
    VALUES (uuid_generate_v4(), 'Tamanho único', CURRENT_TIMESTAMP, variation_id, 1, null);

    -- creates a default config parameter setting the default variation
    INSERT INTO public.config (_id, value, description, company_id, param, created_at) 
    VALUES (uuid_generate_v4(), variation_id, 'Variação padrão', company_id, 'defaultVariation', CURRENT_TIMESTAMP);
    COMMIT;
END;
$$;

-- calls the procedure to create config default
CALL public.create_config_default();

-- delete the procedure
DROP PROCEDURE IF EXISTS public.create_config_default;

ALTER TABLE IF EXISTS public.product_ingredients
    ADD COLUMN group_id uuid;

DROP TABLE IF EXISTS public.product_ingredients_groups;

CREATE TABLE public.product_ingredients_groups
(
    name character varying NOT NULL,
    qtd_selection smallint NOT NULL DEFAULT 1,
    _id uuid NOT NULL,
    default_selection uuid,
    product_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT product_ingredients_groups_pkey PRIMARY KEY (_id),
    CONSTRAINT prod_ing_group_prod_id FOREIGN KEY (product_id)
        REFERENCES public.products (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS public.product_ingredients_groups
    OWNER to postgres;

CREATE OR REPLACE PROCEDURE public.migrate()
LANGUAGE plpgsql
AS $$
  DECLARE group_names RECORD;
  DECLARE new_group_id uuid;
BEGIN
  -- Create product_ingredients_groups
  FOR group_names IN
    SELECT DISTINCT group_name, product_id FROM public.product_ingredients
  LOOP
  	if (group_names.group_name is not null) then
      new_group_id = uuid_generate_v4();

    	INSERT INTO public.product_ingredients_groups (name, _id, created_at)
    	VALUES (group_names.group_name, new_group_id, CURRENT_TIMESTAMP);

      UPDATE public.product_ingredients
      SET group_id = new_group_id
      WHERE product_id = group_names.product_id and group_name = group_names.group_name;
      
	  end if;
  END LOOP;

END;
$$;

CALL public.migrate();

DROP PROCEDURE IF EXISTS public.migrate;

ALTER TABLE IF EXISTS public.product_ingredients DROP COLUMN IF EXISTS group_name;
ALTER TABLE IF EXISTS public.product_ingredients
    ADD CONSTRAINT product_ingredients_group_id FOREIGN KEY (group_id)
    REFERENCES public.product_ingredients_groups (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

INSERT INTO public.versions values (uuid_generate_v4(), CURRENT_TIMESTAMP, null, 7, '0.7');

ALTER TABLE IF EXISTS public.product_ingredients
ADD COLUMN sale_value numeric(12, 2);


CREATE TABLE IF NOT EXISTS public.observation_groups
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    qtd_selection smallint NOT NULL DEFAULT '1'::smallint,
    keywords character varying COLLATE pg_catalog."default",
    CONSTRAINT observation_groups_pkey PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.observation_groups
    OWNER to postgres;

CREATE TABLE IF NOT EXISTS public.observations
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    text character varying(200) COLLATE pg_catalog."default" NOT NULL,
    observation_group_id uuid,
    keywords character varying COLLATE pg_catalog."default",
    CONSTRAINT observations_pkey PRIMARY KEY (_id),
    CONSTRAINT fk_observations_group_id FOREIGN KEY (observation_group_id)
        REFERENCES public.observation_groups (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE IF EXISTS public.observations
    OWNER to postgres;


CREATE TABLE public.observation_categories
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    observation_id uuid NOT NULL,
    category_id uuid NOT NULL,
    PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.observation_categories
    OWNER to postgres;

ALTER TABLE IF EXISTS public.observation_categories
    ADD CONSTRAINT fk_obs_cat_cat_id FOREIGN KEY (category_id)
    REFERENCES public.categories (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.observation_categories
    ADD CONSTRAINT fk_obs_cat_obs_id FOREIGN KEY (observation_id)
    REFERENCES public.observations (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

DROP TABLE IF EXISTS public.observation_ingredients;

CREATE TABLE IF NOT EXISTS public.observation_ingredients
(
    _id uuid NOT NULL,
    observation_id uuid NOT NULL,
    ingredient_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT observation_ingredients_pkey PRIMARY KEY (_id),
    CONSTRAINT observation_ingredients_ingredients_id_fkey FOREIGN KEY (ingredient_id)
        REFERENCES public.products (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT observation_ingredients_observation_id_fkey FOREIGN KEY (observation_id)
        REFERENCES public.observations (_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

ALTER TABLE IF EXISTS public.observation_ingredients
    OWNER to postgres;

-- Table: public.additional_categories

-- DROP TABLE IF EXISTS public.additional_categories;

CREATE TABLE IF NOT EXISTS public.additional_categories
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    category_id uuid NOT NULL,
    additional_id uuid NOT NULL,
    CONSTRAINT additional_categories_pkey PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.additional_categories
    OWNER to postgres;


DROP TABLE IF EXISTS public.products_categories;

CREATE TABLE IF NOT EXISTS public.products_categories
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    category_id uuid NOT NULL,
    product_id uuid NOT NULL,
    CONSTRAINT products_categories_pkey PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.products_categories
    OWNER to postgres;

ALTER TABLE IF EXISTS public.products DROP COLUMN IF EXISTS category_id;
ALTER TABLE IF EXISTS public.products DROP CONSTRAINT IF EXISTS fk_products_category_id;

CREATE TABLE public.product_combo_items
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    product_id uuid NOT NULL,
    qtd_selection smallint NOT NULL DEFAULT 1,
    sale_value numeric(12, 2) NOT NULL DEFAULT 0,
    name character varying(100) NOT NULL,
    PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.product_combo_items
    OWNER to postgres;

ALTER TABLE IF EXISTS public.product_combo_items
    ADD CONSTRAINT product_combo_item_productid FOREIGN KEY (product_id)
    REFERENCES public.products (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

CREATE TABLE public.product_combo_item_options
(
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    product_id uuid NOT NULL,
    product_variation_id uuid NOT NULL,
    product_combo_item_id uuid NOT NULL,
    qtd numeric(12, 2) NOT NULL DEFAULT 0,
    PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.product_combo_item_options
    OWNER to postgres;

ALTER TABLE IF EXISTS public.product_combo_item_options
    ADD CONSTRAINT prod_combo_item_opt_product_id FOREIGN KEY (product_id)
    REFERENCES public.products (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.product_combo_item_options
    ADD CONSTRAINT prod_combo_item_opt_variation_id FOREIGN KEY (product_variation_id)
    REFERENCES public.product_variations (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;