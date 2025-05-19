ALTER TABLE IF EXISTS public.products
    ADD COLUMN picture_url character varying;

ALTER TABLE IF EXISTS public.products
    ADD COLUMN thumbnail_url character varying;

ALTER TABLE IF EXISTS public.products
    ADD COLUMN max_qtd numeric(12, 3);

ALTER TABLE IF EXISTS public.products_categories
    RENAME productid_id TO product_id;

INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 9, '0.9');