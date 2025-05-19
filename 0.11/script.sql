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

    
    -- check if a variation already exists
    IF NOT EXISTS (SELECT 1 FROM public.variations WHERE company_id IS NULL) THEN
        -- Inserts a default variation for unique size
        INSERT INTO public.variations (_id, name, created_at, company_id) 
        VALUES (variation_id, 'Padrão', CURRENT_TIMESTAMP, null);

        -- Inserts a default size for unique size
        INSERT INTO public.variations_items (_id, name, created_at, variation_id, max_division, company_id, "index") 
        VALUES (uuid_generate_v4(), 'Tamanho único', CURRENT_TIMESTAMP, variation_id, 1, null, 0);
    END IF;

    -- creates a default config parameter setting the default variation
    INSERT INTO public.config (_id, value, description, company_id, param, created_at) 
    VALUES (uuid_generate_v4(), variation_id, 'Variação padrão', company_id, 'defaultVariation', CURRENT_TIMESTAMP);
    COMMIT;
END;
$BODY$;

INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 11, '0.11');