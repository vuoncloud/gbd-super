--
-- PostgreSQL database dump
--

-- Dumped from database version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)
-- Dumped by pg_dump version 14.18 (Ubuntu 14.18-0ubuntu0.22.04.1)

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
-- Name: device_status_log; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.device_status_log (
    id integer NOT NULL,
    mac_address character varying(17) NOT NULL,
    status character varying(20) NOT NULL,
    previous_status character varying(20),
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reason text
);


ALTER TABLE public.device_status_log OWNER TO gbdmulti;

--
-- Name: device_status_log_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.device_status_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.device_status_log_id_seq OWNER TO gbdmulti;

--
-- Name: device_status_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.device_status_log_id_seq OWNED BY public.device_status_log.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.devices (
    mac_address character varying(17) NOT NULL,
    device_id character varying(100) NOT NULL,
    project character varying(100),
    current_fw_version character varying(50),
    target_fw_version character varying(50),
    build_date character varying(100),
    last_seen timestamp with time zone,
    config jsonb,
    force_config_update boolean DEFAULT false,
    is_enabled boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    device_type character varying(50) DEFAULT 'unknown'::character varying NOT NULL,
    project_id integer,
    assigned_user character varying(255),
    wifi_ssid character varying(255),
    wifi_password character varying(255),
    mqtt_host character varying(255),
    mqtt_port integer DEFAULT 1883,
    mqtt_username character varying(255),
    mqtt_password character varying(255),
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'offline'::character varying,
    status_updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    heartbeat_interval integer DEFAULT 60,
    is_updating boolean DEFAULT false,
    update_progress integer DEFAULT 0,
    update_started_at timestamp without time zone
);


ALTER TABLE public.devices OWNER TO gbdmulti;

--
-- Name: employee_profiles; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.employee_profiles (
    user_id integer NOT NULL,
    company_name character varying(255),
    employee_govt_id character varying(100),
    address text,
    designation character varying(100),
    department character varying(100)
);


ALTER TABLE public.employee_profiles OWNER TO gbdmulti;

--
-- Name: firmware_manifest; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.firmware_manifest (
    version character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    uploaded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    device_type character varying(255)
);


ALTER TABLE public.firmware_manifest OWNER TO gbdmulti;

