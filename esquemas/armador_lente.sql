CREATE TABLE armador_lente (
    cod_armador SERIAL PRIMARY KEY,
    nombre_armador VARCHAR(100) NOT NULL,
    fecha_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


INSERT INTO armador_lente (nombre_armador)
VALUES ('JAIME'),
('PORFIRIO');

