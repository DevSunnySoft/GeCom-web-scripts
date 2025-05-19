ALTER TABLE IF EXISTS public.products_categories
    ADD CONSTRAINT product_categories_category_id FOREIGN KEY (category_id)
    REFERENCES public.categories (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.products_categories
    ADD CONSTRAINT product_categories_product_id FOREIGN KEY (product_id)
    REFERENCES public.products (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.product_ingredients
    ADD CONSTRAINT product_ingredients_product_id FOREIGN KEY (product_id)
    REFERENCES public.products (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.product_ingredients
    ADD CONSTRAINT product_ingredients_ing_id FOREIGN KEY (ingredient_id)
    REFERENCES public.products (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.product_ingredients
    ADD CONSTRAINT product_ingredients_prod_var_id FOREIGN KEY (product_variation_id)
    REFERENCES public.product_variations (_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.variations_items
    ADD COLUMN index smallint;

UPDATE public.variations_items SET index = 0;

ALTER TABLE IF EXISTS public.variations_items
    ALTER COLUMN index SET NOT NULL;

ALTER TABLE IF EXISTS public.product_variations
    ADD COLUMN index smallint;

UPDATE public.product_variations SET index = 0;

ALTER TABLE IF EXISTS public.variations_items
    ALTER COLUMN index SET NOT NULL;

CREATE INDEX variation_item_index
    ON public.variations_items USING btree
    (index ASC NULLS LAST)
    WITH (deduplicate_items=True);

CREATE OR REPLACE PROCEDURE public.create_company(IN company_name character varying, IN company_legal_name character varying, IN company_cps_id character varying, IN is_active boolean)
    LANGUAGE 'plpgsql'
    
AS $BODY$
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
    INSERT INTO public.variations_items (_id, name, created_at, variation_id, max_division, company_id, "index") 
    VALUES (uuid_generate_v4(), 'Tamanho único', CURRENT_TIMESTAMP, variation_id, 1, null, 0);

    -- creates a default config parameter setting the default variation
    INSERT INTO public.config (_id, value, description, company_id, param, created_at) 
    VALUES (uuid_generate_v4(), variation_id, 'Variação padrão', company_id, 'defaultVariation', CURRENT_TIMESTAMP);
    COMMIT;
END;
$BODY$;

INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 10, '0.10');