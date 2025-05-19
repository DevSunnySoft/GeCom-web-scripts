--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Debian 15.1-1.pgdg110+1)
-- Dumped by pg_dump version 15.1

-- Started on 2023-05-10 12:14:56

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 16491)
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- TOC entry 3365 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- TOC entry 2053 (class 3602 OID 16498)
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

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 16418)
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
-- TOC entry 217 (class 1259 OID 16434)
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
-- TOC entry 218 (class 1259 OID 16446)
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
-- TOC entry 216 (class 1259 OID 16423)
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
-- TOC entry 3356 (class 0 OID 16418)
-- Dependencies: 215
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.companies (_id, created_at, updated_at, is_active, cps_company_id, name, legal_name) FROM stdin;
\.


--
-- TOC entry 3358 (class 0 OID 16434)
-- Dependencies: 217
-- Data for Name: professionals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.professionals (_id, created_at, updated_at, name, is_active, company_id, professional_type) FROM stdin;
\.


--
-- TOC entry 3359 (class 0 OID 16446)
-- Dependencies: 218
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (_id, created_at, updated_at, is_active, name, professional_id, username, pin, email, company_id, cps_id) FROM stdin;
\.


--
-- TOC entry 3357 (class 0 OID 16423)
-- Dependencies: 216
-- Data for Name: versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.versions (_id, created_at, updated_at, build, description) FROM stdin;
96609d9e-2e5a-4778-869d-a16ff27be3e8	2023-04-28 19:46:13.206798	\N	1	0.1
8e084479-87f4-4be2-8494-2a9dce558b75	2023-04-28 20:48:00.95193	\N	2	0.2
8bb54021-510e-4f42-b3f3-a2bbe388be27	2023-05-03 20:37:26.935354	\N	3	0.3
ec36e518-6bb2-4e8e-bc1d-7fd7c8a01b5f	2023-05-10 15:13:55.885325	\N	5	0.5
047debdd-0094-4fe0-9435-d3bfb23744da	2023-05-10 15:13:55.920107	\N	4	0.4
\.


--
-- TOC entry 3198 (class 2606 OID 16429)
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (_id);


--
-- TOC entry 3200 (class 2606 OID 16431)
-- Name: versions pk_versions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT pk_versions PRIMARY KEY (_id);


--
-- TOC entry 3205 (class 2606 OID 16440)
-- Name: professionals professionals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_pkey PRIMARY KEY (_id);


--
-- TOC entry 3208 (class 2606 OID 16452)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (_id);


--
-- TOC entry 3210 (class 2606 OID 16454)
-- Name: users users_username_company_id_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_company_id_uq UNIQUE (username, company_id);


--
-- TOC entry 3202 (class 2606 OID 16433)
-- Name: versions versions_build_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_build_key UNIQUE (build);


--
-- TOC entry 3203 (class 1259 OID 16506)
-- Name: professionals_keywords_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX professionals_keywords_idx ON public.professionals USING gin (keywords);


--
-- TOC entry 3206 (class 1259 OID 16515)
-- Name: users_keywords_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_keywords_idx ON public.users USING gin (keywords);


--
-- TOC entry 3211 (class 2606 OID 16441)
-- Name: professionals professionals_companies_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_companies_fk FOREIGN KEY (company_id) REFERENCES public.companies(_id);


--
-- TOC entry 3212 (class 2606 OID 16455)
-- Name: users users_companies_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_companies_fk FOREIGN KEY (company_id) REFERENCES public.companies(_id);


--
-- TOC entry 3213 (class 2606 OID 16460)
-- Name: users users_professionals_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_professionals_fk FOREIGN KEY (professional_id) REFERENCES public.professionals(_id);


-- Completed on 2023-05-10 12:14:56

--
-- PostgreSQL database dump complete
--

