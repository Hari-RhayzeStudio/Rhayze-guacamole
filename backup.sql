-- RHAYZE STUDIO CLEAN RESTORE SCRIPT
-- Sets the correct encoding and settings
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- 1. Create Types (Enums)
CREATE TYPE public.guacamole_connection_group_type AS ENUM ('ORGANIZATIONAL', 'BALANCING');
ALTER TYPE public.guacamole_connection_group_type OWNER TO rhayze_admin;

CREATE TYPE public.guacamole_entity_type AS ENUM ('USER', 'USER_GROUP');
ALTER TYPE public.guacamole_entity_type OWNER TO rhayze_admin;

CREATE TYPE public.guacamole_object_permission_type AS ENUM ('READ', 'UPDATE', 'DELETE', 'ADMINISTER');
ALTER TYPE public.guacamole_object_permission_type OWNER TO rhayze_admin;

CREATE TYPE public.guacamole_proxy_encryption_method AS ENUM ('NONE', 'SSL');
ALTER TYPE public.guacamole_proxy_encryption_method OWNER TO rhayze_admin;

CREATE TYPE public.guacamole_system_permission_type AS ENUM ('CREATE_CONNECTION', 'CREATE_CONNECTION_GROUP', 'CREATE_SHARING_PROFILE', 'CREATE_USER', 'CREATE_USER_GROUP', 'AUDIT', 'ADMINISTER');
ALTER TYPE public.guacamole_system_permission_type OWNER TO rhayze_admin;

-- 2. Create Tables and Sequences
-- (Notice we keep table names as 'guacamole_...' but set owner to 'rhayze_admin')

CREATE TABLE public.guacamole_connection (
    connection_id integer NOT NULL,
    connection_name character varying(128) NOT NULL,
    parent_id integer,
    protocol character varying(32) NOT NULL,
    max_connections integer,
    max_connections_per_user integer,
    connection_weight integer,
    failover_only boolean DEFAULT false NOT NULL,
    proxy_port integer,
    proxy_hostname character varying(512),
    proxy_encryption_method public.guacamole_proxy_encryption_method
);
ALTER TABLE public.guacamole_connection OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_connection_attribute (
    connection_id integer NOT NULL,
    attribute_name character varying(128) NOT NULL,
    attribute_value character varying(4096) NOT NULL
);
ALTER TABLE public.guacamole_connection_attribute OWNER TO rhayze_admin;

CREATE SEQUENCE public.guacamole_connection_connection_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER TABLE public.guacamole_connection_connection_id_seq OWNER TO rhayze_admin;
ALTER SEQUENCE public.guacamole_connection_connection_id_seq OWNED BY public.guacamole_connection.connection_id;

CREATE TABLE public.guacamole_connection_group (
    connection_group_id integer NOT NULL,
    parent_id integer,
    connection_group_name character varying(128) NOT NULL,
    type public.guacamole_connection_group_type DEFAULT 'ORGANIZATIONAL'::public.guacamole_connection_group_type NOT NULL,
    max_connections integer,
    max_connections_per_user integer,
    enable_session_affinity boolean DEFAULT false NOT NULL
);
ALTER TABLE public.guacamole_connection_group OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_connection_group_attribute (
    connection_group_id integer NOT NULL,
    attribute_name character varying(128) NOT NULL,
    attribute_value character varying(4096) NOT NULL
);
ALTER TABLE public.guacamole_connection_group_attribute OWNER TO rhayze_admin;

CREATE SEQUENCE public.guacamole_connection_group_connection_group_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER TABLE public.guacamole_connection_group_connection_group_id_seq OWNER TO rhayze_admin;
ALTER SEQUENCE public.guacamole_connection_group_connection_group_id_seq OWNED BY public.guacamole_connection_group.connection_group_id;

CREATE TABLE public.guacamole_connection_group_permission (
    entity_id integer NOT NULL,
    connection_group_id integer NOT NULL,
    permission public.guacamole_object_permission_type NOT NULL
);
ALTER TABLE public.guacamole_connection_group_permission OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_connection_history (
    history_id integer NOT NULL,
    user_id integer,
    username character varying(128) NOT NULL,
    remote_host character varying(256) DEFAULT NULL::character varying,
    connection_id integer,
    connection_name character varying(128) NOT NULL,
    sharing_profile_id integer,
    sharing_profile_name character varying(128) DEFAULT NULL::character varying,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone
);
ALTER TABLE public.guacamole_connection_history OWNER TO rhayze_admin;