--
-- Name: hardware; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.hardware (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    hardware_type character varying(100),
    model character varying(100),
    serial_number character varying(100),
    details jsonb DEFAULT '{}'::jsonb,
    status character varying(50) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.hardware OWNER TO gbdmulti;

--
-- Name: hardware_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.hardware_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hardware_id_seq OWNER TO gbdmulti;

--
-- Name: hardware_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.hardware_id_seq OWNED BY public.hardware.id;


--
-- Name: permission_audit_log; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.permission_audit_log (
    id integer NOT NULL,
    user_id integer,
    target_user_id integer,
    permission_key character varying(100),
    action character varying(50),
    old_value character varying(50),
    new_value character varying(50),
    changed_by integer,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reason text
);


ALTER TABLE public.permission_audit_log OWNER TO gbdmulti;

--
-- Name: permission_audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.permission_audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.permission_audit_log_id_seq OWNER TO gbdmulti;

--
-- Name: permission_audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.permission_audit_log_id_seq OWNED BY public.permission_audit_log.id;


--
-- Name: permission_discovery_log; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.permission_discovery_log (
    id integer NOT NULL,
    permission_name character varying(255),
    discovered_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    source_file character varying(500),
    source_function character varying(255),
    status character varying(50) DEFAULT 'discovered'::character varying
);


ALTER TABLE public.permission_discovery_log OWNER TO gbdmulti;

--
-- Name: permission_discovery_log_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.permission_discovery_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.permission_discovery_log_id_seq OWNER TO gbdmulti;

--
-- Name: permission_discovery_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.permission_discovery_log_id_seq OWNED BY public.permission_discovery_log.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    display_name character varying(255),
    description text,
    category character varying(100),
    auto_discovered boolean DEFAULT false,
    display_order integer DEFAULT 0,
    icon character varying(100),
    endpoint character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.permissions OWNER TO gbdmulti;

--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.permissions_id_seq OWNER TO gbdmulti;

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: project_hardware; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.project_hardware (
    id integer NOT NULL,
    project_id integer,
    hardware_id integer,
    assigned_by integer,
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(50) DEFAULT 'active'::character varying,
    notes text
);


ALTER TABLE public.project_hardware OWNER TO gbdmulti;

--
-- Name: project_hardware_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.project_hardware_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_hardware_id_seq OWNER TO gbdmulti;

--
-- Name: project_hardware_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.project_hardware_id_seq OWNED BY public.project_hardware.id;


--
-- Name: project_software; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.project_software (
    id integer NOT NULL,
    project_id integer,
    software_id integer,
    assigned_by integer,
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    license_key character varying(255),
    status character varying(50) DEFAULT 'active'::character varying,
    notes text
);


ALTER TABLE public.project_software OWNER TO gbdmulti;

--
-- Name: project_software_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.project_software_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_software_id_seq OWNER TO gbdmulti;

--
-- Name: project_software_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.project_software_id_seq OWNED BY public.project_software.id;


--
-- Name: project_users; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.project_users (
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    role_name character varying(50) NOT NULL,
    deleted_at timestamp without time zone,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.project_users OWNER TO gbdmulti;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.projects OWNER TO gbdmulti;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO gbdmulti;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: rbac_audit_log; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.rbac_audit_log (
    id integer NOT NULL,
    action character varying(100) NOT NULL,
    permission_key character varying(100),
    target_user_id integer,
    changed_by integer,
    details text,
    ip_address inet,
    user_agent text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rbac_audit_log OWNER TO gbdmulti;

--
-- Name: rbac_audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.rbac_audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rbac_audit_log_id_seq OWNER TO gbdmulti;

--
-- Name: rbac_audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.rbac_audit_log_id_seq OWNED BY public.rbac_audit_log.id;


--
-- Name: relays; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.relays (
    id integer NOT NULL,
    mac_address character varying(17),
    relay_index integer NOT NULL,
    forced_state character varying(10) DEFAULT 'AUTO'::character varying
);


ALTER TABLE public.relays OWNER TO gbdmulti;

--
-- Name: relays_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.relays_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.relays_id_seq OWNER TO gbdmulti;

--
-- Name: relays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.relays_id_seq OWNED BY public.relays.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.role_permissions (
    role_name character varying(50) NOT NULL,
    permission_key character varying(100) NOT NULL,
    deleted_at timestamp without time zone,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    permission_type character varying(10) DEFAULT 'allow'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.role_permissions OWNER TO gbdmulti;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.roles (
    name character varying(50) NOT NULL,
    description character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.roles OWNER TO gbdmulti;

--
-- Name: schedules; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.schedules (
    id integer NOT NULL,
    relay_id integer,
    schedule_index integer NOT NULL,
    is_enabled boolean DEFAULT false,
    on_hour integer,
    on_minute integer,
    off_hour integer,
    off_minute integer
);


ALTER TABLE public.schedules OWNER TO gbdmulti;

--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.schedules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schedules_id_seq OWNER TO gbdmulti;

--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.schedules_id_seq OWNED BY public.schedules.id;


--
-- Name: software; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.software (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    software_type character varying(100),
    version character varying(50),
    license_info character varying(255),
    details jsonb DEFAULT '{}'::jsonb,
    status character varying(50) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.software OWNER TO gbdmulti;

--
-- Name: software_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.software_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.software_id_seq OWNER TO gbdmulti;

--
-- Name: software_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.software_id_seq OWNED BY public.software.id;


--
-- Name: student_profiles; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.student_profiles (
    user_id integer NOT NULL,
    school_name character varying(255),
    class character varying(50),
    section character varying(50),
    course character varying(100)
);


ALTER TABLE public.student_profiles OWNER TO gbdmulti;

--
-- Name: user_devices; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.user_devices (
    user_id integer NOT NULL,
    mac_address character varying(17) NOT NULL
);


ALTER TABLE public.user_devices OWNER TO gbdmulti;

--
-- Name: user_permission_overrides; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.user_permission_overrides (
    id integer NOT NULL,
    user_id integer,
    permission_key character varying(100),
    permission_type character varying(10) DEFAULT 'allow'::character varying,
    granted_by integer,
    granted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notes text,
    CONSTRAINT user_permission_overrides_permission_type_check CHECK (((permission_type)::text = ANY ((ARRAY['allow'::character varying, 'deny'::character varying])::text[])))
);


ALTER TABLE public.user_permission_overrides OWNER TO gbdmulti;

--
-- Name: user_permission_overrides_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.user_permission_overrides_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_permission_overrides_id_seq OWNER TO gbdmulti;

--
-- Name: user_permission_overrides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.user_permission_overrides_id_seq OWNED BY public.user_permission_overrides.id;


--
-- Name: user_permissions; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.user_permissions (
    user_id integer NOT NULL,
    page_name character varying(50) NOT NULL,
    deleted_at timestamp without time zone,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    permission_type character varying(10) DEFAULT 'allow'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_permissions OWNER TO gbdmulti;

--
-- Name: users; Type: TABLE; Schema: public; Owner: gbdmulti
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(150) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_super_admin boolean DEFAULT false,
    parent_id integer,
    name character varying(255),
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    first_name character varying(50),
    last_name character varying(50),
    mobile character varying(15),
    is_email_verified boolean DEFAULT false,
    email_verification_token character varying(100),
    mobile_verified boolean DEFAULT false,
    registration_ip inet,
    last_login_at timestamp without time zone,
    account_status character varying(20) DEFAULT 'active'::character varying,
    deleted_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO gbdmulti;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: gbdmulti
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO gbdmulti;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gbdmulti
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: device_status_log id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.device_status_log ALTER COLUMN id SET DEFAULT nextval('public.device_status_log_id_seq'::regclass);


--
-- Name: hardware id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.hardware ALTER COLUMN id SET DEFAULT nextval('public.hardware_id_seq'::regclass);


--
-- Name: permission_audit_log id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.permission_audit_log ALTER COLUMN id SET DEFAULT nextval('public.permission_audit_log_id_seq'::regclass);


--
-- Name: permission_discovery_log id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.permission_discovery_log ALTER COLUMN id SET DEFAULT nextval('public.permission_discovery_log_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: project_hardware id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_hardware ALTER COLUMN id SET DEFAULT nextval('public.project_hardware_id_seq'::regclass);


--
-- Name: project_software id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_software ALTER COLUMN id SET DEFAULT nextval('public.project_software_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: rbac_audit_log id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.rbac_audit_log ALTER COLUMN id SET DEFAULT nextval('public.rbac_audit_log_id_seq'::regclass);


--
-- Name: relays id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.relays ALTER COLUMN id SET DEFAULT nextval('public.relays_id_seq'::regclass);


--
-- Name: schedules id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.schedules ALTER COLUMN id SET DEFAULT nextval('public.schedules_id_seq'::regclass);


--
-- Name: software id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.software ALTER COLUMN id SET DEFAULT nextval('public.software_id_seq'::regclass);


--
-- Name: user_permission_overrides id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_permission_overrides ALTER COLUMN id SET DEFAULT nextval('public.user_permission_overrides_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: device_status_log; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.device_status_log (id, mac_address, status, previous_status, changed_at, reason) FROM stdin;
1	50:02:91:B3:DF:72	offline	updating	2025-07-29 21:39:04.694773	No heartbeat for 5+ minutes
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.devices (mac_address, device_id, project, current_fw_version, target_fw_version, build_date, last_seen, config, force_config_update, is_enabled, created_at, device_type, project_id, assigned_user, wifi_ssid, wifi_password, mqtt_host, mqtt_port, mqtt_username, mqtt_password, updated_at, status, status_updated_at, heartbeat_interval, is_updating, update_progress, update_started_at) FROM stdin;
60:55:F9:EC:C7:92	GBD20240500	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 12:48:23.772135+05:30	{"target": {}, "current": {}}	f	t	2025-07-29 12:48:23.772135+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CA:62	GBD20240433	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.552675+05:30	{"target": {}, "current": {}}	f	t	2025-07-27 20:45:01.479187+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CE:06	GBD20240312	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.650468+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.420619+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:01:00	GBD20240356	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.010313+05:30	{"target": {}, "current": {}}	f	t	2025-07-22 15:54:42.621346+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:7D:80	GBDFSSPNB0098	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.29334+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.650699+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:AD:F2	GBD20240476	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.491457+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.996323+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CB:CC	GBD20240220	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.61158+05:30	{"target": {}, "current": {}}	f	t	2025-07-27 14:28:45.153769+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:FC:D8	GBDFSSPNB0100	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.865854+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 17:02:03.256978+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:3A	GBD20240522	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.954895+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.632371+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:82:0A	GBD20240039	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.07061+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 12:41:38.702206+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:53:C4	GBD20240166	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.851211+05:30	{"target": {}, "current": {}}	f	t	2025-07-28 12:41:45.707543+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:59:70	GBD20240026	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.168669+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.890978+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:04	GBD20240244	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.290488+05:30	{"target": {}, "current": {}}	f	t	2025-07-28 08:10:43.417079+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:73:86	GBD20240320	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.440546+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.475973+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:41:94:26	GBDFSSPNB0242	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:41.53943+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.565942+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:BE	GBD20240448	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.766476+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.670934+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
48:3F:DA:4F:0B:89	GTOM1S0700	default	3.5.9	3.5.9	Jul 25 2025 08:42:04	2025-07-29 11:43:23.848683+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}, "current": {}}	f	t	2025-07-21 14:09:23.34162+05:30	EMS-4R	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:81:00	GBDFSSPNB0199	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.315258+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.673897+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C8:8A	GBD20240339	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.257347+05:30	{"target": {}, "current": {}}	f	t	2025-07-20 17:11:22.515236+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C8:E6	GBD20240344	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.380251+05:30	{"target": {}, "current": {}}	f	t	2025-07-24 19:04:14.716377+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:F2:80	GBD20240417	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.792742+05:30	{"target": {}, "current": {}}	f	t	2025-07-24 10:57:50.102063+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:86	GBD20240362	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.12232+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 17:35:44.855677+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:5A:A8	GBD20240071	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 11:46:24.902079+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.556444+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B5:14	GBDFSSPNB0136	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.578069+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.153966+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:FC:58	GBD20240398	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.841416+05:30	{"target": {}, "current": {}}	f	t	2025-07-28 12:45:17.815123+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:E2	GBDFSSPNB0138	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.512584+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.10047+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:5B:7E	GBD20240040	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.272967+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.936121+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:90	GBD20240258	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.169954+05:30	{"target": {}, "current": {}}	f	t	2025-07-28 13:43:21.496118+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5E:7A	GBD20240479	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.067497+05:30	{"target": {}, "current": {}}	f	t	2025-07-24 12:01:36.80173+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:5C:96	GBD20240152	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.322914+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.980783+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:5E:70	GBD20240165	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.347724+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.003449+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:A5:5E	GBD20240147	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.473298+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.118849+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:08	GBD20240269	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.338562+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.740203+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:0C	GBD20240277	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.386448+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.784603+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:71:2C	GBD20240161	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:09:26.964152+05:30	{"target": {}, "current": {}}	f	t	2025-07-29 13:40:20.661134+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:5B:B0	GBDFSSPNB0064	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:17:34.641699+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.958449+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:12	GBD20240278	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.435572+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.806557+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:A4	GBDFSSPNB0046	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.341271+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.409323+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:6B:EA	GBD20240088	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.543744+05:30	{"target": {}, "current": {}}	f	t	2025-07-22 20:02:45.988326+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:85:72	GBDFSSPNB0216	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.326005+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.695916+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:88:98	GBDFSSPNB0103	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.336827+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.71825+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:AD:36	GBDFSSPNB0052	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.480481+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.972137+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BB:AE	GBD20240284	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.720119+05:30	{"target": {}, "current": {}}	f	t	2025-07-26 20:18:48.174948+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BB:BA	GBDFSSPNB0086	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.744923+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.265486+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:7B:5C	GBD20240062	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.710396+05:30	{"target": {}, "current": {}}	f	t	2025-07-21 14:58:40.142957+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BE:AA	GBDFSSPNB0102	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.77018+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.288295+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:7E:B2	GBD20240095	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.809266+05:30	{"target": {}, "current": {}}	f	t	2025-07-23 19:24:11.627448+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:85:F4	GBD20240162	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.267613+05:30	{"target": {}, "current": {}}	f	t	2025-07-22 13:03:23.901446+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:01:04	GBD20240218	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.791804+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.369586+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
50:02:91:B3:DF:72	GTOM1S0700	default	2.0.0	3.5.4	Jul 29 2025 12:54:31	2025-07-29 13:13:33.20275+05:30	{"target": {}, "current": {}}	f	t	2025-07-21 18:09:19.390528+05:30	AMS-3S2R	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 20:30:51.126012	offline	2025-07-29 21:39:04.694773	60	t	-4946	2025-07-29 21:39:00.456253
D4:F9:8D:40:01:10	GBD20240263	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.942851+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.515651+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:C9:A4	GBD20240494	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.533347+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.216012+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CA:88	GBD20240209	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.572132+05:30	{"target": {}, "current": {}}	f	t	2025-07-29 10:45:30.572132+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C5:DA	GBDFSSPNB0115	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.161155+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 10:34:29.579899+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:81:34	GBD20240140	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.045493+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.152653+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CD:E4	GBDFSSPNB0079	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.603247+05:30	{"target": {}, "current": {}}	f	t	2025-07-21 18:07:43.489852+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D4:96	GBD20240432	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.805966+05:30	{"target": {}, "current": {}}	f	t	2025-07-29 10:45:30.805966+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D4:98	GBD20240455	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.815669+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.762752+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D5:0E	GBD20240442	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.873992+05:30	{"target": {}, "current": {}}	f	t	2025-07-22 20:02:39.123448+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:2F:C6	GBD20240470	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.087509+05:30	{"target": {}, "current": {}}	f	t	2025-07-27 12:26:30.198098+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B0:B6	GBDFSSPNB0223	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.502209+05:30	{"target": {}, "current": {}}	f	t	2025-07-25 11:06:37.992754+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B0:C2	GBDFSSPNB0117	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.513032+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.021344+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:58:DE	GBDFSSPNB0018	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.88971+05:30	{"target": {}, "current": {}}	f	t	2025-07-18 12:24:54.370032+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:1C	GBDFSSPNB0036	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.16092+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.028049+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:E8	GBDFSSPNB0333	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.48425+05:30	{"target": {}, "current": {}}	f	t	2025-07-25 11:06:40.852913+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BF:4A	GBDFSSPNB0127	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.941901+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.425962+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CB:D0	GBD20240490	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.635061+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.946967+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:86:50	GBD20240098	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.317243+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.306023+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:DB:04	GBD20240446	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.278108+05:30	{"target": {}, "current": {}}	f	t	2025-07-21 10:49:44.716707+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:A0	GBD20240456	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.746995+05:30	{"target": {}, "current": {}}	f	t	2025-07-20 00:06:59.34615+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:F7:74	GBD20240416	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.99109+05:30	{"target": {}, "current": {}}	f	t	2025-07-29 10:45:30.99109+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:A4:5E	GBDFSSPNB0184	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.448398+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.923823+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B1:0C	GBDFSSPNB0190	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.534844+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.064792+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BB:7A	GBDFSSPNB0080	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.694664+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.243148+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:1E	GBDFSSPNB0100	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:34.806729+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 17:17:51.177313+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:E6	GBDFSSPNB0143	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.893826+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.439053+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:63:52	GBD20240122	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.278212+05:30	{"target": {}, "current": {}}	f	t	2025-07-23 19:24:11.103917+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:87:BA	GBD20240107	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.464515+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 13:14:06.464609+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:03:D8	GBD20240262	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.097233+05:30	{"target": {}, "current": {}}	f	t	2025-07-26 11:47:38.034163+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:0E	GBD20240212	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.41091+05:30	{"target": {}, "current": {}}	f	t	2025-07-18 17:13:20.046694+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:1E	GBD20240210	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.509132+05:30	{"target": {}, "current": {}}	f	t	2025-07-20 19:37:17.364775+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:8C	GBD20240272	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.145773+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.251944+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E7:44	GBDFSSPNB0245	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.523153+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.599071+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:EE:FA	GBD20240400	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.744909+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.778193+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:63:88	GBD20240181	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.326486+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 10:35:36.453683+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:BC:0E	GBD20240489	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.410282+05:30	{"target": {}, "current": {}}	f	t	2025-07-17 12:51:20.842055+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:80:A0	GBD20240447	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.304384+05:30	{"target": {}, "current": {}}	f	t	2025-07-21 16:46:20.112311+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:89:64	GBD20240286	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.371467+05:30	{"target": {}, "current": {}}	f	t	2025-07-18 16:53:32.880997+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E4:1A	GBD20240223	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.4241+05:30	{"target": {}, "current": {}}	f	t	2025-07-24 11:05:08.287425+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:08	GBD20240405	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.035721+05:30	{"target": {}, "current": {}}	f	t	2025-07-29 10:45:34.035721+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:75:EA	GBD20240082	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.615008+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.844336+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:5A:12	GDB20240174	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.193094+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 12:52:52.774755+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:03:D0	GBD20240493	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.072691+05:30	{"target": {}, "current": {}}	f	t	2025-07-24 16:01:17.953048+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:87:D6	GBD20240087	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.512944+05:30	{"target": {}, "current": {}}	f	t	2025-07-23 11:14:24.515647+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:54:04	GBD20240074	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.87658+05:30	{"target": {}, "current": {}}	f	t	2025-07-26 16:00:18.117605+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:16	GBD20240266	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.459956+05:30	{"target": {}, "current": {}}	f	t	2025-07-21 15:44:59.754311+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:30	GBD20240249	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.605795+05:30	{"target": {}, "current": {}}	f	t	2025-07-20 17:11:29.248613+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:C7:2E	GBD20240440	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.513684+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.170516+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:7A	GBD20240371	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.698189+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.534545+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C5:46	GBDFSSPNB0074	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.063972+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.542301+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:DD:98	GBD20240467	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.302525+05:30	{"target": {}, "current": {}}	f	t	2025-07-24 17:09:28.896122+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:DD:B6	GBDFSSPNB0066	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.327048+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.467007+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:83:F8	GBD20240035	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.193474+05:30	{"target": {}, "current": {}}	f	t	2025-07-22 13:05:59.138543+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:55:7C	GBD20240157	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.005992+05:30	{"target": {}, "current": {}}	f	t	2025-07-29 10:45:39.005992+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:58	GBD20240283	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.725889+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.960521+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C8:C6	GBDFSSPNB0173	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.331134+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.74335+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:52:1C	GBD20240021	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.755241+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.647905+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:0E	GBDFSSPNB0255	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 12:59:22.185455+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.474439+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:A6:60	GBD20240422	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.459318+05:30	{"target": {}, "current": {}}	f	t	2025-07-25 19:52:35.73971+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:1A	GBDFSSPNB0167	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.434815+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.885289+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2B:65:B6	GBD20240183	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.834737+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.238866+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:65:F4	GBD20240084	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.37498+05:30	{"target": {}, "current": {}}	f	t	2025-07-23 19:24:11.197249+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:66:92	GBD20240124	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.400023+05:30	{"target": {}, "current": {}}	f	t	2025-07-23 11:14:23.489901+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:84:48	GBD20240130	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.218361+05:30	{"target": {}, "current": {}}	f	t	2025-07-29 10:45:38.218361+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:AB:70	GBD20240111	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.498832+05:30	{"target": {}, "current": {}}	f	t	2025-07-24 13:00:02.435522+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:B0:A2	GBD20240086	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.574676+05:30	{"target": {}, "current": {}}	f	t	2025-07-18 16:27:06.762553+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:C3:A2	GBD20240421	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.462859+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.058794+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C9:16	GBDFSSPNB0070	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.462111+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.810125+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CB:98	GBDFSSPNB0120	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.562355+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.900711+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CC:3E	GBDFSSPNB0186	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.818541+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.106887+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CE:B6	GBD20240437	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.84303+05:30	{"target": {}, "current": {}}	f	t	2025-07-25 19:52:37.186839+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CF:0A	GBDFSSPNB0104	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.916175+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.17444+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:D9:96	GBD20240222	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.156315+05:30	{"target": {}, "current": {}}	f	t	2025-07-21 15:19:31.888428+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:DA:80	GBDFSSPNB0206	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.253739+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 10:34:30.452202+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E7:AC	GBDFSSPNB0197	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.597356+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.665066+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B7:F0	GBD20240409	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:24:31.724826+05:30	{"target": {}, "current": {}}	f	t	2025-07-25 19:52:36.082917+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CA:84	GBD20240475	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.562459+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.262646+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:DA:14	GBDFSSPNB0209	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.923035+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 17:02:01.384035+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:39:94	GBD20240507	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.141673+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.334794+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:A3:FE	GBD20240292	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.437269+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.900771+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BE:D8	GBDFSSPNB0059	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.794879+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.311516+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:28	GBD20240389	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.210604+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 11:27:57.50741+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5F:9C	GBD20240485	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.237599+05:30	{"target": {}, "current": {}}	f	t	2025-07-20 17:11:25.903196+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:82:1C	GBD20240089	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.095216+05:30	{"target": {}, "current": {}}	f	t	2025-07-20 22:57:11.07533+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:22	GBD20240213	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.53328+05:30	{"target": {}, "current": {}}	f	t	2025-07-24 14:10:39.541343+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:5A	GBD20240232	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.749791+05:30	{"target": {}, "current": {}}	f	t	2025-07-21 18:58:05.253719+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:74	GBD20240203	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.951182+05:30	{"target": {}, "current": {}}	f	t	2025-07-21 12:02:17.95267+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:88:4C	GBD20240097	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 11:07:09.005664+05:30	{"target": {}, "current": {}}	f	t	2025-07-29 10:45:38.537291+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:2C	GBD20240377	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.881427+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.587831+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:C0:D4	GBD20240382	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.452567+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.035139+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:58:2E	GBD20240112	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.119522+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.845399+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:52:44	GBD20240125	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 12:31:53.760598+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 10:34:34.866319+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:03:F8	GBD20240373	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.168374+05:30	{"target": {}, "current": {}}	f	t	2025-07-22 21:23:21.607151+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D7:EE	GBD20240360	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.913183+05:30	{"target": {}, "current": {}}	f	t	2025-07-25 11:08:11.119337+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:03:FC	GBD20240279	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.21745+05:30	{"target": {}, "current": {}}	f	t	2025-07-25 19:52:44.174625+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:BD:7C	GBD20240453	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.421965+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:19.968318+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BE:E6	GBD20240496	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.819583+05:30	{"target": {}, "current": {}}	f	t	2025-07-27 12:26:31.59811+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C8:96	GBDFSSPNB0081	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.305912+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.721174+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CA:50	GBD20240431	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.543249+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.238106+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:54:44	GBD20240117	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.904755+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.713608+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CD:C2	GBD20240438	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.582086+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.285372+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D5:06	GBDFSSPNB0207	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.864229+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.853325+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CF:2A	GBDFSSPNB0091	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.963113+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.221058+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:00	GBDFSSPNB0030	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.962708+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.889806+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:14	GBD20240403	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.111213+05:30	{"target": {}, "current": {}}	f	t	2025-07-25 19:52:38.40137+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C6:4A	GBDFSSPNB0239	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 14:09:26.84772+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.67719+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:50	GBD20240221	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.702004+05:30	{"target": {}, "current": {}}	f	t	2025-07-17 14:26:42.168491+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:7C	GBD20240252	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.999771+05:30	{"target": {}, "current": {}}	f	t	2025-07-18 13:28:54.836218+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D5:02	GBDFSSPNB0113	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 11:16:00.180767+05:30	{"target": {}, "current": {}}	f	t	2025-07-29 11:16:00.180767+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:BE:1A	GBD20240430	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.432166+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:19.991063+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C5:66	GBDFSSPNB0055	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.112803+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.587318+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C5:CC	GBDFSSPNB0129	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.13694+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.60971+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C5:EC	GBDFSSPNB0034	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.184466+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.632263+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:01:16	GBD20240229	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:09:27.009976+05:30	{"target": {}, "current": {}}	f	t	2025-07-24 15:18:15.684448+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C8:8E	GBDFSSPNB0099	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 11:37:20.624264+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.699338+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:EC	GBD20240484	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:34.53426+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.318792+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:54	GBD20240528	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.216011+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.853239+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:5A:0A	GBD20240043	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.135114+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.510875+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:71:2E	GBDFSSPNB0326	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.567803+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.800647+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:F0:B6	GBD20240289	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:09:26.894672+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.800173+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CF:64	GBDFSSPNB0240	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.986981+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.2438+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:6B:AE	GBDFSSPNB0017	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.249103+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.560948+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:AC:16	GBDFSSPNB0178	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.469811+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.946339+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:DA:2A	GBDFSSPNB0149	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.22903+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.445024+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2B:6A:D6	GBDFSSPNB0329	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.859844+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.260711+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C8:D0	GBDFSSPNB0218	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.355765+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.765202+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:5F:34	GBD20240243	mqtt_registered	GoldBox v2 FW v4.0 19092023	\N	\N	2025-07-29 10:45:39.397241+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.028816+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:96:E2	GBDFSSPNB0123	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.404074+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.831598+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:9A:38	GBDFSSPNB0176	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.415338+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.854428+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B1:04	GBDFSSPNB0126	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.524094+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.043191+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CD:F4	GBD20240452	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.622064+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.352462+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:D2:E0	GBDFSSPNB0198	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:18:10.566036+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.31175+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CF:02	GBDFSSPNB0002	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.868389+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.129184+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:04	GBDFSSPNB0016	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.0115+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.935036+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:30	GBDFSSPNB0336	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.906184+05:30	{"target": {}, "current": {}}	f	t	2025-07-18 16:08:43.224839+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:76	GBDFSSPNB0325	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.415304+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.032312+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:7C	GBDFSSPNB0334	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.463809+05:30	{"target": {}, "current": {}}	f	t	2025-07-20 17:22:48.9893+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:36	GBDFSSPNB0177	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.638502+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.063675+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:7E:C8	GBD20240011	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.832827+05:30	{"target": {}, "current": {}}	f	t	2025-07-25 19:52:42.052755+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:80:6E	GBD20240159	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.957348+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.085688+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:01:08	GBDFSSPNB0061	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.840072+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.422486+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D4:8C	GBDFSSPNB0175	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:09:26.822917+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.738655+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D4:FC	GBDFSSPNB0241	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.854501+05:30	{"target": {}, "current": {}}	f	t	2025-07-21 18:22:10.449663+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:C3:C2	GBDFSSPNB0043	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.472756+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.081754+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:36:1A	GBDFSSPNB0069	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.13087+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.312511+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CE:02	GBDFSSPNB0056	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.640901+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.398029+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D4:84	GBD20240425	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.786854+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.715898+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:BE:A4	GBDFSSPNB0260	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.442288+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.012241+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:F7:A6	GBDFSSPNB0107	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.000735+05:30	{"target": {}, "current": {}}	f	t	2025-07-18 12:24:51.571627+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:C8:EE	GBDFSSPNB0215	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.523724+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.193248+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:C4	GBD20240372	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:18:02.920174+05:30	{"target": {}, "current": {}}	f	t	2025-07-25 19:52:45.304385+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:2C	GBDFSSPNB0058	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.235195+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.072866+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CB:F2	GBDFSSPNB0224	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.683552+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.991198+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CC:28	GBDFSSPNB0035	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.768396+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.061267+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:D2:5E	GBDFSSPNB0250	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.034417+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.289409+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CC:36	GBDFSSPNB0085	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.794298+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.083846+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CF:04	GBDFSSPNB0068	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.893059+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.151942+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:D9:08	GBDFSSPNB0345	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.132531+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.378456+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E4:68	GBDFSSPNB0054	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.473757+05:30	{"target": {}, "current": {}}	f	t	2025-07-18 12:24:54.075522+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E8:10	GBDFSSPNB0041	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.646421+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.710207+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:C6:AE	GBDFSSPNB0065	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.483821+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.103915+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:C4	GBDFSSPNB0125	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.794629+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.347581+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:14	GBD20240517	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.386+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.83928+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:DD:D2	GBDFSSPNB0112	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 14:09:26.870889+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.489296+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:10	GBDFSSPNB0161	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:34.731046+05:30	{"target": {}, "current": {}}	f	t	2025-07-20 00:07:02.852227+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:C7:00	GBDFSSPNB0140	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.494098+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.126337+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:B4	GBD20240017	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.756702+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:20.648047+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:03:C4	GBDFSSPNB0013	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.029201+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.102022+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:1C:54	GBD20240468	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.0484+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.146179+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BF:10	GBDFSSPNB0087	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.917156+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.402627+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:94	GBD20240246	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.727461+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.60273+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:5B:4E	GBD20240173	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.247906+05:30	{"target": {}, "current": {}}	f	t	2025-07-27 12:26:38.871629+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BF:68	GBDFSSPNB0131	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.966554+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.44855+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C5:32	GBDFSSPNB0026	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.03992+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.520211+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C8:FE	GBDFSSPNB0101	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.408032+05:30	{"target": {}, "current": {}}	f	t	2025-07-24 15:12:16.067673+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E4:E2	GBDFSSPNB0204	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.498388+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.577665+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:EE:B2	GBDFSSPNB0330	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.720856+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.755215+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:FC:08	GBDFSSPNB0192	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.817037+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.822793+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:C7:04	GBDFSSPNB0106	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.503699+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.148155+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:0C	GBDFSSPNB0011	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.086309+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.981362+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:30	GBDFSSPNB0019	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.263897+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.094458+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:34	GBDFSSPNB0001	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.288362+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "icont", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:24.116401+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:3C	GBDFSSPNB0023	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.360278+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.18285+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:0A	GBDFSSPNB0027	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.061316+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.957616+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:44	GBDFSSPNB0200	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.669459+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.464891+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CD:F6	GBDFSSPNB0037	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.631401+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.375372+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CB:E2	GBDFSSPNB0154	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.659844+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.969139+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CD:F2	GBDFSSPNB0084	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.612548+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.330397+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:70	GBDFSSPNB0156	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.688543+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.511427+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:8E	GBDFSSPNB0119	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.707636+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.55774+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C9:18	GBDFSSPNB0042	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.487597+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.832059+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CD:E0	GBDFSSPNB0171	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.593587+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.307803+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:A0	GBDFSSPNB0005	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.292045+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.365012+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:56	GBDFSSPNB0114	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.679068+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.488175+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:9A	GBDFSSPNB0150	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.737226+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.625418+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D2:38	GBD20240445	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.777203+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.693353+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CB:FC	GBDFSSPNB0094	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:32.711908+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.014632+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:D9:CC	GBDFSSPNB0298	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.181206+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.400795+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E8:34	GBDFSSPNB0108	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.670339+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.732857+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:28	GBD20240384	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.855857+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.565128+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:D1:F2	GBDFSSPNB0096	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.010195+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.266266+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:EE:AA	GBDFSSPNB0077	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:18:42.433864+05:30	{"target": {}, "current": {}}	f	t	2025-07-19 10:36:21.780451+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:86:52	GBD20240006	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.342798+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:27.328478+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:58:FA	GBDFSSPNB0025	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 11:27:59.329631+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.866975+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D1:92	GBD20240466	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.717124+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.58022+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:03:AA	GBD20240004	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.019714+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:21.078632+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:0D:94	GBD20240254	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.038962+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.124054+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:CE:26	GBDFSSPNB0201	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.659888+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.442461+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:F8	GBDFSSPNB0202	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.635427+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.21295+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:F2	GBDFSSPNB0169	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.585691+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.168019+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5B:04	GBDFSSPNB0193	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.685342+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.258335+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:0A	GBDFSSPNB0331	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.658151+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.428935+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:BC	GBDFSSPNB0187	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.739402+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.303119+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:C0	GBDFSSPNB0236	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.768718+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.325436+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:D8	GBDFSSPNB0142	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.819323+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.371637+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:DA	GBDFSSPNB0141	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.844288+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.394354+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:E8	GBDFSSPNB0137	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.918081+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.461163+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:EA	GBDFSSPNB0134	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.94279+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.48336+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:59:16	GBD20240135	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.143978+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.867882+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:01:0A	GBDFSSPNB0033	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.867157+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.445123+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:4E	GBDFSSPNB0031	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.191459+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.830796+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:0C	GBDFSSPNB0296	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:09:26.917953+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.451611+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:EA	GBDFSSPNB0252	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:34.50992+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.296639+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:F2	GBDFSSPNB0244	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:34.559456+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.34069+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:02	GBDFSSPNB0324	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.584357+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.362858+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:04	GBDFSSPNB0212	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.609359+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.384818+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:08	GBDFSSPNB0229	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:34.633822+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.406503+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:BA	GBDFSSPNB0230	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.711097+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.280698+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:DE:76	GBD20240413	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.942658+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.966382+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:86	GBDFSSPNB0075	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.487915+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.077949+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:18	GBDFSSPNB0203	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.4106+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.861493+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:33:2E	GBDFSSPNB0076	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.109089+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.258889+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:78:FE	GBDFSSPNB0132	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.663045+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.085502+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D5:2E	GBD20240483	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.893499+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.899193+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:2C	GBDFSSPNB0139	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.557711+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.996043+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:0E	GBDFSSPNB0243	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.311626+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.773084+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:79:00	GBDFSSPNB0160	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.688118+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.107866+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5F:96	GBDFSSPNB0246	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.214124+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.706475+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:6A:86	GBDFSSPNB0118	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.47089+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.735503+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:01:20	GBDFSSPNB0063	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.047239+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.58364+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:1C	GBDFSSPNB0145	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.459646+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.90822+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:24	GBDFSSPNB0121	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.508584+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.952172+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:36:0E	GBDFSSPNB0060	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.119941+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.281146+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:EC	GBDFSSPNB0194	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.967801+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.505712+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:EE	GBDFSSPNB0172	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.992369+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.528909+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:40:BC	GBD20240532	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.152312+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.357271+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:F0	GBDFSSPNB0165	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.01729+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.551005+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5E:6E	GBDFSSPNB0181	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.042319+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.572712+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5E:7C	GBDFSSPNB0185	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.092539+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.594598+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5E:82	GBDFSSPNB0237	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.117471+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.616892+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:79:04	GBDFSSPNB0211	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.712847+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.129499+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5F:A6	GBDFSSPNB0235	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.287177+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.751297+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:88:FC	GBD20240418	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.359411+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.763453+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:8C:44	GBD20240310	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.382456+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.786437+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E7:82	GBD20240287	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.572582+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.642917+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E7:FE	GBD20240350	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.621969+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.687396+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:5E	GBD20240201	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.773121+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.982573+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D4:EC	GBDFSSPNB0217	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.835021+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.808141+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:F6:B8	GBD20240211	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.952434+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.98839+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:9E:BE	GBDFSSPNB0214	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:41.466064+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.498405+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:58:E4	GBD20240387	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.913992+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.845156+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:02	GBD20240379	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.987155+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.912263+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:46	GBD20240402	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.434696+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.250009+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:2E:1E	GBDFSSPNB0144	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.077655+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.212029+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:53:40	GBD20240376	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.194446+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.448121+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:88:A2	GBD20240347	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.348523+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.741271+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:93:5C	GBD20240487	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.393266+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.809123+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B4:50	GBD20240435	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.556202+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.109238+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:DA:16	GBD20240247	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.205043+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.423339+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:F7:12	GBDFSSPNB0082	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.962221+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.011706+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:12	GBD20240215	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.755779+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.496754+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:3C	GBD20240303	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.979984+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.654525+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:44	GBD20240299	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.087872+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.742859+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:60	GBD20240533	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.265798+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.899162+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:6E	GBD20240410	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.39028+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.009855+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5C:DC	GBD20240508	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.869634+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.416933+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:6A	GBD20240523	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 12:27:08.098851+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.965775+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:6C	GBD20240527	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:09:26.941291+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.987917+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:22:2E	GBD20240224	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.058114+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.168302+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:5E	GBD20240388	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.459439+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.272168+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:1C	GBD20240543	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.780233+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.519476+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:20	GBD20240529	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.831599+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.541923+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:3E	GBD20240541	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.004947+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.676681+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:42	GBD20240526	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.060835+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.721005+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:48	GBD20240327	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.140307+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.786802+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:5E	GBD20240530	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.240928+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.875766+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:68	GBD20240539	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.315523+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.943813+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:78	GBD20240521	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.439105+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.055105+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:60:D0	GBD20240182	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.254372+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.624434+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:63:5A	GBD20240029	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.302078+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.646787+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:64:6A	GBD20240053	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.350943+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.669172+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:68:A6	GBD20240180	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.446829+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.713619+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:6B:5E	GBD20240064	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.494883+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.757074+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D5:1A	GBD20240512	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.883691+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.877094+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:80:48	GBD20240019	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.932642+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.064071+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:80:B2	GBD20240134	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.995278+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.107709+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:80:F6	GBD20240369	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.021877+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.130508+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:83:06	GBD20240058	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.119766+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.17599+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:6B:A2	GBD20240085	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.519228+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.778805+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:58:44	GBD20240150	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.087707+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.467617+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:4A:8A	GBD20240025	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.938696+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.331571+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:4C:C0	GBD20240094	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.963927+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.354464+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:54:B2	GBD20240114	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.014042+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.40114+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:54:C0	GBD20240380	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.038693+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.423609+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:55:D0	GBD20240143	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.0631+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.445572+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2B:86:4E	GBD20240013	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.884504+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:26.283263+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:59:C0	GBD20240041	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.111797+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.489108+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:5D:64	GBD20240176	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.206736+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.578486+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:60:B6	GBD20240115	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.230761+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.600902+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:80:3E	GBD20240005	mqtt_registered	GoldBox v2 FW v3.9 15022024	\N	\N	2025-07-29 10:45:37.906101+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:27.041927+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:83:5E	GBD20240075	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.144341+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.198978+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:83:E2	GBD20240104	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.168717+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.233783+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:85:CA	GBD20240172	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.243018+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.259472+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:DB:0E	GBDFSSPNB0124	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.932744+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.944163+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:86:5E	GBD20240126	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.367809+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.351476+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:88:A2	GBD20240049	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.56213+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.46585+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:53:56	GBD20240008	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.826184+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:27.69161+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:54:FE	GBD20240146	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.930747+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.735772+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:55:26	GBD20240073	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.955865+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.757368+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:86:32	GBD20240002	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.291799+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:27.282835+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:52:A8	GBD20240118	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.989289+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.378364+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:67:B6	GBD20240141	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.423172+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.691789+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:7F:B6	GBD20240037	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.857449+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.998238+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:76:EC	GBD20240042	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.638653+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.86549+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:78:B6	GBD20240133	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.662737+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.888049+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:7B:36	GBD20240137	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.685948+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.909992+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:7D:4A	GBD20240065	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.733163+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.931914+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:7D:98	GBD20240113	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.760276+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.953924+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:7D:9E	GBD20240102	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.784322+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.97605+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:71:5A	GBD20240346	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.591815+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.822679+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D7:82	GBDFSSPNB0010	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.903336+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.921829+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:86:B6	GBD20240158	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.41639+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.39687+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:4C:30	GBD20240412	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.586199+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.490369+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:4E:A4	GBD20240142	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.659728+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.558611+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:55:6E	GBD20240149	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.981112+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.779675+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:CA:4C	GBD20240091	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.670585+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.253319+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:D2:04	GBD20240068	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.694736+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.27616+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:01:06	GBD20240482	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.815718+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.39241+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:F7:5E	GBDFSSPNB0110	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.981472+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.056445+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:86:82	GBD20240023	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.391567+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.374107+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:87:98	GBD20240001	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.440858+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:27.419862+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:87:CA	GBD20240155	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.488922+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.442845+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:4D:30	GBD20240103	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.611209+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.512449+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:4D:8C	GBD20240024	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.635222+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.535651+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:4F:70	GBD20240077	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.682509+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.581021+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:50:C8	GBD20240178	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.706617+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.603711+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:55:BC	GBD20240066	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.030717+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.801396+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:57:C6	GBD20240003	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.05806+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:27.82353+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2F:07:0A	GBD20240128	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.718729+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.298637+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5E:8A	GBDFSSPNB0231	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.166177+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.661861+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D4:B8	GBDFSSPNB0092	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.825244+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.785867+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:D4:EE	GBD20240427	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:30.844813+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:20.830621+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EC:F7:4E	GBDFSSPNB0327	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:30.971926+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.034232+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:2B:A2	GBD20240396	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.067847+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.19038+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:30:80	GBDFSSPNB0095	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.098333+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.234595+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:53:E4	GBD20240542	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.205207+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.47087+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:73:06	GBD20240501	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.260083+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.582558+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5E:84	GBDFSSPNB0191	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.142351+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.63956+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:4C:B0	GBD20240524	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.162733+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.3807+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:73:08	GBDFSSPNB0072	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 14:24:47.991564+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.604905+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:4C:D0	GBD20240534	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.173309+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.403784+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:4C:EE	GBD20240538	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.183813+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.426363+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:54:04	GBD20240537	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.216116+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.49322+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:5A:BC	GBD20240540	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.227006+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.516263+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:61:68	GBD20240531	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.238098+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.538628+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:75:76	GBD20240471	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.282253+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.627838+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:A0:76	GBD20240486	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.426353+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:21.877978+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B1:16	GBD20240478	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.545632+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.087039+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B4:70	GBD20240383	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.56725+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.131945+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B6:B8	GBD20240274	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.588635+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.176202+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B7:9C	GBD20240477	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.611631+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.198278+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:B8:14	GBDFSSPNB0111	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.65983+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.220425+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BE:F4	GBD20240381	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.844675+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.334836+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BE:FA	GBD20240461	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.868884+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.357407+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:BF:02	GBD20240457	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:31.893353+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.380147+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C5:62	GBD20240297	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.08779+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.564677+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CB:5E	GBD20240187	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.512808+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.854885+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C0:E4	GBD20240316	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:31.990617+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.470782+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C2:0C	GBD20240195	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.015115+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.497679+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C6:24	GBD20240296	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.209117+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.654525+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:C9:0A	GBD20240335	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.434041+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.787764+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CB:78	GBDFSSPNB0049	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.537771+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.87814+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CB:CA	GBD20240394	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.58655+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:22.92424+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:D6:84	GBD20240423	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.107174+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.356129+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CC:00	GBD20240424	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.739922+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.038249+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:CF:10	GBD20240368	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:32.940211+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.197662+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:D2:E6	GBDFSSPNB0158	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.082778+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.333902+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:DF:94	GBD20240264	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.37551+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.511351+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E7:5C	GBD20240414	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.548074+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.620998+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E0:EE	GBD20240535	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:33.400061+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.534198+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:ED:E4:3E	GBD20240472	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:33.449118+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:23.555994+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:18	GBDFSSPNB0039	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.13554+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.005342+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:20	GBD20240240	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.18625+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.050221+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:44	GBD20240386	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.409824+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.228015+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:36	GBD20240367	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.312583+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.138482+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:3A	GBD20240340	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.3361+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.159968+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:59:42	GBD20240390	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.385102+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.205574+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:4A	GBDFSSPNB0332	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.165989+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.808379+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:62	GBD20240525	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.290833+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.921623+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:36	GBD20240131	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:34.931073+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.609789+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:40	GBD20240536	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.032402+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.6989+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:46	GBD20240406	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.114904+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:24.76524+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:EC	GBD20240514	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.5366+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.123661+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:EE	GBD20240505	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.561365+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.145563+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:F6	GBDFSSPNB0253	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:35.610728+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.190646+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5A:FE	GBDFSSPNB0188	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:35.660417+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.236163+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:12	GBD20240510	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:48:20.214484+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.817226+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5E:92	GBD20240465	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.19057+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.684672+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:5F:A0	GBD20240519	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.26231+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.72895+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:10	GBD20240464	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.33631+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.795048+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:20	GBD20240463	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.484301+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.930424+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:2A	GBD20240511	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.533463+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:25.974076+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:30	GBDFSSPNB0232	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.587671+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.018562+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:79:06	GBD20240520	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.737666+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.151205+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2B:5A:4E	GBD20240129	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.762022+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.173031+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2B:5E:5A	GBD20240047	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.786702+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.194867+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2B:62:46	GBD20240121	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.810603+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.216965+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
60:55:F9:EF:61:34	GBDFSSPNB0247	mqtt_registered	GoldBox v2 FW v4.0 05062024	\N	\N	2025-07-29 10:45:36.613933+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.041763+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2B:94:10	GBD20240109	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:36.913854+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.308575+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:5A:64	GBD20240145	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.158645+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:26.533436+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2D:80:0A	GDB20240083	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:37.881379+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.019777+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:51:E4	GBD20240167	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.731212+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.626064+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:52:32	GBD20240063	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:38.778724+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.669442+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:B2:7C	GBD20240090	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.598699+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.185487+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:03:F4	GBD20240271	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.120486+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.606043+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:03:F6	GBD20240207	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.144475+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.628209+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:03:FA	GBD20240248	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.192892+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.651051+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:46	GBD20240216	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.678309+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.93867+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:0A	GBD20240193	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.362774+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.761778+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:1C	GBD20240237	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.484801+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.828249+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:A3:04	GBD20240060	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.448583+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.09645+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:C6:DA	GBD20240067	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.645887+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.230627+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:00:F2	GBD20240202	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.743277+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.32297+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:24	GBD20240280	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.558458+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.849211+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:38	GBD20240194	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.630102+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.894158+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:44	GBD20240231	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.654506+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.91658+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:06	GBD20240267	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.314926+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.717841+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:66	GBD20240219	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.821138+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.02607+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:6A	GBD20240276	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.875816+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.070489+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:6C	GBD20240242	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.900695+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.093506+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:80	GBDFSSPNB0045	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.049348+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.184271+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:5A:8A	GBD20240055	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.223279+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:27.913582+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:60:92	GBD20240076	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.423717+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.074094+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:AE:36	GBD20240164	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.523355+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.141+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:AE:7E	GBD20240027	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.548037+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.163326+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
68:67:25:2E:B2:8C	GBD20240014	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.62226+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "iconttech2022", "wifi_ssid": "IcOnT", "mqtt_server": "itlmqtt.itlems.com"}}	t	t	2025-07-17 10:46:28.207885+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:01:0C	GBD20240206	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.892169+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.469045+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:01:0E	GBD20240214	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.916748+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.492743+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:00:FE	GBD20240046	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.767549+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.346695+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:03:FE	GBD20240245	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.241883+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.673246+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:02	GBD20240259	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.265997+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.695123+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:9A	GBDFSSPNB0050	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.217845+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.296572+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:01:12	GBD20240205	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:39.967487+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.538357+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:AE	GBD20240351	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.366348+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.431677+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:41:00:7A	GBD20240375	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.490084+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.520668+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:41:93:3E	GBD20240321	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.514678+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.543202+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:41:9F:1C	GBD20240374	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.564748+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.58841+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:60	GBD20240188	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.797075+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.004326+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:68	GBD20240236	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.845466+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.04807+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:78	GBD20240401	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.975639+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.138861+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:7E	GBD20240363	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.024971+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.161273+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:84	GBD20240343	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.098301+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.229435+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:94	GBD20240358	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.193359+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.274484+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:9E	GBD20240331	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.267706+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.341999+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:A2	GBDFSSPNB0057	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.316842+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.387404+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:59:EC	GBD20240317	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.416377+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.453939+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:01:18	GBD20240191	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.021217+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.560828+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:28	GBD20240261	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.582412+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:28.87159+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:72	GBD20240192	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:40.926454+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.115859+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:82	GBDFSSPNB0048	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.074202+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.206925+05:30	unknown	1	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
D4:F9:8D:40:04:9C	GBD20240364	mqtt_registered	GoldBox v2 FW v4.0 15022024	\N	\N	2025-07-29 10:45:41.242778+05:30	{"target": {"mqtt_pass": "Qwerty", "mqtt_port": 1883, "mqtt_user": "Qwerty", "wifi_pass": "DefaultPassword", "wifi_ssid": "Veon", "mqtt_server": "itlmqtt.itlems.com"}}	f	t	2025-07-17 10:46:29.319222+05:30	unknown	\N	\N	\N	\N	mqtt.ssplcms.com	1883	\N	\N	2025-07-29 18:04:56.849454	offline	2025-07-29 18:13:52.045885	60	f	0	\N
\.


--
-- Data for Name: employee_profiles; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.employee_profiles (user_id, company_name, employee_govt_id, address, designation, department) FROM stdin;
\.


--
-- Data for Name: firmware_manifest; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.firmware_manifest (version, path, uploaded_at, device_type) FROM stdin;
3.5.9	/firmware/MINI_3.5.9.bin	2025-07-24 11:13:45.831153+05:30	EMS-4R
\.


--
-- Data for Name: hardware; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.hardware (id, name, hardware_type, model, serial_number, details, status, created_at, updated_at) FROM stdin;
1	Server-Primary	Server	Dell PowerEdge R740	SRV-001	{"cpu": "Intel Xeon", "ram": "64GB", "storage": "2TB SSD"}	active	2025-07-29 14:01:20.648093	2025-07-29 14:01:20.648093
2	Router-Main	Network	Cisco ISR 4321	RTR-001	{"ports": 24, "speed": "1Gbps"}	active	2025-07-29 14:01:20.648093	2025-07-29 14:01:20.648093
3	UPS-Backup	Power	APC Smart-UPS 3000	UPS-001	{"runtime": "30min", "capacity": "3000VA"}	active	2025-07-29 14:01:20.648093	2025-07-29 14:01:20.648093
\.


--
-- Data for Name: permission_audit_log; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.permission_audit_log (id, user_id, target_user_id, permission_key, action, old_value, new_value, changed_by, changed_at, reason) FROM stdin;
\.


--
-- Data for Name: permission_discovery_log; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.permission_discovery_log (id, permission_name, discovered_at, source_file, source_function, status) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.permissions (id, key, display_name, description, category, auto_discovered, display_order, icon, endpoint, created_at, deleted_at, updated_at) FROM stdin;
62	admin.access	Admin Access	Full administrative access	admin	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
63	permission_admin_only	Admin Only	Administrative privileges	admin	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
64	page_rbac_management	RBAC Management	Access RBAC management page	page	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
65	page_dashboard	Dashboard	Access dashboard page	page	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
66	page_device_list	Device List	Access device list page	page	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
67	page_device_status	Device Status	Access device status page	page	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
68	page_firmware_manager	Firmware Manager	Access firmware manager	page	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
69	page_tester	Device Tester	Access device tester	page	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
70	page_project_management	Project Management	Access project management	page	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
71	page_user_list	User Management	Access user management	page	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
72	page_role_management	Role Management	Access role management	page	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
73	users.create	Create Users	Create new users	user	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
74	users.edit	Edit Users	Edit existing users	user	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
75	users.delete	Delete Users	Delete users	user	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
76	users.view	View Users	View user information	user	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
77	roles.create	Create Roles	Create new roles	role	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
78	roles.edit	Edit Roles	Edit existing roles	role	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
79	roles.delete	Delete Roles	Delete roles	role	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
80	roles.view	View Roles	View role information	role	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
81	devices.create	Create Devices	Create new devices	device	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
82	devices.edit	Edit Devices	Edit device settings	device	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
83	devices.delete	Delete Devices	Delete devices	device	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
84	devices.control	Control Devices	Control device operations	device	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
85	projects.create	Create Projects	Create new projects	project	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
86	projects.edit	Edit Projects	Edit existing projects	project	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
87	projects.delete	Delete Projects	Delete projects	project	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
88	projects.manage_users	Manage Project Users	Manage project user assignments	project	f	0	\N	\N	2025-07-30 09:19:50.049629	\N	2025-07-30 09:19:50.049629
137	permissions.discover	Discover Permissions	Auto-discover permissions	permission	f	0	\N	\N	2025-07-30 09:33:51.919512	\N	2025-07-30 09:33:51.919512
138	permissions.manage	Manage Permissions	Manage system permissions	permission	f	0	\N	\N	2025-07-30 09:33:51.919512	\N	2025-07-30 09:33:51.919512
140	system.configure	System Configuration	Configure system settings	system	f	0	\N	\N	2025-07-30 09:33:51.919512	\N	2025-07-30 09:33:51.919512
141	audit.view	View Audit Logs	View system audit logs	audit	f	0	\N	\N	2025-07-30 09:33:51.919512	\N	2025-07-30 09:33:51.919512
142	audit.export	Export Audit Logs	Export audit logs	audit	f	0	\N	\N	2025-07-30 09:33:51.919512	\N	2025-07-30 09:33:51.919512
182	system.admin.full_access	System.Admin.Full Access	Auto-discovered: system.admin.full_access	system	t	0	\N	\N	2025-07-30 09:40:56.905274	\N	2025-07-30 09:40:56.905274
183	roles.manage	Roles.Manage	Auto-discovered: roles.manage	roles	t	0	\N	\N	2025-07-30 09:40:56.905274	\N	2025-07-30 09:40:56.905274
184	hardware.view	Hardware.View	Auto-discovered: hardware.view	hardware	t	0	\N	\N	2025-07-30 09:40:56.905274	\N	2025-07-30 09:40:56.905274
185	software.manage	Software.Manage	Auto-discovered: software.manage	software	t	0	\N	\N	2025-07-30 09:40:56.905274	\N	2025-07-30 09:40:56.905274
\.


--
-- Data for Name: project_hardware; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.project_hardware (id, project_id, hardware_id, assigned_by, assigned_at, status, notes) FROM stdin;
1	1	1	1	2025-07-29 14:01:20.659834	active	Initial setup
2	1	2	1	2025-07-29 14:01:20.659834	active	Initial setup
\.


--
-- Data for Name: project_software; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.project_software (id, project_id, software_id, assigned_by, assigned_at, license_key, status, notes) FROM stdin;
\.


--
-- Data for Name: project_users; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.project_users (project_id, user_id, role_name, deleted_at, updated_at) FROM stdin;
1	4	customer	\N	2025-07-30 09:07:27.144155
1	2	admin	\N	2025-07-30 09:07:27.144155
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.projects (id, name, description, created_at) FROM stdin;
1	Device Management	Device Management Project	2025-07-29 16:50:18.284882
2	GTOM SOUTH	\N	2025-07-29 16:50:18.284882
\.


--
-- Data for Name: rbac_audit_log; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.rbac_audit_log (id, action, permission_key, target_user_id, changed_by, details, ip_address, user_agent, created_at) FROM stdin;
\.


--
-- Data for Name: relays; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.relays (id, mac_address, relay_index, forced_state) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.role_permissions (role_name, permission_key, deleted_at, updated_at, permission_type, created_at) FROM stdin;
admin	page_dashboard	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	page_rbac_management	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	page_device_list	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	page_tester	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	page_device_status	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	page_firmware_manager	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	page_user_list	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	page_role_management	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	page_project_management	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	users.create	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	users.edit	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	users.view	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	roles.view	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	permissions.discover	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	devices.create	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	devices.edit	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	devices.control	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	projects.create	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	projects.edit	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
admin	projects.manage_users	\N	2025-07-30 11:48:11.117861	allow	2025-07-30 11:48:11.117861
super_admin	admin.access	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	permission_admin_only	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	page_rbac_management	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	page_dashboard	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	page_device_list	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	page_device_status	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	page_firmware_manager	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	page_tester	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	page_project_management	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	page_user_list	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	page_role_management	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	users.create	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	users.edit	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	users.delete	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	users.view	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	roles.create	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	roles.edit	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	roles.delete	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	roles.view	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	devices.create	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	devices.edit	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	devices.delete	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	devices.control	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
manager	page_dashboard	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
manager	page_device_list	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
manager	page_device_status	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
manager	page_tester	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
manager	page_user_list	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
manager	users.view	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
manager	devices.edit	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
manager	devices.control	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
user	page_dashboard	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
user	page_device_list	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
user	page_tester	\N	2025-07-30 09:38:02.617846	allow	2025-07-30 09:38:02.617846
super_admin	permissions.discover	\N	2025-07-30 09:40:43.651287	allow	2025-07-30 09:40:43.651287
super_admin	permissions.manage	\N	2025-07-30 09:40:43.651287	allow	2025-07-30 09:40:43.651287
super_admin	system.configure	\N	2025-07-30 09:40:43.651287	allow	2025-07-30 09:40:43.651287
super_admin	audit.view	\N	2025-07-30 09:40:43.651287	allow	2025-07-30 09:40:43.651287
super_admin	audit.export	\N	2025-07-30 09:40:43.651287	allow	2025-07-30 09:40:43.651287
super_admin	projects.create	\N	2025-07-30 09:40:43.651287	allow	2025-07-30 09:40:43.651287
super_admin	projects.edit	\N	2025-07-30 09:40:43.651287	allow	2025-07-30 09:40:43.651287
super_admin	projects.delete	\N	2025-07-30 09:40:43.651287	allow	2025-07-30 09:40:43.651287
super_admin	projects.manage_users	\N	2025-07-30 09:40:43.651287	allow	2025-07-30 09:40:43.651287
user	page_device_status	\N	2025-07-30 09:40:43.651287	allow	2025-07-30 09:40:43.651287
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.roles (name, description, created_at, updated_at) FROM stdin;
admin	Has all permissions.	2025-07-29 14:01:20.304777	2025-07-29 14:01:20.308681
viewer	Has limited, view-only permissions by default.	2025-07-29 14:01:20.304777	2025-07-29 14:01:20.308681
customer	Standard customer account with specific permissions.	2025-07-29 14:01:20.304777	2025-07-29 14:01:20.308681
employee	Standard employee account.	2025-07-29 14:01:20.304777	2025-07-29 14:01:20.308681
student	Student account with limited access.	2025-07-29 14:01:20.304777	2025-07-29 14:01:20.308681
teacher	Teacher account with specific permissions.	2025-07-29 14:01:20.304777	2025-07-29 14:01:20.308681
super_admin	Global system owner with all permissions.	2025-07-29 14:01:20.304777	2025-07-29 14:01:20.308681
manager	Management level access to user data	2025-07-30 09:33:51.919512	2025-07-30 09:33:51.919512
user	Basic user access to assigned features	2025-07-30 09:33:51.919512	2025-07-30 09:33:51.919512
\.


--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.schedules (id, relay_id, schedule_index, is_enabled, on_hour, on_minute, off_hour, off_minute) FROM stdin;
\.


--
-- Data for Name: software; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.software (id, name, software_type, version, license_info, details, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: student_profiles; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.student_profiles (user_id, school_name, class, section, course) FROM stdin;
\.


--
-- Data for Name: user_devices; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.user_devices (user_id, mac_address) FROM stdin;
4	68:67:25:2D:87:98
4	48:3F:DA:4F:0B:89
\.


--
-- Data for Name: user_permission_overrides; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.user_permission_overrides (id, user_id, permission_key, permission_type, granted_by, granted_at, notes) FROM stdin;
\.


--
-- Data for Name: user_permissions; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.user_permissions (user_id, page_name, deleted_at, updated_at, permission_type, created_at) FROM stdin;
3	tester_page	\N	2025-07-30 09:07:27.154443	allow	2025-07-30 09:31:38.392011
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: gbdmulti
--

COPY public.users (id, email, password_hash, created_at, is_super_admin, parent_id, name, updated_at, first_name, last_name, mobile, is_email_verified, email_verification_token, mobile_verified, registration_ip, last_login_at, account_status, deleted_at) FROM stdin;
4	rpi2moniter@gmail.com	$2b$12$F07uuFgBola6gMyHY1nLXuy7YafUMxEXK1OIGpqhnpwxvKPzhsxfy	2025-07-27 17:45:28.303149+05:30	f	\N	rpi2moniter	2025-07-29 14:01:20.29399	rpi2moniter	\N	\N	f	\N	f	\N	\N	active	\N
3	goyalnishant36@gmail.com	$2b$12$nbzOHjCr4wWM.HjiqDe/WeAc8Y/d1ak2W6hjYmxUC85sY6RnWBUtK	2025-07-24 12:49:48.249128+05:30	f	1	goyalnishant36	2025-07-29 14:01:20.29399	goyalnishant36	\N	\N	f	\N	f	\N	\N	active	\N
1	nishantgoyal@ssplcms.com	$2b$12$tDDy/WfR.T2MRWyLNAKgYe2bPjy3jGFPBSmePagJUho0HcghzP6bC	2025-07-17 10:29:51.543451+05:30	t	\N	nishantgoyal	2025-07-29 14:01:20.29399	nishantgoyal	\N	\N	f	\N	f	\N	\N	active	\N
2	amankj1572003@gmail.com	$2b$12$vEhUNsVQD/9qMvJZKe3Xz.vXq9Jz3wnXs7Yw/eU64W46z5aPi82X6	2025-07-19 10:36:02.411106+05:30	f	\N	amankj1572003	2025-07-29 14:01:20.29399	amankj1572003	\N	\N	f	\N	f	\N	\N	active	\N
\.


--
-- Name: device_status_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.device_status_log_id_seq', 1, true);


--
-- Name: hardware_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.hardware_id_seq', 3, true);


--
-- Name: permission_audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.permission_audit_log_id_seq', 1, false);


--
-- Name: permission_discovery_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.permission_discovery_log_id_seq', 1, false);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.permissions_id_seq', 495, true);


--
-- Name: project_hardware_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.project_hardware_id_seq', 2, true);


--
-- Name: project_software_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.project_software_id_seq', 1, false);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.projects_id_seq', 2, true);


--
-- Name: rbac_audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.rbac_audit_log_id_seq', 1, false);


--
-- Name: relays_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.relays_id_seq', 1, false);


--
-- Name: schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.schedules_id_seq', 1, false);


--
-- Name: software_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.software_id_seq', 1, false);


--
-- Name: user_permission_overrides_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.user_permission_overrides_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gbdmulti
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: device_status_log device_status_log_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.device_status_log
    ADD CONSTRAINT device_status_log_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (mac_address);


--
-- Name: employee_profiles employee_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.employee_profiles
    ADD CONSTRAINT employee_profiles_pkey PRIMARY KEY (user_id);


--
-- Name: firmware_manifest firmware_manifest_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.firmware_manifest
    ADD CONSTRAINT firmware_manifest_pkey PRIMARY KEY (version);


--
-- Name: hardware hardware_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.hardware
    ADD CONSTRAINT hardware_pkey PRIMARY KEY (id);


--
-- Name: hardware hardware_serial_number_key; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.hardware
    ADD CONSTRAINT hardware_serial_number_key UNIQUE (serial_number);


--
-- Name: permission_audit_log permission_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.permission_audit_log
    ADD CONSTRAINT permission_audit_log_pkey PRIMARY KEY (id);


--
-- Name: permission_discovery_log permission_discovery_log_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.permission_discovery_log
    ADD CONSTRAINT permission_discovery_log_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_key_key; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_key_key UNIQUE (key);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: project_hardware project_hardware_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_hardware
    ADD CONSTRAINT project_hardware_pkey PRIMARY KEY (id);


--
-- Name: project_hardware project_hardware_project_id_hardware_id_key; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_hardware
    ADD CONSTRAINT project_hardware_project_id_hardware_id_key UNIQUE (project_id, hardware_id);


--
-- Name: project_software project_software_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_software
    ADD CONSTRAINT project_software_pkey PRIMARY KEY (id);


--
-- Name: project_software project_software_project_id_software_id_key; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_software
    ADD CONSTRAINT project_software_project_id_software_id_key UNIQUE (project_id, software_id);


--
-- Name: project_users project_users_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_pkey PRIMARY KEY (project_id, user_id);


--
-- Name: projects projects_name_key; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_name_key UNIQUE (name);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: rbac_audit_log rbac_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.rbac_audit_log
    ADD CONSTRAINT rbac_audit_log_pkey PRIMARY KEY (id);


--
-- Name: relays relays_mac_address_relay_index_key; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.relays
    ADD CONSTRAINT relays_mac_address_relay_index_key UNIQUE (mac_address, relay_index);


--
-- Name: relays relays_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.relays
    ADD CONSTRAINT relays_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_name, permission_key);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (name);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_relay_id_schedule_index_key; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_relay_id_schedule_index_key UNIQUE (relay_id, schedule_index);


--
-- Name: software software_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.software
    ADD CONSTRAINT software_pkey PRIMARY KEY (id);


--
-- Name: student_profiles student_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.student_profiles
    ADD CONSTRAINT student_profiles_pkey PRIMARY KEY (user_id);


--
-- Name: user_devices user_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT user_devices_pkey PRIMARY KEY (user_id, mac_address);


--
-- Name: user_permission_overrides user_permission_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_permission_overrides
    ADD CONSTRAINT user_permission_overrides_pkey PRIMARY KEY (id);


--
-- Name: user_permission_overrides user_permission_overrides_user_id_permission_key_key; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_permission_overrides
    ADD CONSTRAINT user_permission_overrides_user_id_permission_key_key UNIQUE (user_id, permission_key);


--
-- Name: user_permissions user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT user_permissions_pkey PRIMARY KEY (user_id, page_name);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_device_status_log_mac; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_device_status_log_mac ON public.device_status_log USING btree (mac_address);


--
-- Name: idx_devices_assigned_user; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_devices_assigned_user ON public.devices USING btree (assigned_user);


--
-- Name: idx_devices_device_id; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_devices_device_id ON public.devices USING btree (device_id);


--
-- Name: idx_devices_device_type; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_devices_device_type ON public.devices USING btree (device_type);


--
-- Name: idx_devices_last_seen; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_devices_last_seen ON public.devices USING btree (last_seen);


--
-- Name: idx_devices_mac_address; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_devices_mac_address ON public.devices USING btree (mac_address);


--
-- Name: idx_devices_project; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_devices_project ON public.devices USING btree (project);


--
-- Name: idx_devices_project_id; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_devices_project_id ON public.devices USING btree (project_id);


--
-- Name: idx_devices_status; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_devices_status ON public.devices USING btree (status);


--
-- Name: idx_devices_status_updated; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_devices_status_updated ON public.devices USING btree (status_updated_at);


--
-- Name: idx_permissions_deleted; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_permissions_deleted ON public.permissions USING btree (deleted_at);


--
-- Name: idx_project_users_deleted; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_project_users_deleted ON public.project_users USING btree (deleted_at);


--
-- Name: idx_project_users_role; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_project_users_role ON public.project_users USING btree (role_name);


--
-- Name: idx_project_users_user; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_project_users_user ON public.project_users USING btree (user_id);


--
-- Name: idx_role_permissions_deleted; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_role_permissions_deleted ON public.role_permissions USING btree (deleted_at);


--
-- Name: idx_role_permissions_permission; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_role_permissions_permission ON public.role_permissions USING btree (permission_key);


--
-- Name: idx_role_permissions_role; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_role_permissions_role ON public.role_permissions USING btree (role_name);


--
-- Name: idx_user_permission_overrides_permission_key; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_user_permission_overrides_permission_key ON public.user_permission_overrides USING btree (permission_key);


--
-- Name: idx_user_permission_overrides_user_id; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_user_permission_overrides_user_id ON public.user_permission_overrides USING btree (user_id);


--
-- Name: idx_user_permissions_deleted; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_user_permissions_deleted ON public.user_permissions USING btree (deleted_at);


--
-- Name: idx_users_account_status; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_users_account_status ON public.users USING btree (account_status);


--
-- Name: idx_users_email_verified; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_users_email_verified ON public.users USING btree (is_email_verified);


--
-- Name: idx_users_mobile; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE UNIQUE INDEX idx_users_mobile ON public.users USING btree (mobile) WHERE (mobile IS NOT NULL);


--
-- Name: idx_users_parent_id; Type: INDEX; Schema: public; Owner: gbdmulti
--

CREATE INDEX idx_users_parent_id ON public.users USING btree (parent_id);


--
-- Name: device_status_log device_status_log_mac_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.device_status_log
    ADD CONSTRAINT device_status_log_mac_address_fkey FOREIGN KEY (mac_address) REFERENCES public.devices(mac_address) ON DELETE CASCADE;


--
-- Name: devices devices_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: devices fk_devices_project; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT fk_devices_project FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: employee_profiles fk_user; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.employee_profiles
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: student_profiles fk_user; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.student_profiles
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_devices fk_user_devices_user; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT fk_user_devices_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: permission_audit_log permission_audit_log_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.permission_audit_log
    ADD CONSTRAINT permission_audit_log_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- Name: permission_audit_log permission_audit_log_target_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.permission_audit_log
    ADD CONSTRAINT permission_audit_log_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.users(id);


--
-- Name: permission_audit_log permission_audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.permission_audit_log
    ADD CONSTRAINT permission_audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: project_hardware project_hardware_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_hardware
    ADD CONSTRAINT project_hardware_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id);


--
-- Name: project_hardware project_hardware_hardware_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_hardware
    ADD CONSTRAINT project_hardware_hardware_id_fkey FOREIGN KEY (hardware_id) REFERENCES public.hardware(id) ON DELETE CASCADE;


--
-- Name: project_hardware project_hardware_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_hardware
    ADD CONSTRAINT project_hardware_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_software project_software_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_software
    ADD CONSTRAINT project_software_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id);


--
-- Name: project_software project_software_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_software
    ADD CONSTRAINT project_software_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_software project_software_software_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_software
    ADD CONSTRAINT project_software_software_id_fkey FOREIGN KEY (software_id) REFERENCES public.software(id) ON DELETE CASCADE;


--
-- Name: project_users project_users_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_users project_users_role_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_role_name_fkey FOREIGN KEY (role_name) REFERENCES public.roles(name);


--
-- Name: project_users project_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: rbac_audit_log rbac_audit_log_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.rbac_audit_log
    ADD CONSTRAINT rbac_audit_log_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id);


--
-- Name: relays relays_mac_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.relays
    ADD CONSTRAINT relays_mac_address_fkey FOREIGN KEY (mac_address) REFERENCES public.devices(mac_address) ON DELETE CASCADE;


--
-- Name: schedules schedules_relay_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_relay_id_fkey FOREIGN KEY (relay_id) REFERENCES public.relays(id) ON DELETE CASCADE;


--
-- Name: user_devices user_devices_mac_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT user_devices_mac_address_fkey FOREIGN KEY (mac_address) REFERENCES public.devices(mac_address) ON DELETE CASCADE;


--
-- Name: user_devices user_devices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT user_devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_permission_overrides user_permission_overrides_granted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_permission_overrides
    ADD CONSTRAINT user_permission_overrides_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES public.users(id);


--
-- Name: user_permission_overrides user_permission_overrides_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_permission_overrides
    ADD CONSTRAINT user_permission_overrides_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_permissions user_permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.user_permissions
    ADD CONSTRAINT user_permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id);


--
-- Name: users users_parent_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: gbdmulti
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_parent_id_fkey1 FOREIGN KEY (parent_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

