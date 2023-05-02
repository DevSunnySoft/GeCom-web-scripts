--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Debian 15.1-1.pgdg110+1)
-- Dumped by pg_dump version 15.1

-- Started on 2023-05-02 11:47:41

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 32981)
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
-- TOC entry 216 (class 1259 OID 33021)
-- Name: professionals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.professionals (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    name character varying NOT NULL,
    is_active boolean NOT NULL,
    company_id uuid NOT NULL,
    professional_type smallint[] NOT NULL
);


ALTER TABLE public.professionals OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 33033)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    _id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    is_active boolean NOT NULL,
    name character varying NOT NULL,
    professional_id uuid,
    username character varying NOT NULL,
    pin character varying(4),
    email character varying,
    company_id uuid
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 32852)
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
-- TOC entry 3345 (class 0 OID 32981)
-- Dependencies: 215
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.companies (_id, created_at, updated_at, is_active, cps_company_id, name, legal_name) FROM stdin;
\.


--
-- TOC entry 3346 (class 0 OID 33021)
-- Dependencies: 216
-- Data for Name: professionals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.professionals (_id, created_at, updated_at, name, is_active, company_id, professional_type) FROM stdin;
\.


--
-- TOC entry 3347 (class 0 OID 33033)
-- Dependencies: 217
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (_id, created_at, updated_at, is_active, name, professional_id, username, pin, email, company_id) FROM stdin;
\.


--
-- TOC entry 3344 (class 0 OID 32852)
-- Dependencies: 214
-- Data for Name: versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.versions (_id, created_at, updated_at, build, description) FROM stdin;
96609d9e-2e5a-4778-869d-a16ff27be3e8	2023-04-28 19:46:13.206798	\N	1	0.1
8e084479-87f4-4be2-8494-2a9dce558b75	2023-04-28 20:48:00.95193	\N	2	0.2
c8085432-edb9-453c-acc2-1377439515cd	2023-05-02 14:46:10.896756	\N	3	0.3
\.


--
-- TOC entry 3192 (class 2606 OID 32987)
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (_id);


--
-- TOC entry 3188 (class 2606 OID 32858)
-- Name: versions pk_versions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT pk_versions PRIMARY KEY (_id);


--
-- TOC entry 3194 (class 2606 OID 33027)
-- Name: professionals professionals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_pkey PRIMARY KEY (_id);


--
-- TOC entry 3196 (class 2606 OID 33039)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (_id);


--
-- TOC entry 3198 (class 2606 OID 33041)
-- Name: users users_username_company_id_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_company_id_uq UNIQUE (username, company_id);


--
-- TOC entry 3190 (class 2606 OID 32860)
-- Name: versions versions_build_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_build_key UNIQUE (build);


--
-- TOC entry 3199 (class 2606 OID 33028)
-- Name: professionals professionals_companies_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.professionals
    ADD CONSTRAINT professionals_companies_fk FOREIGN KEY (company_id) REFERENCES public.companies(_id);


--
-- TOC entry 3200 (class 2606 OID 33042)
-- Name: users users_companies_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_companies_fk FOREIGN KEY (company_id) REFERENCES public.companies(_id);


--
-- TOC entry 3201 (class 2606 OID 33047)
-- Name: users users_professionals_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_professionals_fk FOREIGN KEY (professional_id) REFERENCES public.professionals(_id);


-- Completed on 2023-05-02 11:47:42

--
-- PostgreSQL database dump complete
--