CREATE SEQUENCE public.guacamole_connection_history_history_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER TABLE public.guacamole_connection_history_history_id_seq OWNER TO rhayze_admin;
ALTER SEQUENCE public.guacamole_connection_history_history_id_seq OWNED BY public.guacamole_connection_history.history_id;

CREATE TABLE public.guacamole_connection_parameter (
    connection_id integer NOT NULL,
    parameter_name character varying(128) NOT NULL,
    parameter_value character varying(4096) NOT NULL
);
ALTER TABLE public.guacamole_connection_parameter OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_connection_permission (
    entity_id integer NOT NULL,
    connection_id integer NOT NULL,
    permission public.guacamole_object_permission_type NOT NULL
);
ALTER TABLE public.guacamole_connection_permission OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_entity (
    entity_id integer NOT NULL,
    name character varying(128) NOT NULL,
    type public.guacamole_entity_type NOT NULL
);
ALTER TABLE public.guacamole_entity OWNER TO rhayze_admin;

CREATE SEQUENCE public.guacamole_entity_entity_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER TABLE public.guacamole_entity_entity_id_seq OWNER TO rhayze_admin;
ALTER SEQUENCE public.guacamole_entity_entity_id_seq OWNED BY public.guacamole_entity.entity_id;

CREATE TABLE public.guacamole_sharing_profile (
    sharing_profile_id integer NOT NULL,
    sharing_profile_name character varying(128) NOT NULL,
    primary_connection_id integer NOT NULL
);
ALTER TABLE public.guacamole_sharing_profile OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_sharing_profile_attribute (
    sharing_profile_id integer NOT NULL,
    attribute_name character varying(128) NOT NULL,
    attribute_value character varying(4096) NOT NULL
);
ALTER TABLE public.guacamole_sharing_profile_attribute OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_sharing_profile_parameter (
    sharing_profile_id integer NOT NULL,
    parameter_name character varying(128) NOT NULL,
    parameter_value character varying(4096) NOT NULL
);
ALTER TABLE public.guacamole_sharing_profile_parameter OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_sharing_profile_permission (
    entity_id integer NOT NULL,
    sharing_profile_id integer NOT NULL,
    permission public.guacamole_object_permission_type NOT NULL
);
ALTER TABLE public.guacamole_sharing_profile_permission OWNER TO rhayze_admin;

CREATE SEQUENCE public.guacamole_sharing_profile_sharing_profile_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER TABLE public.guacamole_sharing_profile_sharing_profile_id_seq OWNER TO rhayze_admin;
ALTER SEQUENCE public.guacamole_sharing_profile_sharing_profile_id_seq OWNED BY public.guacamole_sharing_profile.sharing_profile_id;

CREATE TABLE public.guacamole_system_permission (
    entity_id integer NOT NULL,
    permission public.guacamole_system_permission_type NOT NULL
);
ALTER TABLE public.guacamole_system_permission OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_user (
    user_id integer NOT NULL,
    entity_id integer NOT NULL,
    password_hash bytea NOT NULL,
    password_salt bytea,
    password_date timestamp with time zone NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    expired boolean DEFAULT false NOT NULL,
    access_window_start time without time zone,
    access_window_end time without time zone,
    valid_from date,
    valid_until date,
    timezone character varying(64),
    full_name character varying(256),
    email_address character varying(256),
    organization character varying(256),
    organizational_role character varying(256)
);
ALTER TABLE public.guacamole_user OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_user_attribute (
    user_id integer NOT NULL,
    attribute_name character varying(128) NOT NULL,
    attribute_value character varying(4096) NOT NULL
);
ALTER TABLE public.guacamole_user_attribute OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_user_group (
    user_group_id integer NOT NULL,
    entity_id integer NOT NULL,
    disabled boolean DEFAULT false NOT NULL
);
ALTER TABLE public.guacamole_user_group OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_user_group_attribute (
    user_group_id integer NOT NULL,
    attribute_name character varying(128) NOT NULL,
    attribute_value character varying(4096) NOT NULL
);
ALTER TABLE public.guacamole_user_group_attribute OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_user_group_member (
    user_group_id integer NOT NULL,
    member_entity_id integer NOT NULL
);
ALTER TABLE public.guacamole_user_group_member OWNER TO rhayze_admin;

CREATE TABLE public.guacamole_user_group_permission (
    entity_id integer NOT NULL,
    affected_user_group_id integer NOT NULL,
    permission public.guacamole_object_permission_type NOT NULL
);
ALTER TABLE public.guacamole_user_group_permission OWNER TO rhayze_admin;

