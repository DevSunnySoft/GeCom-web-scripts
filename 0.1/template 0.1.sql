--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Debian 15.1-1.pgdg110+1)
-- Dumped by pg_dump version 15.1

-- Started on 2023-04-18 16:39:41

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

SET default_table_access_method = heap;

--
-- TOC entry 214 (class 1259 OID 32842)
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
-- TOC entry 3321 (class 0 OID 32842)
-- Dependencies: 214
-- Data for Name: versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.versions (_id, created_at, updated_at, build, description) FROM stdin;
56804fde-3245-4977-9116-19604cb977a4	2023-04-18 19:36:38.41602	\N	1	0.1
\.


--
-- TOC entry 3176 (class 2606 OID 32848)
-- Name: versions pk_versions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT pk_versions PRIMARY KEY (_id);


--
-- TOC entry 3178 (class 2606 OID 32850)
-- Name: versions versions_build_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_build_key UNIQUE (build);


-- Completed on 2023-04-18 16:39:41

--
-- PostgreSQL database dump complete
--

