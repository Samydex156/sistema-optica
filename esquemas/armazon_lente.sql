CREATE TABLE armazon_lente (
    cod_armazon SERIAL PRIMARY KEY,
    nombre_armazon VARCHAR(255) NOT NULL,
    fecha_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