CREATE SEQUENCE public.guacamole_user_group_user_group_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER TABLE public.guacamole_user_group_user_group_id_seq OWNER TO rhayze_admin;
ALTER SEQUENCE public.guacamole_user_group_user_group_id_seq OWNED BY public.guacamole_user_group.user_group_id;

CREATE TABLE public.guacamole_user_history (
    history_id integer NOT NULL,
    user_id integer,
    username character varying(128) NOT NULL,
    remote_host character varying(256) DEFAULT NULL::character varying,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone
);
ALTER TABLE public.guacamole_user_history OWNER TO rhayze_admin;

CREATE SEQUENCE public.guacamole_user_history_history_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER TABLE public.guacamole_user_history_history_id_seq OWNER TO rhayze_admin;
ALTER SEQUENCE public.guacamole_user_history_history_id_seq OWNED BY public.guacamole_user_history.history_id;

CREATE TABLE public.guacamole_user_password_history (
    password_history_id integer NOT NULL,
    user_id integer NOT NULL,
    password_hash bytea NOT NULL,
    password_salt bytea,
    password_date timestamp with time zone NOT NULL
);
ALTER TABLE public.guacamole_user_password_history OWNER TO rhayze_admin;

CREATE SEQUENCE public.guacamole_user_password_history_password_history_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER TABLE public.guacamole_user_password_history_password_history_id_seq OWNER TO rhayze_admin;
ALTER SEQUENCE public.guacamole_user_password_history_password_history_id_seq OWNED BY public.guacamole_user_password_history.password_history_id;

CREATE TABLE public.guacamole_user_permission (
    entity_id integer NOT NULL,
    affected_user_id integer NOT NULL,
    permission public.guacamole_object_permission_type NOT NULL
);
ALTER TABLE public.guacamole_user_permission OWNER TO rhayze_admin;

CREATE SEQUENCE public.guacamole_user_user_id_seq
    AS integer START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER TABLE public.guacamole_user_user_id_seq OWNER TO rhayze_admin;
ALTER SEQUENCE public.guacamole_user_user_id_seq OWNED BY public.guacamole_user.user_id;

-- 3. Link Sequences to Columns
ALTER TABLE ONLY public.guacamole_connection ALTER COLUMN connection_id SET DEFAULT nextval('public.guacamole_connection_connection_id_seq'::regclass);
ALTER TABLE ONLY public.guacamole_connection_group ALTER COLUMN connection_group_id SET DEFAULT nextval('public.guacamole_connection_group_connection_group_id_seq'::regclass);
ALTER TABLE ONLY public.guacamole_connection_history ALTER COLUMN history_id SET DEFAULT nextval('public.guacamole_connection_history_history_id_seq'::regclass);
ALTER TABLE ONLY public.guacamole_entity ALTER COLUMN entity_id SET DEFAULT nextval('public.guacamole_entity_entity_id_seq'::regclass);
ALTER TABLE ONLY public.guacamole_sharing_profile ALTER COLUMN sharing_profile_id SET DEFAULT nextval('public.guacamole_sharing_profile_sharing_profile_id_seq'::regclass);
ALTER TABLE ONLY public.guacamole_user ALTER COLUMN user_id SET DEFAULT nextval('public.guacamole_user_user_id_seq'::regclass);
ALTER TABLE ONLY public.guacamole_user_group ALTER COLUMN user_group_id SET DEFAULT nextval('public.guacamole_user_group_user_group_id_seq'::regclass);
ALTER TABLE ONLY public.guacamole_user_history ALTER COLUMN history_id SET DEFAULT nextval('public.guacamole_user_history_history_id_seq'::regclass);
ALTER TABLE ONLY public.guacamole_user_password_history ALTER COLUMN password_history_id SET DEFAULT nextval('public.guacamole_user_password_history_password_history_id_seq'::regclass);

-- 4. INSERT DATA (Using COPY)
COPY public.guacamole_connection (connection_id, connection_name, parent_id, protocol, max_connections, max_connections_per_user, connection_weight, failover_only, proxy_port, proxy_hostname, proxy_encryption_method) FROM stdin;
9	Host Machine Virtual	5	vnc	\N	\N	\N	f	\N	\N	NONE
10	Host Machine Virtual 1	5	vnc	\N	\N	\N	f	\N	\N	NONE
8	Hari.in	4	rdp	\N	\N	\N	f	\N	\N	\N
6	Host Machine RDP	5	rdp	\N	\N	\N	f	\N	\N	\N
\.

COPY public.guacamole_connection_attribute (connection_id, attribute_name, attribute_value) FROM stdin;
\.

