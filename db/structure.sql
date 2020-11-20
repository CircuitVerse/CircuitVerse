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
-- Name: ahoy_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ahoy_events (
    id bigint NOT NULL,
    visit_id bigint,
    user_id bigint,
    name character varying,
    properties json,
    "time" timestamp without time zone
);


--
-- Name: ahoy_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ahoy_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ahoy_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ahoy_events_id_seq OWNED BY public.ahoy_events.id;


--
-- Name: ahoy_visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ahoy_visits (
    id bigint NOT NULL,
    visit_token character varying,
    visitor_token character varying,
    user_id bigint,
    ip character varying,
    user_agent text,
    referrer text,
    referring_domain character varying,
    landing_page text,
    browser character varying,
    os character varying,
    device_type character varying,
    country character varying,
    region character varying,
    city character varying,
    utm_source character varying,
    utm_medium character varying,
    utm_term character varying,
    utm_content character varying,
    utm_campaign character varying,
    app_version character varying,
    os_version character varying,
    platform character varying,
    started_at timestamp without time zone
);


--
-- Name: ahoy_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ahoy_visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ahoy_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ahoy_visits_id_seq OWNED BY public.ahoy_visits.id;


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcements (
    id bigint NOT NULL,
    body text,
    link text,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.announcements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignments (
    id bigint NOT NULL,
    name character varying,
    deadline timestamp without time zone NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_id bigint,
    status character varying,
    grading_scale integer DEFAULT 0,
    grades_finalized boolean DEFAULT false,
    restrictions json DEFAULT '"[]"'::json
);


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assignments_id_seq OWNED BY public.assignments.id;


--
-- Name: collaborations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collaborations (
    id bigint NOT NULL,
    user_id bigint,
    project_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: collaborations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collaborations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collaborations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collaborations_id_seq OWNED BY public.collaborations.id;


--
-- Name: commontator_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commontator_comments (
    id integer NOT NULL,
    creator_type character varying,
    creator_id integer,
    editor_type character varying,
    editor_id integer,
    thread_id integer NOT NULL,
    body text NOT NULL,
    deleted_at timestamp without time zone,
    cached_votes_up integer DEFAULT 0,
    cached_votes_down integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id bigint
);


--
-- Name: commontator_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.commontator_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commontator_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commontator_comments_id_seq OWNED BY public.commontator_comments.id;


--
-- Name: commontator_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commontator_subscriptions (
    id integer NOT NULL,
    subscriber_type character varying NOT NULL,
    subscriber_id integer NOT NULL,
    thread_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: commontator_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.commontator_subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commontator_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commontator_subscriptions_id_seq OWNED BY public.commontator_subscriptions.id;


--
-- Name: commontator_threads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commontator_threads (
    id integer NOT NULL,
    commontable_type character varying,
    commontable_id integer,
    closed_at timestamp without time zone,
    closer_type character varying,
    closer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: commontator_threads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.commontator_threads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commontator_threads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commontator_threads_id_seq OWNED BY public.commontator_threads.id;


--
-- Name: custom_mails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.custom_mails (
    id bigint NOT NULL,
    subject text,
    content text,
    sent boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint
);


--
-- Name: custom_mails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.custom_mails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_mails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.custom_mails_id_seq OWNED BY public.custom_mails.id;


--
-- Name: featured_circuits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.featured_circuits (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id bigint
);


--
-- Name: featured_circuits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.featured_circuits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: featured_circuits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.featured_circuits_id_seq OWNED BY public.featured_circuits.id;


--
-- Name: forum_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_categories (
    id integer NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    color character varying DEFAULT '000000'::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: forum_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_categories_id_seq OWNED BY public.forum_categories.id;


--
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_posts (
    id integer NOT NULL,
    forum_thread_id integer,
    user_id integer,
    body text,
    solved boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: forum_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_posts_id_seq OWNED BY public.forum_posts.id;


--
-- Name: forum_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_subscriptions (
    id integer NOT NULL,
    forum_thread_id integer,
    user_id integer,
    subscription_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: forum_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_subscriptions_id_seq OWNED BY public.forum_subscriptions.id;


--
-- Name: forum_threads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_threads (
    id integer NOT NULL,
    forum_category_id integer,
    user_id integer,
    title character varying NOT NULL,
    slug character varying NOT NULL,
    forum_posts_count integer DEFAULT 0,
    pinned boolean DEFAULT false,
    solved boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: forum_threads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_threads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_threads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_threads_id_seq OWNED BY public.forum_threads.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id bigint NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grades (
    id bigint NOT NULL,
    grade character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id bigint,
    user_id bigint,
    assignment_id bigint,
    remarks character varying
);


--
-- Name: grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grades_id_seq OWNED BY public.grades.id;


--
-- Name: group_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_members (
    id bigint NOT NULL,
    group_id bigint,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: group_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_members_id_seq OWNED BY public.group_members.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    name character varying,
    mentor_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_members_count integer
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: mailkick_opt_outs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mailkick_opt_outs (
    id bigint NOT NULL,
    email character varying,
    user_type character varying,
    user_id bigint,
    active boolean DEFAULT true NOT NULL,
    reason character varying,
    list character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: mailkick_opt_outs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mailkick_opt_outs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailkick_opt_outs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mailkick_opt_outs_id_seq OWNED BY public.mailkick_opt_outs.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    target_type character varying NOT NULL,
    target_id bigint NOT NULL,
    notifiable_type character varying NOT NULL,
    notifiable_id bigint NOT NULL,
    key character varying NOT NULL,
    group_type character varying,
    group_id bigint,
    group_owner_id integer,
    notifier_type character varying,
    notifier_id bigint,
    parameters text,
    opened_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: pending_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pending_invitations (
    id bigint NOT NULL,
    group_id bigint,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pending_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pending_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pending_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pending_invitations_id_seq OWNED BY public.pending_invitations.id;


--
-- Name: push_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_subscriptions (
    id bigint NOT NULL,
    endpoint character varying,
    p256dh character varying,
    auth character varying,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: push_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.push_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: push_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.push_subscriptions_id_seq OWNED BY public.push_subscriptions.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: stars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stars (
    id bigint NOT NULL,
    user_id bigint,
    project_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stars_id_seq OWNED BY public.stars.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id bigint NOT NULL,
    target_type character varying NOT NULL,
    target_id bigint NOT NULL,
    key character varying NOT NULL,
    subscribing boolean DEFAULT true NOT NULL,
    subscribing_to_email boolean DEFAULT true NOT NULL,
    subscribed_at timestamp without time zone,
    unsubscribed_at timestamp without time zone,
    subscribed_to_email_at timestamp without time zone,
    unsubscribed_to_email_at timestamp without time zone,
    optional_targets text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taggings (
    id bigint NOT NULL,
    project_id bigint,
    tag_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taggings_id_seq OWNED BY public.taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    provider character varying,
    uid character varying,
    profile_picture_file_name character varying,
    profile_picture_content_type character varying,
    profile_picture_file_size bigint,
    profile_picture_updated_at timestamp without time zone,
    admin boolean DEFAULT false,
    country character varying,
    educational_institute character varying,
    subscribed boolean DEFAULT true
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    id integer NOT NULL,
    votable_type character varying,
    votable_id integer,
    voter_type character varying,
    voter_id integer,
    vote_flag boolean,
    vote_scope character varying,
    vote_weight integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: ahoy_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_events ALTER COLUMN id SET DEFAULT nextval('public.ahoy_events_id_seq'::regclass);


--
-- Name: ahoy_visits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_visits ALTER COLUMN id SET DEFAULT nextval('public.ahoy_visits_id_seq'::regclass);


--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments ALTER COLUMN id SET DEFAULT nextval('public.assignments_id_seq'::regclass);


--
-- Name: collaborations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collaborations ALTER COLUMN id SET DEFAULT nextval('public.collaborations_id_seq'::regclass);


--
-- Name: commontator_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commontator_comments ALTER COLUMN id SET DEFAULT nextval('public.commontator_comments_id_seq'::regclass);


--
-- Name: commontator_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commontator_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.commontator_subscriptions_id_seq'::regclass);


--
-- Name: commontator_threads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commontator_threads ALTER COLUMN id SET DEFAULT nextval('public.commontator_threads_id_seq'::regclass);


--
-- Name: custom_mails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_mails ALTER COLUMN id SET DEFAULT nextval('public.custom_mails_id_seq'::regclass);


--
-- Name: featured_circuits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.featured_circuits ALTER COLUMN id SET DEFAULT nextval('public.featured_circuits_id_seq'::regclass);


--
-- Name: forum_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_categories ALTER COLUMN id SET DEFAULT nextval('public.forum_categories_id_seq'::regclass);


--
-- Name: forum_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts ALTER COLUMN id SET DEFAULT nextval('public.forum_posts_id_seq'::regclass);


--
-- Name: forum_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.forum_subscriptions_id_seq'::regclass);


--
-- Name: forum_threads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_threads ALTER COLUMN id SET DEFAULT nextval('public.forum_threads_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades ALTER COLUMN id SET DEFAULT nextval('public.grades_id_seq'::regclass);


--
-- Name: group_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members ALTER COLUMN id SET DEFAULT nextval('public.group_members_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: mailkick_opt_outs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailkick_opt_outs ALTER COLUMN id SET DEFAULT nextval('public.mailkick_opt_outs_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: pending_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_invitations ALTER COLUMN id SET DEFAULT nextval('public.pending_invitations_id_seq'::regclass);


--
-- Name: push_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.push_subscriptions_id_seq'::regclass);


--
-- Name: stars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stars ALTER COLUMN id SET DEFAULT nextval('public.stars_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings ALTER COLUMN id SET DEFAULT nextval('public.taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Name: ahoy_events ahoy_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_events
    ADD CONSTRAINT ahoy_events_pkey PRIMARY KEY (id);


--
-- Name: ahoy_visits ahoy_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ahoy_visits
    ADD CONSTRAINT ahoy_visits_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: collaborations collaborations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collaborations
    ADD CONSTRAINT collaborations_pkey PRIMARY KEY (id);


--
-- Name: commontator_comments commontator_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commontator_comments
    ADD CONSTRAINT commontator_comments_pkey PRIMARY KEY (id);


--
-- Name: commontator_subscriptions commontator_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commontator_subscriptions
    ADD CONSTRAINT commontator_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: commontator_threads commontator_threads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commontator_threads
    ADD CONSTRAINT commontator_threads_pkey PRIMARY KEY (id);


--
-- Name: custom_mails custom_mails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.custom_mails
    ADD CONSTRAINT custom_mails_pkey PRIMARY KEY (id);


--
-- Name: featured_circuits featured_circuits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.featured_circuits
    ADD CONSTRAINT featured_circuits_pkey PRIMARY KEY (id);


--
-- Name: forum_categories forum_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_categories
    ADD CONSTRAINT forum_categories_pkey PRIMARY KEY (id);


--
-- Name: forum_posts forum_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT forum_posts_pkey PRIMARY KEY (id);


--
-- Name: forum_subscriptions forum_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_subscriptions
    ADD CONSTRAINT forum_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: forum_threads forum_threads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_threads
    ADD CONSTRAINT forum_threads_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: grades grades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (id);


--
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: mailkick_opt_outs mailkick_opt_outs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailkick_opt_outs
    ADD CONSTRAINT mailkick_opt_outs_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: pending_invitations pending_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pending_invitations
    ADD CONSTRAINT pending_invitations_pkey PRIMARY KEY (id);


--
-- Name: push_subscriptions push_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_subscriptions
    ADD CONSTRAINT push_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: stars stars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stars
    ADD CONSTRAINT stars_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: index_ahoy_events_on_name_and_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_name_and_time ON public.ahoy_events USING btree (name, "time");


--
-- Name: index_ahoy_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_user_id ON public.ahoy_events USING btree (user_id);


--
-- Name: index_ahoy_events_on_visit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_events_on_visit_id ON public.ahoy_events USING btree (visit_id);


--
-- Name: index_ahoy_visits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ahoy_visits_on_user_id ON public.ahoy_visits USING btree (user_id);


--
-- Name: index_ahoy_visits_on_visit_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ahoy_visits_on_visit_token ON public.ahoy_visits USING btree (visit_token);


--
-- Name: index_assignments_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assignments_on_group_id ON public.assignments USING btree (group_id);


--
-- Name: index_collaborations_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collaborations_on_project_id ON public.collaborations USING btree (project_id);


--
-- Name: index_collaborations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collaborations_on_user_id ON public.collaborations USING btree (user_id);


--
-- Name: index_commontator_comments_on_c_id_and_c_type_and_t_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commontator_comments_on_c_id_and_c_type_and_t_id ON public.commontator_comments USING btree (creator_id, creator_type, thread_id);


--
-- Name: index_commontator_comments_on_cached_votes_down; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commontator_comments_on_cached_votes_down ON public.commontator_comments USING btree (cached_votes_down);


--
-- Name: index_commontator_comments_on_cached_votes_up; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commontator_comments_on_cached_votes_up ON public.commontator_comments USING btree (cached_votes_up);


--
-- Name: index_commontator_comments_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commontator_comments_on_parent_id ON public.commontator_comments USING btree (parent_id);


--
-- Name: index_commontator_comments_on_thread_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commontator_comments_on_thread_id_and_created_at ON public.commontator_comments USING btree (thread_id, created_at);


--
-- Name: index_commontator_subscriptions_on_s_id_and_s_type_and_t_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_commontator_subscriptions_on_s_id_and_s_type_and_t_id ON public.commontator_subscriptions USING btree (subscriber_id, subscriber_type, thread_id);


--
-- Name: index_commontator_subscriptions_on_thread_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commontator_subscriptions_on_thread_id ON public.commontator_subscriptions USING btree (thread_id);


--
-- Name: index_commontator_threads_on_c_id_and_c_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_commontator_threads_on_c_id_and_c_type ON public.commontator_threads USING btree (commontable_id, commontable_type);


--
-- Name: index_custom_mails_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_custom_mails_on_user_id ON public.custom_mails USING btree (user_id);


--
-- Name: index_featured_circuits_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_featured_circuits_on_project_id ON public.featured_circuits USING btree (project_id);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON public.friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_type_and_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type_and_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_type, sluggable_id);


--
-- Name: index_grades_on_assignment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_assignment_id ON public.grades USING btree (assignment_id);


--
-- Name: index_grades_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_project_id ON public.grades USING btree (project_id);


--
-- Name: index_grades_on_project_id_and_assignment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_grades_on_project_id_and_assignment_id ON public.grades USING btree (project_id, assignment_id);


--
-- Name: index_grades_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_user_id ON public.grades USING btree (user_id);


--
-- Name: index_group_members_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_members_on_group_id ON public.group_members USING btree (group_id);


--
-- Name: index_group_members_on_group_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_group_members_on_group_id_and_user_id ON public.group_members USING btree (group_id, user_id);


--
-- Name: index_group_members_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_members_on_user_id ON public.group_members USING btree (user_id);


--
-- Name: index_groups_on_mentor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_mentor_id ON public.groups USING btree (mentor_id);


--
-- Name: index_mailkick_opt_outs_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailkick_opt_outs_on_email ON public.mailkick_opt_outs USING btree (email);


--
-- Name: index_mailkick_opt_outs_on_user_type_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailkick_opt_outs_on_user_type_and_user_id ON public.mailkick_opt_outs USING btree (user_type, user_id);


--
-- Name: index_notifications_on_group_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_group_owner_id ON public.notifications USING btree (group_owner_id);


--
-- Name: index_notifications_on_group_type_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_group_type_and_group_id ON public.notifications USING btree (group_type, group_id);


--
-- Name: index_notifications_on_notifiable_type_and_notifiable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_notifiable_type_and_notifiable_id ON public.notifications USING btree (notifiable_type, notifiable_id);


--
-- Name: index_notifications_on_notifier_type_and_notifier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_notifier_type_and_notifier_id ON public.notifications USING btree (notifier_type, notifier_id);


--
-- Name: index_notifications_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_target_type_and_target_id ON public.notifications USING btree (target_type, target_id);


--
-- Name: index_pending_invitations_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pending_invitations_on_group_id ON public.pending_invitations USING btree (group_id);


--
-- Name: index_pending_invitations_on_group_id_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pending_invitations_on_group_id_and_email ON public.pending_invitations USING btree (group_id, email);


--
-- Name: index_push_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_push_subscriptions_on_user_id ON public.push_subscriptions USING btree (user_id);


--
-- Name: index_stars_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stars_on_project_id ON public.stars USING btree (project_id);


--
-- Name: index_stars_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stars_on_user_id ON public.stars USING btree (user_id);


--
-- Name: index_stars_on_user_id_and_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stars_on_user_id_and_project_id ON public.stars USING btree (user_id, project_id);


--
-- Name: index_subscriptions_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_key ON public.subscriptions USING btree (key);


--
-- Name: index_subscriptions_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_target_type_and_target_id ON public.subscriptions USING btree (target_type, target_id);


--
-- Name: index_subscriptions_on_target_type_and_target_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subscriptions_on_target_type_and_target_id_and_key ON public.subscriptions USING btree (target_type, target_id, key);


--
-- Name: index_taggings_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_project_id ON public.taggings USING btree (project_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tag_id ON public.taggings USING btree (tag_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_votes_on_votable_id_and_votable_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_votable_id_and_votable_type_and_vote_scope ON public.votes USING btree (votable_id, votable_type, vote_scope);


--
-- Name: index_votes_on_voter_id_and_voter_type_and_vote_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_voter_id_and_voter_type_and_vote_scope ON public.votes USING btree (voter_id, voter_type, vote_scope);


--
-- Name: stars fk_rails_510b95ed0a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stars
    ADD CONSTRAINT fk_rails_510b95ed0a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: taggings fk_rails_9fcd2e236b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taggings
    ADD CONSTRAINT fk_rails_9fcd2e236b FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20171106170810'),
('20171106175519'),
('20171107043137'),
('20171107043836'),
('20171107044938'),
('20171107114943'),
('20171107130407'),
('20171109145421'),
('20171109175504'),
('20171110110459'),
('20171110111153'),
('20171110142854'),
('20171110143208'),
('20171111123333'),
('20171111123458'),
('20171111125800'),
('20171111132829'),
('20171114061142'),
('20171115173434'),
('20171209173825'),
('20171210122013'),
('20171210123204'),
('20171210200041'),
('20171213124254'),
('20171215103540'),
('20171215121720'),
('20171217075003'),
('20180115065041'),
('20180204144441'),
('20181010165821'),
('20190110050909'),
('20190303074605'),
('20190303074630'),
('20190303180900'),
('20190303182743'),
('20190314204600'),
('20190330051946'),
('20190330200336'),
('20190526125442'),
('20190609113412'),
('20190623061901'),
('20190628090620'),
('20190723154732'),
('20190728103204'),
('20190804064213'),
('20191207032656'),
('20191208045111'),
('20200604034729'),
('20200604103111'),
('20200604103211'),
('20200622174739'),
('20200627120620'),
('20200627120951'),
('20200710140439'),
('20200710140440'),
('20200710140441'),
('20200710140442'),
('20200930135954'),
('20201013035451'),
('20201021112654'),
('20201027012455'),
('20201027023111');


