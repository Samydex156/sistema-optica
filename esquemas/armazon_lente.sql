CREATE TABLE armazon_lente (
    cod_armazon SERIAL PRIMARY KEY,
    nombre_armazon VARCHAR(255) NOT NULL,
    fecha_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO armazon_lente (nombre_armazon) VALUES ('PROPIO');
INSERT INTO armazon_lente (nombre_armazon) VALUES ('MILY');
INSERT INTO armazon_lente (nombre_armazon) VALUES ('LUX');
INSERT INTO armazon_lente (nombre_armazon) VALUES ('VITA');
INSERT INTO armazon_lente (nombre_armazon) VALUES ('LAVIE');
INSERT INTO armazon_lente (nombre_armazon) VALUES ('CONTINENTAL');
INSERT INTO armazon_lente (nombre_armazon) VALUES ('OTRO');