COPY public.guacamole_connection_group (connection_group_id, parent_id, connection_group_name, type, max_connections, max_connections_per_user, enable_session_affinity) FROM stdin;
4	\N	Contractors	ORGANIZATIONAL	\N	\N	f
5	\N	Host Machine	ORGANIZATIONAL	\N	\N	f
\.

COPY public.guacamole_connection_group_attribute (connection_group_id, attribute_name, attribute_value) FROM stdin;
\.

COPY public.guacamole_connection_group_permission (entity_id, connection_group_id, permission) FROM stdin;
3	4	READ
3	4	UPDATE
3	4	DELETE
3	4	ADMINISTER
8	4	READ
11	4	READ
8	5	READ
8	5	UPDATE
8	5	DELETE
8	5	ADMINISTER
\.

COPY public.guacamole_connection_history (history_id, user_id, username, remote_host, connection_id, connection_name, sharing_profile_id, sharing_profile_name, start_date, end_date) FROM stdin;
1	2	Virtual24	172.18.0.1	\N	CMD_Win-11	\N	\N	2025-10-16 04:58:16.042+00	2025-10-16 04:58:18.25+00
884	7	Hari venkat	172.18.0.1	8	Hari.in	\N	\N	2025-11-20 06:39:32.771+00	2025-11-20 06:39:55.664+00
295	3	Hari	172.18.0.1	8	Hari.in	\N	\N	2025-10-19 19:01:23.827+00	2025-10-19 19:02:45.475+00
892	7	Hari venkat	172.18.0.1	8	Hari.in	\N	\N	2025-11-20 06:51:33.373+00	2025-11-20 08:03:39.242+00
893	7	Hari venkat	172.18.0.1	8	Hari.in	\N	\N	2025-11-20 08:11:55.892+00	2025-11-20 08:12:30.224+00
897	7	Hari venkat	172.18.0.1	8	Hari.in	\N	\N	2025-11-20 16:10:34.325+00	2025-11-20 16:20:05.905+00
965	7	Hari venkat	172.18.0.1	9	Host Machine Virtual	\N	\N	2025-11-21 05:26:25.431+00	2025-11-21 05:26:25.82+00
966	7	Hari venkat	172.18.0.1	9	Host Machine Virtual	\N	\N	2025-11-21 05:29:09.578+00	2025-11-21 05:29:09.984+00
\.

COPY public.guacamole_connection_parameter (connection_id, parameter_name, parameter_value) FROM stdin;
8	enable-font-smoothing	true
8	hostname	DESKTOP-FPK5T9G
8	color-depth	32
8	recording-name	${HISTORY_UUID}
8	disable-auth	true
8	console-audio	true
8	enable-full-window-drag	true
8	port	3389
8	create-recording-path	true
8	enable-wallpaper	true
8	enable-theming	true
8	timezone	Asia/Calcutta
8	server-layout	en-gb-qwerty
8	security	tls
8	ignore-cert	true
8	dpi	120
8	enable-desktop-composition	true
8	enable-printing	true
8	resize-method	display-update
8	create-drive-path	true
8	enable-drive	true
8	enable-audio-input	true
8	recording-path	record
6	enable-font-smoothing	true
6	hostname	192.168.1.77
6	password	Virtualmachine
6	color-depth	32
6	recording-name	${HISTORY_UUID}
6	console-audio	true
6	enable-full-window-drag	true
6	port	3389
6	create-recording-path	true
6	enable-wallpaper	true
6	enable-theming	true
6	security	nla
6	ignore-cert	true
6	dpi	120
6	enable-desktop-composition	true
6	console	true
6	enable-printing	true
6	resize-method	display-update
6	enable-drive	true
9	cursor	local
9	password	Kamraann
9	color-depth	24
6	enable-audio-input	true
6	recording-path	record
6	username	Kamraann
9	hostname	192.168.1.77
9	port	5900
10	cursor	local
10	password	Kamraann
10	color-depth	24
10	hostname	host.docker.internal
10	port	5900
10	username	Kamraann
\.

COPY public.guacamole_connection_permission (entity_id, connection_id, permission) FROM stdin;
3	6	READ
3	6	UPDATE
3	6	DELETE
3	6	ADMINISTER
3	8	READ
3	8	UPDATE
3	8	DELETE
3	8	ADMINISTER
8	8	READ
11	8	READ
8	9	READ
8	9	UPDATE
8	9	DELETE
8	9	ADMINISTER
8	10	READ
8	10	UPDATE
8	10	DELETE
8	10	ADMINISTER
\.

