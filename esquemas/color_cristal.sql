CREATE TABLE color_cristal (
    cod_color_cristal SERIAL PRIMARY KEY,
    nombre_color VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

--------------------------
INSERT INTO color_cristal (nombre_color) VALUES
('BLANCO'),
('BROWN'),
('GREY'),
('ROSADO'),
('LILA'),
('CAFE'),
('PLOMO'),
('AMARILLO'),
('AMARILLO VERDOSO');
