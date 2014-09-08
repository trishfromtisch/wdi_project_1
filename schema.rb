CREATE DATABASE gradlaw;

\c gradlaw;

CREATE TABLE categories (id serial primary key, name varchar (255), description varchar (255), votes integer, has_post boolean);

CREATE TABLE posts (id serial primary key, content text, category_id integer, expiration date, votes integer);

CREATE TABLE comments (id serial primary key, content text, post_id integer);

CREATE TABLE subscriber (id serial primary key, email varchar(255), kind varchar(12), foreign_id integer);