COPY public.guacamole_entity (entity_id, name, type) FROM stdin;
2	Virtual24	USER
3	Hari	USER
5	kamraann@rhayzestudio.com	USER
8	Hari venkat	USER
9	Kamraann Rajaani	USER
11	Hari Veera Venkat Pasapuleti	USER
12	Sherry	USER
\.

COPY public.guacamole_sharing_profile (sharing_profile_id, sharing_profile_name, primary_connection_id) FROM stdin;
\.

COPY public.guacamole_sharing_profile_attribute (sharing_profile_id, attribute_name, attribute_value) FROM stdin;
\.

COPY public.guacamole_sharing_profile_parameter (sharing_profile_id, parameter_name, parameter_value) FROM stdin;
\.

COPY public.guacamole_sharing_profile_permission (entity_id, sharing_profile_id, permission) FROM stdin;
\.

COPY public.guacamole_system_permission (entity_id, permission) FROM stdin;
2	CREATE_CONNECTION
2	CREATE_CONNECTION_GROUP
2	CREATE_SHARING_PROFILE
2	CREATE_USER
2	CREATE_USER_GROUP
2	AUDIT
2	ADMINISTER
3	CREATE_CONNECTION
3	CREATE_CONNECTION_GROUP
3	CREATE_SHARING_PROFILE
3	CREATE_USER
3	CREATE_USER_GROUP
3	AUDIT
3	ADMINISTER
5	CREATE_CONNECTION
5	CREATE_CONNECTION_GROUP
5	CREATE_SHARING_PROFILE
5	CREATE_USER
5	CREATE_USER_GROUP
5	AUDIT
5	ADMINISTER
9	CREATE_CONNECTION
9	CREATE_CONNECTION_GROUP
9	CREATE_SHARING_PROFILE
9	CREATE_USER
9	CREATE_USER_GROUP
9	AUDIT
9	ADMINISTER
8	CREATE_CONNECTION
8	CREATE_SHARING_PROFILE
8	AUDIT
8	CREATE_USER
8	CREATE_CONNECTION_GROUP
8	CREATE_USER_GROUP
8	ADMINISTER
\.

COPY public.guacamole_user (user_id, entity_id, password_hash, password_salt, password_date, disabled, expired, access_window_start, access_window_end, valid_from, valid_until, timezone, full_name, email_address, organization, organizational_role) FROM stdin;
2	2	\\x4e331b26bca8fca8582fc5985e11044307e8c837b8ba5f90ce18ce3154a72a5d	\\x49c8db4edb5c5b1c940b0709cfb6e00995ffdf6b81cd35970f7346d0fd96bd96	2025-10-16 04:50:35.383+00	f	f	\N	\N	\N	\N	\N	Kamraann Rajaani	kamraann@rhayzestudio.com	Rhayze Studio	Admin
3	3	\\x077702aec78fc9b9b205e4e53f5068832fe230b13249e72bab3112811c576fc4	\\x074ba0e78d072b8078690d3ef30f7ccd96b6a8e10391bce810486fe561c778da	2025-10-18 06:00:16.373+00	f	f	\N	\N	\N	\N	\N	Hari Veera Venkat	hari@rhayzestudio.com	\N	Developer
4	5	\\x083cab4c093798f12525e2e91c063a6053d240fd6b37fa4a746c67fb2ef554d4	\\x339a7b02e29561def1491f527cadd83c3af6171c1618c70d411ec77a44a91b4f	2025-10-23 05:27:36.398+00	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
8	9	\\x17a95c785f68266e67e46b900b9b83e2f4b64f4c4ddf36af480977df5f5650d8	\\xbb5c926c82781f1accb335abe14ed7a9b21e81b24fb19fadaaf15328d859bbde	2025-10-23 15:41:17.003+00	f	f	\N	\N	\N	\N	\N	Kamraann Rajaani	kamraann@rhayzestudio.com	Rhayze Studio	Admin
10	11	\\x921c5d7b30d6c6ccddbe794ae7f107e238bd681156fbedb2d6563dd24892dffd	\\x5c11360947296b1d4f8a6be840b861a2f84ae1b3d4d4a10e1b75f17a606c36c0	2025-10-23 16:05:12.84+00	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
11	12	\\xa105cb49b3e6a0f28181d207d2b21fa1518f333784e04a4f6612781f72fdbac7	\\x5cc728625ca968ab260f8ddf3a214072c1cd21b78313fafe783d532873bd9a8c	2025-10-23 16:20:12.939+00	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
7	8	\\x2b1b967e22f35d96440a1d21033a70c86f8cc798539ac75981ad9af2fc02a007	\\xb523d5c12b739bdd4ff082c7226bdddf8f149b040d3b2e01074f62e2c0b8f9fc	2025-10-23 15:39:53.168+00	f	f	\N	\N	\N	\N	Asia/Calcutta	Hari Veera Venkat	hari@rhayzestudio.com	Rhayze Studio	Developer
\.

