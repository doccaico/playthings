CREATE TABLE entries (
 id          SERIAL,
 name        CHARACTER VARYING           NOT NULL,
 text        CHARACTER VARYING           NOT NULL,
 mail        CHARACTER VARYING           NOT NULL,
 password    CHARACTER VARYING           NOT NULL,
 age         CHARACTER VARYING           NOT NULL,
 area        INTEGER                     NOT NULL,
 gender      INTEGER                     NOT NULL,
 created_on  TIMESTAMP WITHOUT TIME ZONE NOT NULL,
 PRIMARY KEY (id)
);

-- import dummy-data from csv
\COPY entries FROM flask_bbs/utils/entries.csv WITH CSV DELIMITER ',';

-- sync id
-- select setval('entries_id_seq',(select max(id) from entries));
