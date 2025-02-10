--
-- PostgreSQL database dump
--

-- Dumped from database version 14.15 (Homebrew)
-- Dumped by pg_dump version 14.15 (Homebrew)

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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.admin_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.admin_users OWNER TO igorsimdanov;

--
-- Name: TABLE admin_users; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.admin_users IS 'Учетные записи для системы администрирования';


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO igorsimdanov;

--
-- Name: authors; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.authors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying,
    middle_name character varying,
    original character varying,
    books_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.authors OWNER TO igorsimdanov;

--
-- Name: TABLE authors; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.authors IS 'Авторы книг';


--
-- Name: COLUMN authors.first_name; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.authors.first_name IS 'Имя автора';


--
-- Name: COLUMN authors.last_name; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.authors.last_name IS 'Фамилия автора';


--
-- Name: COLUMN authors.middle_name; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.authors.middle_name IS 'Отчество автора';


--
-- Name: COLUMN authors.original; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.authors.original IS 'Автор в inpx-индексе';


--
-- Name: COLUMN authors.books_count; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.authors.books_count IS 'Количество книг';


--
-- Name: books; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.books (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    title character varying NOT NULL,
    series character varying,
    serno character varying,
    libid integer NOT NULL,
    size integer NOT NULL,
    filename integer NOT NULL,
    del boolean DEFAULT false NOT NULL,
    ext character varying DEFAULT 'fb2'::character varying NOT NULL,
    published_at date,
    insno character varying,
    folder_id uuid NOT NULL,
    language_id uuid NOT NULL
);


ALTER TABLE public.books OWNER TO igorsimdanov;

--
-- Name: TABLE books; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.books IS 'Книги';


--
-- Name: COLUMN books.title; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.books.title IS 'Название';


--
-- Name: COLUMN books.series; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.books.series IS 'Серия';


--
-- Name: COLUMN books.serno; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.books.serno IS 'Номер в серии';


--
-- Name: COLUMN books.libid; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.books.libid IS 'Идентификатор книги в библиотеке';


--
-- Name: COLUMN books.size; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.books.size IS 'Размер файла в байтах';


--
-- Name: COLUMN books.filename; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.books.filename IS 'Название файла в архиве';


--
-- Name: COLUMN books.del; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.books.del IS 'Удален ли файл из библиотеки';


--
-- Name: COLUMN books.ext; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.books.ext IS 'Расширение файла';


--
-- Name: COLUMN books.published_at; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.books.published_at IS 'Дата публикации файла в библиотеке';


--
-- Name: COLUMN books.insno; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.books.insno IS 'ISBN';


--
-- Name: books_authors; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.books_authors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    book_id uuid NOT NULL,
    author_id uuid NOT NULL
);


ALTER TABLE public.books_authors OWNER TO igorsimdanov;

--
-- Name: TABLE books_authors; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.books_authors IS 'Связь книги с авторами';


--
-- Name: books_genres; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.books_genres (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    book_id uuid NOT NULL,
    genre_id uuid NOT NULL
);


ALTER TABLE public.books_genres OWNER TO igorsimdanov;

--
-- Name: TABLE books_genres; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.books_genres IS 'Связь книги с жанрами';


--
-- Name: books_keywords; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.books_keywords (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    book_id uuid NOT NULL,
    keyword_id uuid NOT NULL
);


ALTER TABLE public.books_keywords OWNER TO igorsimdanov;

--
-- Name: TABLE books_keywords; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.books_keywords IS 'Связь книги с ключевыми словами';


--
-- Name: folders; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.folders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.folders OWNER TO igorsimdanov;

--
-- Name: TABLE folders; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.folders IS 'Папки книг';


--
-- Name: COLUMN folders.name; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.folders.name IS 'Название папки';


--
-- Name: genre_groups; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.genre_groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.genre_groups OWNER TO igorsimdanov;

--
-- Name: TABLE genre_groups; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.genre_groups IS 'Группа жанров книг';


--
-- Name: COLUMN genre_groups.name; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.genre_groups.name IS 'Название группы жанра';