COPY public.guacamole_user_attribute (user_id, attribute_name, attribute_value) FROM stdin;
\.

COPY public.guacamole_user_group (user_group_id, entity_id, disabled) FROM stdin;
\.

COPY public.guacamole_user_group_attribute (user_group_id, attribute_name, attribute_value) FROM stdin;
\.

COPY public.guacamole_user_group_member (user_group_id, member_entity_id) FROM stdin;
\.

COPY public.guacamole_user_group_permission (entity_id, affected_user_group_id, permission) FROM stdin;
\.

COPY public.guacamole_user_history (history_id, user_id, username, remote_host, start_date, end_date) FROM stdin;
1	\N	guacadmin	172.18.0.1	2025-10-16 04:44:22.704+00	\N
2	\N	guacadmin	172.18.0.1	2025-10-16 04:44:22.732+00	\N
3	\N	guacadmin	172.18.0.1	2025-10-16 04:44:27.537+00	\N
\.

COPY public.guacamole_user_password_history (password_history_id, user_id, password_hash, password_salt, password_date) FROM stdin;
\.

COPY public.guacamole_user_permission (entity_id, affected_user_id, permission) FROM stdin;
2	2	READ
2	2	UPDATE
2	3	READ
2	3	UPDATE
2	3	DELETE
2	3	ADMINISTER
3	3	READ
3	3	UPDATE
2	4	READ
2	4	UPDATE
2	4	DELETE
2	4	ADMINISTER
5	4	READ
5	4	UPDATE
8	7	READ
9	8	READ
9	8	UPDATE
11	10	READ
12	11	READ
8	7	UPDATE
\.

-- 5. Restore Constraints (Primary Keys and Foreign Keys)
SELECT pg_catalog.setval('public.guacamole_connection_connection_id_seq', 10, true);
SELECT pg_catalog.setval('public.guacamole_connection_group_connection_group_id_seq', 5, true);
SELECT pg_catalog.setval('public.guacamole_connection_history_history_id_seq', 1120, true);
SELECT pg_catalog.setval('public.guacamole_entity_entity_id_seq', 13, true);
SELECT pg_catalog.setval('public.guacamole_sharing_profile_sharing_profile_id_seq', 1, false);
SELECT pg_catalog.setval('public.guacamole_user_group_user_group_id_seq', 2, true);
SELECT pg_catalog.setval('public.guacamole_user_history_history_id_seq', 3710, true);
SELECT pg_catalog.setval('public.guacamole_user_password_history_password_history_id_seq', 1, false);
SELECT pg_catalog.setval('public.guacamole_user_user_id_seq', 11, true);

