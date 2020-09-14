CREATE DATABASE db_demo;
USE db_demo;

CREATE TABLE demo_table
(
    id   int          NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    PRIMARY KEY (id)
);

INSERT INTO demo_table (name)
VALUES ('Oleg');
