CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE TEXT SEARCH CONFIGURATION pt ( COPY = portuguese );
ALTER TEXT SEARCH CONFIGURATION pt
        ALTER MAPPING FOR hword, hword_part, word
        WITH unaccent, portuguese_stem;

ALTER TABLE professionals
ADD COLUMN keywords tsvector
GENERATED ALWAYS AS (to_tsvector('pt', coalesce("name", ''))) STORED;

CREATE INDEX professionals_keywords_idx ON professionals USING GIN (keywords);

ALTER TABLE users
ADD COLUMN keywords tsvector
GENERATED ALWAYS AS (to_tsvector('pt', coalesce("name", '') || ' ' || coalesce("username", '') || ' ' || coalesce("email", ''))) STORED;

CREATE INDEX users_keywords_idx ON users USING GIN (keywords);

ALTER TABLE IF EXISTS public.professionals
    ALTER COLUMN company_id DROP NOT NULL;

ALTER TABLE IF EXISTS public.users
    ALTER COLUMN username DROP NOT NULL;

ALTER TABLE public.users
    ALTER COLUMN pin TYPE character varying COLLATE pg_catalog."default";