ALTER TABLE ONLY public.guacamole_connection_group ADD CONSTRAINT connection_group_name_parent UNIQUE (connection_group_name, parent_id);
ALTER TABLE ONLY public.guacamole_connection ADD CONSTRAINT connection_name_parent UNIQUE (connection_name, parent_id);
ALTER TABLE ONLY public.guacamole_connection_attribute ADD CONSTRAINT guacamole_connection_attribute_pkey PRIMARY KEY (connection_id, attribute_name);
ALTER TABLE ONLY public.guacamole_connection_group_attribute ADD CONSTRAINT guacamole_connection_group_attribute_pkey PRIMARY KEY (connection_group_id, attribute_name);
ALTER TABLE ONLY public.guacamole_connection_group_permission ADD CONSTRAINT guacamole_connection_group_permission_pkey PRIMARY KEY (entity_id, connection_group_id, permission);
ALTER TABLE ONLY public.guacamole_connection_group ADD CONSTRAINT guacamole_connection_group_pkey PRIMARY KEY (connection_group_id);
ALTER TABLE ONLY public.guacamole_connection_history ADD CONSTRAINT guacamole_connection_history_pkey PRIMARY KEY (history_id);
ALTER TABLE ONLY public.guacamole_connection_parameter ADD CONSTRAINT guacamole_connection_parameter_pkey PRIMARY KEY (connection_id, parameter_name);
ALTER TABLE ONLY public.guacamole_connection_permission ADD CONSTRAINT guacamole_connection_permission_pkey PRIMARY KEY (entity_id, connection_id, permission);
ALTER TABLE ONLY public.guacamole_connection ADD CONSTRAINT guacamole_connection_pkey PRIMARY KEY (connection_id);
ALTER TABLE ONLY public.guacamole_entity ADD CONSTRAINT guacamole_entity_name_scope UNIQUE (type, name);
ALTER TABLE ONLY public.guacamole_entity ADD CONSTRAINT guacamole_entity_pkey PRIMARY KEY (entity_id);
ALTER TABLE ONLY public.guacamole_sharing_profile_attribute ADD CONSTRAINT guacamole_sharing_profile_attribute_pkey PRIMARY KEY (sharing_profile_id, attribute_name);
ALTER TABLE ONLY public.guacamole_sharing_profile_parameter ADD CONSTRAINT guacamole_sharing_profile_parameter_pkey PRIMARY KEY (sharing_profile_id, parameter_name);
ALTER TABLE ONLY public.guacamole_sharing_profile_permission ADD CONSTRAINT guacamole_sharing_profile_permission_pkey PRIMARY KEY (entity_id, sharing_profile_id, permission);
ALTER TABLE ONLY public.guacamole_sharing_profile ADD CONSTRAINT guacamole_sharing_profile_pkey PRIMARY KEY (sharing_profile_id);
ALTER TABLE ONLY public.guacamole_system_permission ADD CONSTRAINT guacamole_system_permission_pkey PRIMARY KEY (entity_id, permission);
ALTER TABLE ONLY public.guacamole_user_attribute ADD CONSTRAINT guacamole_user_attribute_pkey PRIMARY KEY (user_id, attribute_name);
ALTER TABLE ONLY public.guacamole_user_group_attribute ADD CONSTRAINT guacamole_user_group_attribute_pkey PRIMARY KEY (user_group_id, attribute_name);
ALTER TABLE ONLY public.guacamole_user_group_member ADD CONSTRAINT guacamole_user_group_member_pkey PRIMARY KEY (user_group_id, member_entity_id);
ALTER TABLE ONLY public.guacamole_user_group_permission ADD CONSTRAINT guacamole_user_group_permission_pkey PRIMARY KEY (entity_id, affected_user_group_id, permission);
ALTER TABLE ONLY public.guacamole_user_group ADD CONSTRAINT guacamole_user_group_pkey PRIMARY KEY (user_group_id);
ALTER TABLE ONLY public.guacamole_user_group ADD CONSTRAINT guacamole_user_group_single_entity UNIQUE (entity_id);
ALTER TABLE ONLY public.guacamole_user_history ADD CONSTRAINT guacamole_user_history_pkey PRIMARY KEY (history_id);
ALTER TABLE ONLY public.guacamole_user_password_history ADD CONSTRAINT guacamole_user_password_history_pkey PRIMARY KEY (password_history_id);
ALTER TABLE ONLY public.guacamole_user_permission ADD CONSTRAINT guacamole_user_permission_pkey PRIMARY KEY (entity_id, affected_user_id, permission);
ALTER TABLE ONLY public.guacamole_user ADD CONSTRAINT guacamole_user_pkey PRIMARY KEY (user_id);
ALTER TABLE ONLY public.guacamole_user ADD CONSTRAINT guacamole_user_single_entity UNIQUE (entity_id);
ALTER TABLE ONLY public.guacamole_sharing_profile ADD CONSTRAINT sharing_profile_name_primary UNIQUE (sharing_profile_name, primary_connection_id);

