--
-- PostgreSQL database dump
--

\restrict mS0sq1wkU9mEkIY0QhDBVwK0rmXd81gdhAtlDhNE03nl4DOTMh9nX4CU2cxwAMq

-- Dumped from database version 18.3 (Homebrew)
-- Dumped by pg_dump version 18.3 (Homebrew)

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
-- Name: approval_status; Type: TYPE; Schema: public; Owner: lapac
--

CREATE TYPE public.approval_status AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public.approval_status OWNER TO lapac;

--
-- Name: approver_type; Type: TYPE; Schema: public; Owner: lapac
--

CREATE TYPE public.approver_type AS ENUM (
    'MANAGER',
    'ROLE',
    'USER'
);


ALTER TYPE public.approver_type OWNER TO lapac;

--
-- Name: expense_status; Type: TYPE; Schema: public; Owner: lapac
--

CREATE TYPE public.expense_status AS ENUM (
    'DRAFT',
    'SUBMITTED',
    'PENDING',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public.expense_status OWNER TO lapac;

--
-- Name: rule_type; Type: TYPE; Schema: public; Owner: lapac
--

CREATE TYPE public.rule_type AS ENUM (
    'SEQUENTIAL',
    'PERCENTAGE',
    'SPECIFIC',
    'HYBRID'
);


ALTER TYPE public.rule_type OWNER TO lapac;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: lapac
--

CREATE TYPE public.user_role AS ENUM (
    'ADMIN',
    'MANAGER',
    'EMPLOYEE'
);


ALTER TYPE public.user_role OWNER TO lapac;

--
-- Name: update_timestamp(); Type: FUNCTION; Schema: public; Owner: lapac
--

CREATE FUNCTION public.update_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_timestamp() OWNER TO lapac;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: lapac
--

CREATE TABLE public.companies (
    id bigint NOT NULL,
    name text NOT NULL,
    default_currency character varying(10) NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.companies OWNER TO lapac;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: lapac
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.companies_id_seq OWNER TO lapac;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lapac
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: expense_approvals; Type: TABLE; Schema: public; Owner: lapac
--

CREATE TABLE public.expense_approvals (
    id bigint NOT NULL,
    expense_id bigint,
    step_id bigint,
    approver_id bigint,
    status public.approval_status DEFAULT 'PENDING'::public.approval_status,
    comment text,
    decided_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.expense_approvals OWNER TO lapac;

--
-- Name: expense_approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: lapac
--

CREATE SEQUENCE public.expense_approvals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.expense_approvals_id_seq OWNER TO lapac;

--
-- Name: expense_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lapac
--

ALTER SEQUENCE public.expense_approvals_id_seq OWNED BY public.expense_approvals.id;


--
-- Name: expense_items; Type: TABLE; Schema: public; Owner: lapac
--

CREATE TABLE public.expense_items (
    id bigint NOT NULL,
    expense_id bigint,
    name text,
    quantity integer,
    unit_price numeric(10,2),
    total numeric(10,2)
);


ALTER TABLE public.expense_items OWNER TO lapac;

--
-- Name: expense_items_id_seq; Type: SEQUENCE; Schema: public; Owner: lapac
--

CREATE SEQUENCE public.expense_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.expense_items_id_seq OWNER TO lapac;

--
-- Name: expense_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lapac
--

ALTER SEQUENCE public.expense_items_id_seq OWNED BY public.expense_items.id;


--
-- Name: expenses; Type: TABLE; Schema: public; Owner: lapac
--

CREATE TABLE public.expenses (
    id bigint NOT NULL,
    company_id bigint NOT NULL,
    user_id bigint NOT NULL,
    amount numeric(12,2) NOT NULL,
    currency character varying(10) NOT NULL,
    category text,
    description text,
    expense_date date,
    status public.expense_status DEFAULT 'DRAFT'::public.expense_status,
    current_step integer DEFAULT 1,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    receipt_url text
);


ALTER TABLE public.expenses OWNER TO lapac;

--
-- Name: expense_summary; Type: MATERIALIZED VIEW; Schema: public; Owner: lapac
--

CREATE MATERIALIZED VIEW public.expense_summary AS
 SELECT user_id,
    count(*) AS total_expenses,
    sum(amount) AS total_amount
   FROM public.expenses
  GROUP BY user_id
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.expense_summary OWNER TO lapac;

--
-- Name: expense_workflows; Type: TABLE; Schema: public; Owner: lapac
--

CREATE TABLE public.expense_workflows (
    id bigint NOT NULL,
    expense_id bigint,
    workflow_id bigint,
    started_at timestamp without time zone DEFAULT now(),
    completed_at timestamp without time zone
);


ALTER TABLE public.expense_workflows OWNER TO lapac;

--
-- Name: expense_workflows_id_seq; Type: SEQUENCE; Schema: public; Owner: lapac
--

CREATE SEQUENCE public.expense_workflows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.expense_workflows_id_seq OWNER TO lapac;

--
-- Name: expense_workflows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lapac
--

ALTER SEQUENCE public.expense_workflows_id_seq OWNED BY public.expense_workflows.id;


--
-- Name: expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: lapac
--

CREATE SEQUENCE public.expenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.expenses_id_seq OWNER TO lapac;

--
-- Name: expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lapac
--

ALTER SEQUENCE public.expenses_id_seq OWNED BY public.expenses.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: lapac
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    company_id bigint NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    role public.user_role NOT NULL,
    manager_id bigint,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO lapac;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: lapac
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO lapac;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lapac
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: workflow_rules; Type: TABLE; Schema: public; Owner: lapac
--

CREATE TABLE public.workflow_rules (
    id bigint NOT NULL,
    workflow_id bigint,
    rule_type public.rule_type NOT NULL,
    percentage_value integer,
    specific_user_id bigint,
    config jsonb,
    CONSTRAINT check_percentage CHECK (((rule_type <> 'PERCENTAGE'::public.rule_type) OR (percentage_value IS NOT NULL)))
);


ALTER TABLE public.workflow_rules OWNER TO lapac;

--
-- Name: workflow_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: lapac
--

CREATE SEQUENCE public.workflow_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workflow_rules_id_seq OWNER TO lapac;

--
-- Name: workflow_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lapac
--

ALTER SEQUENCE public.workflow_rules_id_seq OWNED BY public.workflow_rules.id;


--
-- Name: workflow_steps; Type: TABLE; Schema: public; Owner: lapac
--

CREATE TABLE public.workflow_steps (
    id bigint NOT NULL,
    workflow_id bigint,
    step_order integer NOT NULL,
    approver_type public.approver_type NOT NULL,
    approver_user_id bigint,
    approver_role public.user_role,
    is_mandatory boolean DEFAULT true
);


ALTER TABLE public.workflow_steps OWNER TO lapac;

--
-- Name: workflow_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: lapac
--

CREATE SEQUENCE public.workflow_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workflow_steps_id_seq OWNER TO lapac;

--
-- Name: workflow_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lapac
--

ALTER SEQUENCE public.workflow_steps_id_seq OWNED BY public.workflow_steps.id;


--
-- Name: workflows; Type: TABLE; Schema: public; Owner: lapac
--

CREATE TABLE public.workflows (
    id bigint NOT NULL,
    company_id bigint NOT NULL,
    name text NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.workflows OWNER TO lapac;

--
-- Name: workflows_id_seq; Type: SEQUENCE; Schema: public; Owner: lapac
--

CREATE SEQUENCE public.workflows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workflows_id_seq OWNER TO lapac;

--
-- Name: workflows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lapac
--

ALTER SEQUENCE public.workflows_id_seq OWNED BY public.workflows.id;


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: expense_approvals id; Type: DEFAULT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_approvals ALTER COLUMN id SET DEFAULT nextval('public.expense_approvals_id_seq'::regclass);


--
-- Name: expense_items id; Type: DEFAULT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_items ALTER COLUMN id SET DEFAULT nextval('public.expense_items_id_seq'::regclass);


--
-- Name: expense_workflows id; Type: DEFAULT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_workflows ALTER COLUMN id SET DEFAULT nextval('public.expense_workflows_id_seq'::regclass);


--
-- Name: expenses id; Type: DEFAULT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expenses ALTER COLUMN id SET DEFAULT nextval('public.expenses_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: workflow_rules id; Type: DEFAULT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflow_rules ALTER COLUMN id SET DEFAULT nextval('public.workflow_rules_id_seq'::regclass);


--
-- Name: workflow_steps id; Type: DEFAULT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflow_steps ALTER COLUMN id SET DEFAULT nextval('public.workflow_steps_id_seq'::regclass);


--
-- Name: workflows id; Type: DEFAULT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflows ALTER COLUMN id SET DEFAULT nextval('public.workflows_id_seq'::regclass);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: expense_approvals expense_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_approvals
    ADD CONSTRAINT expense_approvals_pkey PRIMARY KEY (id);


--
-- Name: expense_items expense_items_pkey; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_items
    ADD CONSTRAINT expense_items_pkey PRIMARY KEY (id);


--
-- Name: expense_workflows expense_workflows_expense_id_key; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_workflows
    ADD CONSTRAINT expense_workflows_expense_id_key UNIQUE (expense_id);


--
-- Name: expense_workflows expense_workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_workflows
    ADD CONSTRAINT expense_workflows_pkey PRIMARY KEY (id);


--
-- Name: expenses expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);


--
-- Name: workflow_steps unique_step_order; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflow_steps
    ADD CONSTRAINT unique_step_order UNIQUE (workflow_id, step_order);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workflow_rules workflow_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflow_rules
    ADD CONSTRAINT workflow_rules_pkey PRIMARY KEY (id);


--
-- Name: workflow_steps workflow_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflow_steps
    ADD CONSTRAINT workflow_steps_pkey PRIMARY KEY (id);


--
-- Name: workflows workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_pkey PRIMARY KEY (id);


--
-- Name: idx_approvals_approver; Type: INDEX; Schema: public; Owner: lapac
--

CREATE INDEX idx_approvals_approver ON public.expense_approvals USING btree (approver_id);


--
-- Name: idx_approvals_expense; Type: INDEX; Schema: public; Owner: lapac
--

CREATE INDEX idx_approvals_expense ON public.expense_approvals USING btree (expense_id);


--
-- Name: idx_expenses_status; Type: INDEX; Schema: public; Owner: lapac
--

CREATE INDEX idx_expenses_status ON public.expenses USING btree (status);


--
-- Name: idx_expenses_user; Type: INDEX; Schema: public; Owner: lapac
--

CREATE INDEX idx_expenses_user ON public.expenses USING btree (user_id);


--
-- Name: idx_users_company; Type: INDEX; Schema: public; Owner: lapac
--

CREATE INDEX idx_users_company ON public.users USING btree (company_id);


--
-- Name: idx_workflow_company; Type: INDEX; Schema: public; Owner: lapac
--

CREATE INDEX idx_workflow_company ON public.workflows USING btree (company_id);


--
-- Name: expenses trigger_update_expenses; Type: TRIGGER; Schema: public; Owner: lapac
--

CREATE TRIGGER trigger_update_expenses BEFORE UPDATE ON public.expenses FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: expense_approvals expense_approvals_approver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_approvals
    ADD CONSTRAINT expense_approvals_approver_id_fkey FOREIGN KEY (approver_id) REFERENCES public.users(id);


--
-- Name: expense_approvals expense_approvals_expense_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_approvals
    ADD CONSTRAINT expense_approvals_expense_id_fkey FOREIGN KEY (expense_id) REFERENCES public.expenses(id) ON DELETE CASCADE;


--
-- Name: expense_approvals expense_approvals_step_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_approvals
    ADD CONSTRAINT expense_approvals_step_id_fkey FOREIGN KEY (step_id) REFERENCES public.workflow_steps(id);


--
-- Name: expense_items expense_items_expense_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_items
    ADD CONSTRAINT expense_items_expense_id_fkey FOREIGN KEY (expense_id) REFERENCES public.expenses(id) ON DELETE CASCADE;


--
-- Name: expense_workflows expense_workflows_expense_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_workflows
    ADD CONSTRAINT expense_workflows_expense_id_fkey FOREIGN KEY (expense_id) REFERENCES public.expenses(id) ON DELETE CASCADE;


--
-- Name: expense_workflows expense_workflows_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expense_workflows
    ADD CONSTRAINT expense_workflows_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.workflows(id);


--
-- Name: expenses expenses_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: expenses expenses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: users users_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.users(id);


--
-- Name: workflow_rules workflow_rules_specific_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflow_rules
    ADD CONSTRAINT workflow_rules_specific_user_id_fkey FOREIGN KEY (specific_user_id) REFERENCES public.users(id);


--
-- Name: workflow_rules workflow_rules_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflow_rules
    ADD CONSTRAINT workflow_rules_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.workflows(id) ON DELETE CASCADE;


--
-- Name: workflow_steps workflow_steps_approver_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflow_steps
    ADD CONSTRAINT workflow_steps_approver_user_id_fkey FOREIGN KEY (approver_user_id) REFERENCES public.users(id);


--
-- Name: workflow_steps workflow_steps_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflow_steps
    ADD CONSTRAINT workflow_steps_workflow_id_fkey FOREIGN KEY (workflow_id) REFERENCES public.workflows(id) ON DELETE CASCADE;


--
-- Name: workflows workflows_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lapac
--

ALTER TABLE ONLY public.workflows
    ADD CONSTRAINT workflows_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict mS0sq1wkU9mEkIY0QhDBVwK0rmXd81gdhAtlDhNE03nl4DOTMh9nX4CU2cxwAMq

