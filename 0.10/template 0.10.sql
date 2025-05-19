--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2 (Debian 17.2-1.pgdg120+1)
-- Dumped by pg_dump version 17.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: create_company(character varying, character varying, character varying, boolean); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.create_company(IN company_name character varying, IN company_legal_name character varying, IN company_cps_id character varying, IN is_active boolean)
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
    INSERT INTO public.variations_items (_id, name, created_at, variation_id, max_division, company_id, "index") 
    VALUES (uuid_generate_v4(), 'Tamanho único', CURRENT_TIMESTAMP, variation_id, 1, null, 0);

    -- creates a default config parameter setting the default variation
    INSERT INTO public.config (_id, value, description, company_id, param, created_at) 
    VALUES (uuid_generate_v4(), variation_id, 'Variação padrão', company_id, 'defaultVariation', CURRENT_TIMESTAMP);
    COMMIT;
END;
$$;


ALTER PROCEDURE public.create_company(IN company_name character varying, IN company_legal_name character varying, IN company_cps_id character varying, IN is_active boolean) OWNER TO postgres;

--
-- Name: pt; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: postgres
--

CREATE TEXT SEARCH CONFIGURATION public.pt (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR asciiword WITH portuguese_stem;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR word WITH public.unaccent, portuguese_stem;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR hword_part WITH public.unaccent, portuguese_stem;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR hword_asciipart WITH portuguese_stem;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR asciihword WITH portuguese_stem;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR hword WITH public.unaccent, portuguese_stem;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.pt
    ADD MAPPING FOR uint WITH simple;


ALTER TEXT SEARCH CONFIGURATION public.pt OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: additional_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.additional_categories (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    category_id uuid NOT NULL,
    additional_id uuid NOT NULL
);


ALTER TABLE public.additional_categories OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    name character varying(50) NOT NULL,
    complete_description character varying(100),
    main_category_id uuid,
    company_id uuid NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.companies (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    is_active boolean NOT NULL,
    cps_company_id character varying(24) NOT NULL,
    name character varying NOT NULL,
    legal_name character varying
);


ALTER TABLE public.companies OWNER TO postgres;

--
-- Name: config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.config (
    _id uuid NOT NULL,
    value character varying(255),
    description character varying(255),
    company_id uuid,
    param character varying(40) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.config OWNER TO postgres;

--
-- Name: observation_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.observation_categories (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    observation_id uuid NOT NULL,
    category_id uuid NOT NULL
);


ALTER TABLE public.observation_categories OWNER TO postgres;

--
-- Name: observation_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.observation_groups (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    name character varying(100) NOT NULL,
    qtd_selection smallint DEFAULT '1'::smallint NOT NULL,
    keywords character varying
);


ALTER TABLE public.observation_groups OWNER TO postgres;

--
-- Name: observation_ingredients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.observation_ingredients (
    _id uuid NOT NULL,
    observation_id uuid NOT NULL,
    ingredient_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.observation_ingredients OWNER TO postgres;

--
-- Name: observations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.observations (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    text character varying(200) NOT NULL,
    observation_group_id uuid,
    keywords character varying
);


ALTER TABLE public.observations OWNER TO postgres;

--
-- Name: product_combo_item_options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_combo_item_options (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    product_id uuid NOT NULL,
    product_variation_id uuid NOT NULL,
    product_combo_item_id uuid NOT NULL,
    qtd numeric(12,2) DEFAULT 0 NOT NULL
);


ALTER TABLE public.product_combo_item_options OWNER TO postgres;

--
-- Name: product_combo_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_combo_items (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    product_id uuid NOT NULL,
    qtd_selection smallint DEFAULT 1 NOT NULL,
    sale_value numeric(12,2) DEFAULT 0 NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.product_combo_items OWNER TO postgres;

--
-- Name: product_ingredients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_ingredients (
    _id uuid NOT NULL,
    product_id uuid NOT NULL,
    quantity numeric(12,3) DEFAULT '0'::numeric NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_visible boolean DEFAULT true NOT NULL,
    created_at date NOT NULL,
    updated_at date,
    product_variation_id uuid NOT NULL,
    ingredient_id uuid NOT NULL,
    cost_value numeric(12,2),
    group_id uuid,
    sale_value numeric(12,2)
);


ALTER TABLE public.product_ingredients OWNER TO postgres;

--
-- Name: product_ingredients_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_ingredients_groups (
    name character varying NOT NULL,
    qtd_selection smallint DEFAULT 1 NOT NULL,
    _id uuid NOT NULL,
    default_selection uuid,
    product_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.product_ingredients_groups OWNER TO postgres;

--
-- Name: product_variations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variations (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    variation_id uuid NOT NULL,
    variation_item_id uuid NOT NULL,
    sale_value numeric(12,2) DEFAULT 0 NOT NULL,
    product_id uuid NOT NULL,
    name character varying(30),
    variation_name character varying(30),
    cost_value numeric(12,2) DEFAULT 0 NOT NULL,
    index smallint
);


ALTER TABLE public.product_variations OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    name character varying(255),
    description character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    cost_value numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    sale_value numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    product_type smallint DEFAULT '0'::smallint NOT NULL,
    measure character varying(3) DEFAULT 'UN'::character varying NOT NULL,
    enable_delivery boolean DEFAULT true NOT NULL,
    enable_local boolean DEFAULT true NOT NULL,
    is_available boolean DEFAULT true NOT NULL,
    gtin character varying(15),
    id character varying(10) NOT NULL,
    keywords character varying,
    enable_online_sale boolean DEFAULT true NOT NULL,
    company_id uuid,
    enable_stock_control boolean DEFAULT false,
    stock_movement_event smallint DEFAULT 0 NOT NULL,
    picture_url character varying,
    thumbnail_url character varying,
    max_qtd numeric(12,3)
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products_categories (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    category_id uuid NOT NULL,
    product_id uuid NOT NULL
);


ALTER TABLE public.products_categories OWNER TO postgres;

--
-- Name: professionals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.professionals (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    name character varying NOT NULL,
    is_active boolean NOT NULL,
    company_id uuid,
    professional_type smallint[] NOT NULL,
    keywords tsvector GENERATED ALWAYS AS (to_tsvector('public.pt'::regconfig, (COALESCE(name, ''::character varying))::text)) STORED
);


ALTER TABLE public.professionals OWNER TO postgres;

--
-- Name: sales_campaign_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_campaign_items (
    _id uuid NOT NULL,
    sales_campaign_id uuid NOT NULL,
    product_variation_id uuid NOT NULL,
    sale_value numeric(12,2) DEFAULT '0'::numeric NOT NULL,
    created_at timestamp without time zone DEFAULT '2025-02-27 13:53:23.776063'::timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    is_active boolean DEFAULT true,
    product_id uuid NOT NULL
);


ALTER TABLE public.sales_campaign_items OWNER TO postgres;

--
-- Name: sales_campaigns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_campaigns (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    is_active boolean DEFAULT false NOT NULL,
    name character varying(100) NOT NULL,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    keywords character varying NOT NULL,
    company_id uuid
);


ALTER TABLE public.sales_campaigns OWNER TO postgres;

--
-- Name: seq_product_id; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_product_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seq_product_id OWNER TO postgres;

--
-- Name: seq_product_id; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seq_product_id OWNED BY public.products.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    is_active boolean NOT NULL,
    name character varying NOT NULL,
    professional_id uuid,
    username character varying,
    pin character varying,
    email character varying,
    company_id uuid,
    keywords tsvector GENERATED ALWAYS AS (to_tsvector('public.pt'::regconfig, (((((COALESCE(name, ''::character varying))::text || ' '::text) || (COALESCE(username, ''::character varying))::text) || ' '::text) || (COALESCE(email, ''::character varying))::text))) STORED,
    cps_id character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: variations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.variations (
    _id uuid NOT NULL,
    name character varying(30) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    company_id uuid
);


ALTER TABLE public.variations OWNER TO postgres;

--
-- Name: variations_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.variations_items (
    _id uuid NOT NULL,
    name character varying(30) NOT NULL,
    max_division smallint DEFAULT '1'::smallint NOT NULL,
    variation_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    company_id uuid,
    updated_at timestamp without time zone,
    index smallint NOT NULL
);


ALTER TABLE public.variations_items OWNER TO postgres;

--
-- Name: versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.versions (
    _id uuid NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    build integer,
    description character varying
);


ALTER TABLE public.versions OWNER TO postgres;

--
-- Data for Name: additional_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.additional_categories (_id, created_at, updated_at, category_id, additional_id) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (_id, created_at, updated_at, name, complete_description, main_category_id, company_id) FROM stdin;
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.companies (_id, created_at, updated_at, is_active, cps_company_id, name, legal_name) FROM stdin;
\.


--
-- Data for Name: config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.config (_id, value, description, company_id, param, created_at, updated_at) FROM stdin;
d995ae19-4b74-4fe4-a450-3fe63d8aa291	60650904-58b9-4c5b-8aa5-f4c78e3caaeb	Variação padrão	\N	defaultVariation	2025-02-27 13:53:23.465978	\N
\.


--
-- Data for Name: observation_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.observation_categories (_id, created_at, updated_at, observation_id, category_id) FROM stdin;
\.


--
-- Data for Name: observation_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.observation_groups (_id, created_at, updated_at, name, qtd_selection, keywords) FROM stdin;
\.


--
-- Data for Name: observation_ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.observation_ingredients (_id, observation_id, ingredient_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: observations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.observations (_id, created_at, updated_at, text, observation_group_id, keywords) FROM stdin;
\.


--
-- Data for Name: product_combo_item_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_combo_item_options (_id, created_at, updated_at, product_id, product_variation_id, product_combo_item_id, qtd) FROM stdin;
\.


--
-- Data for Name: product_combo_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_combo_items (_id, created_at, updated_at, product_id, qtd_selection, sale_value, name) FROM stdin;
\.


--
-- Data for Name: product_ingredients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_ingredients (_id, product_id, quantity, is_active, is_visible, created_at, updated_at, product_variation_id, ingredient_id, cost_value, group_id, sale_value) FROM stdin;
\.


--
-- Data for Name: product_ingredients_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_ingredients_groups (name, qtd_selection, _id, default_selection, product_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: product_variations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variations (_id, created_at, updated_at, variation_id, variation_item_id, sale_value, product_id, name, variation_name, cost_value, index) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (_id, created_at, updated_at, name, description, is_active, cost_value, sale_value, product_type, measure, enable_delivery, enable_local, is_available, gtin, id, keywords, enable_online_sale, company_id, enable_stock_control, stock_movement_event, picture_url, thumbnail_url, max_qtd) FROM stdin;
\.


--
-- Data for Name: products_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products_categories (_id, created_at, updated_at, category_id, product_id) FROM stdin;
\.


--
-- Data for Name: professionals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.professionals (_id, created_at, updated_at, name, is_active, company_id, professional_type) FROM stdin;
\.


--
-- Data for Name: sales_campaign_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_campaign_items (_id, sales_campaign_id, product_variation_id, sale_value, created_at, updated_at, is_active, product_id) FROM stdin;
\.


--
-- Data for Name: sales_campaigns; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_campaigns (_id, created_at, updated_at, is_active, name, start_date, end_date, keywords, company_id) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (_id, created_at, updated_at, is_active, name, professional_id, username, pin, email, company_id, cps_id) FROM stdin;
\.


--
-- Data for Name: variations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.variations (_id, name, created_at, updated_at, company_id) FROM stdin;
60650904-58b9-4c5b-8aa5-f4c78e3caaeb	Padrão	2025-02-27 13:53:23.465978	\N	\N
\.


--
-- Data for Name: variations_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.variations_items (_id, name, max_division, variation_id, created_at, company_id, updated_at, index) FROM stdin;
21eb1baa-9b50-45cb-841e-360e097d62de	Tamanho único	1	60650904-58b9-4c5b-8aa5-f4c78e3caaeb	2025-02-27 13:53:23.465978	\N	\N	0
\.


--
-- Data for Name: versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.versions (_id, created_at, updated_at, build, description) FROM stdin;
56804fde-3245-4977-9116-19604cb977a4	2023-04-18 19:36:38.41602	\N	1	0.1
d0ff3dbd-5398-4503-8219-24b0bf5f3528	2025-02-09 17:29:15.794736	\N	2	0.2
57fb09a7-aa1b-4734-a7b6-71639cf13b79	2025-02-09 17:29:15.926806	\N	3	0.3
f0596cb1-0833-4b20-bf41-26ca4d0af59d	2025-02-09 17:29:16.09179	\N	4	0.4
1c476a3a-5e7d-4548-9080-c5f0838c6faa	2025-02-09 17:29:16.179938	\N	5	0.5
37ed2a89-e6eb-4a6d-ac5d-13de30652ae1	2025-02-27 13:53:23.307144	\N	6	0.6
a2493861-b777-4b1d-86ad-4889510fb2d0	2025-02-27 13:53:23.512549	\N	7	0.7
c0d1556e-a31c-4700-b7e9-4e1545435fb8	2025-02-27 13:53:23.785613	\N	8	0.8
cdd20543-ae51-476c-9a4a-4137184d0492	2025-04-06 21:44:37.529504	\N	9	0.9
6b7a38d5-78f3-4d9e-94de-057f6f09a733	2025-04-06 21:46:01.752262	\N	10	0.10
\.


--
-- Name: seq_product_id; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_product_id', 1, false);


--
-- Name: additional_categories additional_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.additional_categories
    ADD CONSTRAINT additional_categories_pkey PRIMARY KEY (_id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (_id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (_id);


--
-- Name: config fk_config_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.config
    ADD CONSTRAINT fk_config_id PRIMARY KEY (_id);


--
-- Name: observation_categories observation_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observation_categories
    ADD CONSTRAINT observation_categories_pkey PRIMARY KEY (_id);


--
-- Name: observation_groups observation_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observation_groups
    ADD CONSTRAINT observation_groups_pkey PRIMARY KEY (_id);


--
-- Name: observation_ingredients observation_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observation_ingredients
    ADD CONSTRAINT observation_ingredients_pkey PRIMARY KEY (_id);


--
-- Name: observations observations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observations
    ADD CONSTRAINT observations_pkey PRIMARY KEY (_id);


--
-- Name: versions pk_versions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT pk_versions PRIMARY KEY (_id);


--
-- Name: product_combo_item_options product_combo_item_options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_combo_item_options
    ADD CONSTRAINT product_combo_item_options_pkey PRIMARY KEY (_id);


--
-- Name: product_combo_items product_combo_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_combo_items
    ADD CONSTRAINT product_combo_items_pkey PRIMARY KEY (_id);


--
-- Name: product_ingredients_groups product_ingredients_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_ingredients_groups
    ADD CONSTRAINT product_ingredients_groups_pkey PRIMARY KEY (_id);


--
-- Name: product_ingredients product_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_ingredients
    ADD CONSTRAINT product_ingredients_pkey PRIMARY KEY (_id);


--
-- Name: product_variations product_variations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variations
    ADD CONSTRAINT product_variations_pkey PRIMARY KEY (_id);


--
-- Name: products_categories products_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products_categories
    ADD CONSTRAINT products_categories_pkey PRIMARY KEY (_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (_id);


--
-- Name: professionals professionals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_pkey PRIMARY KEY (_id);


--
-- Name: sales_campaign_items sales_campaign_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_campaign_items
    ADD CONSTRAINT sales_campaign_prices_pkey PRIMARY KEY (_id);


--
-- Name: sales_campaigns sales_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_campaigns
    ADD CONSTRAINT sales_campaigns_pkey PRIMARY KEY (_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (_id);


--
-- Name: users users_username_company_id_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_company_id_uq UNIQUE (username, company_id);


--
-- Name: variations_items variations_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variations_items
    ADD CONSTRAINT variations_items_pkey PRIMARY KEY (_id);


--
-- Name: variations variations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variations
    ADD CONSTRAINT variations_pkey PRIMARY KEY (_id);


--
-- Name: versions versions_build_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_build_key UNIQUE (build);


--
-- Name: professionals_keywords_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX professionals_keywords_idx ON public.professionals USING gin (keywords);


--
-- Name: users_keywords_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_keywords_idx ON public.users USING gin (keywords);


--
-- Name: variation_item_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX variation_item_index ON public.variations_items USING btree (index) WITH (deduplicate_items='true');


--
-- Name: categories fk_categories_company_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_categories_company_id FOREIGN KEY (company_id) REFERENCES public.companies(_id);


--
-- Name: categories fk_categories_main_category_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_categories_main_category_id FOREIGN KEY (_id) REFERENCES public.categories(_id);


--
-- Name: config fk_config_company_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.config
    ADD CONSTRAINT fk_config_company_id FOREIGN KEY (company_id) REFERENCES public.companies(_id) ON DELETE CASCADE;


--
-- Name: observation_categories fk_obs_cat_cat_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observation_categories
    ADD CONSTRAINT fk_obs_cat_cat_id FOREIGN KEY (category_id) REFERENCES public.categories(_id) NOT VALID;


--
-- Name: observation_categories fk_obs_cat_obs_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observation_categories
    ADD CONSTRAINT fk_obs_cat_obs_id FOREIGN KEY (observation_id) REFERENCES public.observations(_id) NOT VALID;


--
-- Name: observations fk_observations_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observations
    ADD CONSTRAINT fk_observations_group_id FOREIGN KEY (observation_group_id) REFERENCES public.observation_groups(_id);


--
-- Name: product_variations fk_product_variaion_item_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variations
    ADD CONSTRAINT fk_product_variaion_item_id FOREIGN KEY (variation_item_id) REFERENCES public.variations_items(_id);


--
-- Name: product_variations fk_product_variation_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variations
    ADD CONSTRAINT fk_product_variation_id FOREIGN KEY (variation_id) REFERENCES public.variations(_id);


--
-- Name: product_variations fk_product_variation_product_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variations
    ADD CONSTRAINT fk_product_variation_product_id FOREIGN KEY (product_id) REFERENCES public.products(_id) ON DELETE CASCADE;


--
-- Name: products fk_products_company_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_company_id FOREIGN KEY (company_id) REFERENCES public.companies(_id);


--
-- Name: sales_campaign_items fk_sales_campaign_prices_item_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_campaign_items
    ADD CONSTRAINT fk_sales_campaign_prices_item_id FOREIGN KEY (product_variation_id) REFERENCES public.product_variations(_id);


--
-- Name: variations fk_variation_company_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variations
    ADD CONSTRAINT fk_variation_company_id FOREIGN KEY (company_id) REFERENCES public.companies(_id);


--
-- Name: variations_items fk_variation_items_company_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variations_items
    ADD CONSTRAINT fk_variation_items_company_id FOREIGN KEY (company_id) REFERENCES public.companies(_id);


--
-- Name: variations_items fk_variation_items_variation_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variations_items
    ADD CONSTRAINT fk_variation_items_variation_id FOREIGN KEY (variation_id) REFERENCES public.variations(_id) ON DELETE CASCADE;


--
-- Name: observation_ingredients observation_ingredients_ingredients_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observation_ingredients
    ADD CONSTRAINT observation_ingredients_ingredients_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.products(_id);


--
-- Name: observation_ingredients observation_ingredients_observation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observation_ingredients
    ADD CONSTRAINT observation_ingredients_observation_id_fkey FOREIGN KEY (observation_id) REFERENCES public.observations(_id);


--
-- Name: product_combo_item_options prod_combo_item_opt_product_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_combo_item_options
    ADD CONSTRAINT prod_combo_item_opt_product_id FOREIGN KEY (product_id) REFERENCES public.products(_id) NOT VALID;


--
-- Name: product_combo_item_options prod_combo_item_opt_variation_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_combo_item_options
    ADD CONSTRAINT prod_combo_item_opt_variation_id FOREIGN KEY (product_variation_id) REFERENCES public.product_variations(_id) NOT VALID;


--
-- Name: product_ingredients_groups prod_ing_group_prod_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_ingredients_groups
    ADD CONSTRAINT prod_ing_group_prod_id FOREIGN KEY (product_id) REFERENCES public.products(_id);


--
-- Name: products_categories product_categories_category_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products_categories
    ADD CONSTRAINT product_categories_category_id FOREIGN KEY (category_id) REFERENCES public.categories(_id) NOT VALID;


--
-- Name: products_categories product_categories_product_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products_categories
    ADD CONSTRAINT product_categories_product_id FOREIGN KEY (product_id) REFERENCES public.products(_id) NOT VALID;


--
-- Name: product_combo_items product_combo_item_productid; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_combo_items
    ADD CONSTRAINT product_combo_item_productid FOREIGN KEY (product_id) REFERENCES public.products(_id) NOT VALID;


--
-- Name: product_ingredients product_ingredients_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_ingredients
    ADD CONSTRAINT product_ingredients_group_id FOREIGN KEY (group_id) REFERENCES public.product_ingredients_groups(_id) NOT VALID;


--
-- Name: product_ingredients product_ingredients_ing_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_ingredients
    ADD CONSTRAINT product_ingredients_ing_id FOREIGN KEY (ingredient_id) REFERENCES public.products(_id) NOT VALID;


--
-- Name: product_ingredients product_ingredients_prod_var_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_ingredients
    ADD CONSTRAINT product_ingredients_prod_var_id FOREIGN KEY (product_variation_id) REFERENCES public.product_variations(_id) NOT VALID;


--
-- Name: product_ingredients product_ingredients_product_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_ingredients
    ADD CONSTRAINT product_ingredients_product_id FOREIGN KEY (product_id) REFERENCES public.products(_id) NOT VALID;


--
-- Name: professionals professionals_companies_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_companies_fk FOREIGN KEY (company_id) REFERENCES public.companies(_id);


--
-- Name: users users_companies_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_companies_fk FOREIGN KEY (company_id) REFERENCES public.companies(_id);


--
-- Name: users users_professionals_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_professionals_fk FOREIGN KEY (professional_id) REFERENCES public.professionals(_id);


--
-- PostgreSQL database dump complete
--