ALTER TABLE ONLY public.guacamole_connection_attribute ADD CONSTRAINT guacamole_connection_attribute_ibfk_1 FOREIGN KEY (connection_id) REFERENCES public.guacamole_connection(connection_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_connection_group_attribute ADD CONSTRAINT guacamole_connection_group_attribute_ibfk_1 FOREIGN KEY (connection_group_id) REFERENCES public.guacamole_connection_group(connection_group_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_connection_group ADD CONSTRAINT guacamole_connection_group_ibfk_1 FOREIGN KEY (parent_id) REFERENCES public.guacamole_connection_group(connection_group_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_connection_group_permission ADD CONSTRAINT guacamole_connection_group_permission_entity FOREIGN KEY (entity_id) REFERENCES public.guacamole_entity(entity_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_connection_group_permission ADD CONSTRAINT guacamole_connection_group_permission_ibfk_1 FOREIGN KEY (connection_group_id) REFERENCES public.guacamole_connection_group(connection_group_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_connection_history ADD CONSTRAINT guacamole_connection_history_ibfk_1 FOREIGN KEY (user_id) REFERENCES public.guacamole_user(user_id) ON DELETE SET NULL;
ALTER TABLE ONLY public.guacamole_connection_history ADD CONSTRAINT guacamole_connection_history_ibfk_2 FOREIGN KEY (connection_id) REFERENCES public.guacamole_connection(connection_id) ON DELETE SET NULL;
ALTER TABLE ONLY public.guacamole_connection_history ADD CONSTRAINT guacamole_connection_history_ibfk_3 FOREIGN KEY (sharing_profile_id) REFERENCES public.guacamole_sharing_profile(sharing_profile_id) ON DELETE SET NULL;
ALTER TABLE ONLY public.guacamole_connection ADD CONSTRAINT guacamole_connection_ibfk_1 FOREIGN KEY (parent_id) REFERENCES public.guacamole_connection_group(connection_group_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_connection_parameter ADD CONSTRAINT guacamole_connection_parameter_ibfk_1 FOREIGN KEY (connection_id) REFERENCES public.guacamole_connection(connection_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_connection_permission ADD CONSTRAINT guacamole_connection_permission_entity FOREIGN KEY (entity_id) REFERENCES public.guacamole_entity(entity_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_connection_permission ADD CONSTRAINT guacamole_connection_permission_ibfk_1 FOREIGN KEY (connection_id) REFERENCES public.guacamole_connection(connection_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_sharing_profile_attribute ADD CONSTRAINT guacamole_sharing_profile_attribute_ibfk_1 FOREIGN KEY (sharing_profile_id) REFERENCES public.guacamole_sharing_profile(sharing_profile_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_sharing_profile ADD CONSTRAINT guacamole_sharing_profile_ibfk_1 FOREIGN KEY (primary_connection_id) REFERENCES public.guacamole_connection(connection_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_sharing_profile_parameter ADD CONSTRAINT guacamole_sharing_profile_parameter_ibfk_1 FOREIGN KEY (sharing_profile_id) REFERENCES public.guacamole_sharing_profile(sharing_profile_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_sharing_profile_permission ADD CONSTRAINT guacamole_sharing_profile_permission_entity FOREIGN KEY (entity_id) REFERENCES public.guacamole_entity(entity_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_sharing_profile_permission ADD CONSTRAINT guacamole_sharing_profile_permission_ibfk_1 FOREIGN KEY (sharing_profile_id) REFERENCES public.guacamole_sharing_profile(sharing_profile_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_system_permission ADD CONSTRAINT guacamole_system_permission_entity FOREIGN KEY (entity_id) REFERENCES public.guacamole_entity(entity_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user_attribute ADD CONSTRAINT guacamole_user_attribute_ibfk_1 FOREIGN KEY (user_id) REFERENCES public.guacamole_user(user_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user ADD CONSTRAINT guacamole_user_entity FOREIGN KEY (entity_id) REFERENCES public.guacamole_entity(entity_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user_group_attribute ADD CONSTRAINT guacamole_user_group_attribute_ibfk_1 FOREIGN KEY (user_group_id) REFERENCES public.guacamole_user_group(user_group_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user_group ADD CONSTRAINT guacamole_user_group_entity FOREIGN KEY (entity_id) REFERENCES public.guacamole_entity(entity_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user_group_member ADD CONSTRAINT guacamole_user_group_member_entity FOREIGN KEY (member_entity_id) REFERENCES public.guacamole_entity(entity_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user_group_member ADD CONSTRAINT guacamole_user_group_member_parent FOREIGN KEY (user_group_id) REFERENCES public.guacamole_user_group(user_group_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user_group_permission ADD CONSTRAINT guacamole_user_group_permission_affected_user_group FOREIGN KEY (affected_user_group_id) REFERENCES public.guacamole_user_group(user_group_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user_group_permission ADD CONSTRAINT guacamole_user_group_permission_entity FOREIGN KEY (entity_id) REFERENCES public.guacamole_entity(entity_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user_history ADD CONSTRAINT guacamole_user_history_ibfk_1 FOREIGN KEY (user_id) REFERENCES public.guacamole_user(user_id) ON DELETE SET NULL;
ALTER TABLE ONLY public.guacamole_user_password_history ADD CONSTRAINT guacamole_user_password_history_ibfk_1 FOREIGN KEY (user_id) REFERENCES public.guacamole_user(user_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user_permission ADD CONSTRAINT guacamole_user_permission_entity FOREIGN KEY (entity_id) REFERENCES public.guacamole_entity(entity_id) ON DELETE CASCADE;
ALTER TABLE ONLY public.guacamole_user_permission ADD CONSTRAINT guacamole_user_permission_ibfk_1 FOREIGN KEY (affected_user_id) REFERENCES public.guacamole_user(user_id) ON DELETE CASCADE;