--
-- Name: genres; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.genres (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    slug character varying NOT NULL,
    name character varying,
    genre_group_id uuid NOT NULL,
    books_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.genres OWNER TO igorsimdanov;

--
-- Name: TABLE genres; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.genres IS 'Жанры книг';


--
-- Name: COLUMN genres.slug; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.genres.slug IS 'Обозначение жанра в библиотеке';


--
-- Name: COLUMN genres.name; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.genres.name IS 'Название жанра';


--
-- Name: COLUMN genres.books_count; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.genres.books_count IS 'Количество книг';


--
-- Name: keywords; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.keywords (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying NOT NULL,
    books_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.keywords OWNER TO igorsimdanov;

--
-- Name: TABLE keywords; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.keywords IS 'Ключевые слова';


--
-- Name: COLUMN keywords.name; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.keywords.name IS 'Ключевое слово';


--
-- Name: COLUMN keywords.books_count; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.keywords.books_count IS 'Количество книг';


--
-- Name: languages; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.languages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    slug character varying NOT NULL,
    name character varying,
    books_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.languages OWNER TO igorsimdanov;

--
-- Name: TABLE languages; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON TABLE public.languages IS 'Языки книг';


--
-- Name: COLUMN languages.slug; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.languages.slug IS 'Обозначение языка';


--
-- Name: COLUMN languages.name; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.languages.name IS 'Название языка';


--
-- Name: COLUMN languages.books_count; Type: COMMENT; Schema: public; Owner: igorsimdanov
--

COMMENT ON COLUMN public.languages.books_count IS 'Количество книг';


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: igorsimdanov
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO igorsimdanov;

--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.admin_users (id, created_at, updated_at, email, encrypted_password) FROM stdin;
\.


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2024-12-24 11:09:03.082512	2024-12-24 11:09:03.082517
schema_sha1	a8c075709fb00d1e4bfc0be920b24fbfbe968ee2	2024-12-24 11:09:03.095029	2024-12-24 11:09:03.095037
\.


--
-- Data for Name: authors; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.authors (id, created_at, updated_at, first_name, last_name, middle_name, original, books_count) FROM stdin;
\.


--
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.books (id, created_at, updated_at, title, series, serno, libid, size, filename, del, ext, published_at, insno, folder_id, language_id) FROM stdin;
\.


--
-- Data for Name: books_authors; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.books_authors (id, created_at, updated_at, book_id, author_id) FROM stdin;
\.


--
-- Data for Name: books_genres; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.books_genres (id, created_at, updated_at, book_id, genre_id) FROM stdin;
\.


--
-- Data for Name: books_keywords; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.books_keywords (id, created_at, updated_at, book_id, keyword_id) FROM stdin;
\.


--
-- Data for Name: folders; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.folders (id, created_at, updated_at, name) FROM stdin;
\.


--
-- Data for Name: genre_groups; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.genre_groups (id, created_at, updated_at, name) FROM stdin;
\.


--
-- Data for Name: genres; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.genres (id, created_at, updated_at, slug, name, genre_group_id, books_count) FROM stdin;
\.


--
-- Data for Name: keywords; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.keywords (id, created_at, updated_at, name, books_count) FROM stdin;
\.


--
-- Data for Name: languages; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.languages (id, created_at, updated_at, slug, name, books_count) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: igorsimdanov
--

COPY public.schema_migrations (version) FROM stdin;
20240901140126
\.


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: books_authors books_authors_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books_authors
    ADD CONSTRAINT books_authors_pkey PRIMARY KEY (id);


--
-- Name: books_genres books_genres_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books_genres
    ADD CONSTRAINT books_genres_pkey PRIMARY KEY (id);


--
-- Name: books_keywords books_keywords_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books_keywords
    ADD CONSTRAINT books_keywords_pkey PRIMARY KEY (id);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: folders folders_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_pkey PRIMARY KEY (id);


--
-- Name: genre_groups genre_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.genre_groups
    ADD CONSTRAINT genre_groups_pkey PRIMARY KEY (id);


--
-- Name: genres genres_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_pkey PRIMARY KEY (id);


--
-- Name: keywords keywords_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: idx_on_first_name_last_name_middle_name_original_8ed0e1cb00; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE UNIQUE INDEX idx_on_first_name_last_name_middle_name_original_8ed0e1cb00 ON public.authors USING btree (first_name, last_name, middle_name, original);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE UNIQUE INDEX index_admin_users_on_email ON public.admin_users USING btree (email);


--
-- Name: index_books_authors_on_author_id; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE INDEX index_books_authors_on_author_id ON public.books_authors USING btree (author_id);


--
-- Name: index_books_authors_on_book_id; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE INDEX index_books_authors_on_book_id ON public.books_authors USING btree (book_id);


--
-- Name: index_books_genres_on_book_id; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE INDEX index_books_genres_on_book_id ON public.books_genres USING btree (book_id);


--
-- Name: index_books_genres_on_genre_id; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE INDEX index_books_genres_on_genre_id ON public.books_genres USING btree (genre_id);


--
-- Name: index_books_keywords_on_book_id; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE INDEX index_books_keywords_on_book_id ON public.books_keywords USING btree (book_id);


--
-- Name: index_books_keywords_on_keyword_id; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE INDEX index_books_keywords_on_keyword_id ON public.books_keywords USING btree (keyword_id);


--
-- Name: index_books_on_folder_id; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE INDEX index_books_on_folder_id ON public.books USING btree (folder_id);


--
-- Name: index_books_on_language_id; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE INDEX index_books_on_language_id ON public.books USING btree (language_id);


--
-- Name: index_folders_on_name; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE UNIQUE INDEX index_folders_on_name ON public.folders USING btree (name);


--
-- Name: index_genre_groups_on_name; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE UNIQUE INDEX index_genre_groups_on_name ON public.genre_groups USING btree (name);


--
-- Name: index_genres_on_genre_group_id; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE INDEX index_genres_on_genre_group_id ON public.genres USING btree (genre_group_id);


--
-- Name: index_genres_on_slug; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE UNIQUE INDEX index_genres_on_slug ON public.genres USING btree (slug);


--
-- Name: index_keywords_on_name; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE UNIQUE INDEX index_keywords_on_name ON public.keywords USING btree (name);


--
-- Name: index_languages_on_slug; Type: INDEX; Schema: public; Owner: igorsimdanov
--

CREATE UNIQUE INDEX index_languages_on_slug ON public.languages USING btree (slug);


--
-- Name: books fk_rails_0c601779a5; Type: FK CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT fk_rails_0c601779a5 FOREIGN KEY (language_id) REFERENCES public.languages(id);


--
-- Name: books_genres fk_rails_4bec785c35; Type: FK CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books_genres
    ADD CONSTRAINT fk_rails_4bec785c35 FOREIGN KEY (book_id) REFERENCES public.books(id);


--
-- Name: books_authors fk_rails_6700109351; Type: FK CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books_authors
    ADD CONSTRAINT fk_rails_6700109351 FOREIGN KEY (author_id) REFERENCES public.authors(id);


--
-- Name: books_genres fk_rails_888159e47e; Type: FK CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books_genres
    ADD CONSTRAINT fk_rails_888159e47e FOREIGN KEY (genre_id) REFERENCES public.genres(id);


--
-- Name: genres fk_rails_95f7d9555f; Type: FK CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT fk_rails_95f7d9555f FOREIGN KEY (genre_group_id) REFERENCES public.genre_groups(id);


--
-- Name: books_keywords fk_rails_9ae3f7496a; Type: FK CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books_keywords
    ADD CONSTRAINT fk_rails_9ae3f7496a FOREIGN KEY (keyword_id) REFERENCES public.keywords(id);


--
-- Name: books_authors fk_rails_b5e896f41c; Type: FK CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books_authors
    ADD CONSTRAINT fk_rails_b5e896f41c FOREIGN KEY (book_id) REFERENCES public.books(id);


--
-- Name: books_keywords fk_rails_da086dbeaa; Type: FK CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books_keywords
    ADD CONSTRAINT fk_rails_da086dbeaa FOREIGN KEY (book_id) REFERENCES public.books(id);


--
-- Name: books fk_rails_ee21b1c6c2; Type: FK CONSTRAINT; Schema: public; Owner: igorsimdanov
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT fk_rails_ee21b1c6c2 FOREIGN KEY (folder_id) REFERENCES public.folders(id);


--
-- PostgreSQL database dump complete
--

