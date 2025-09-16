CREATE TABLE material_cristal (
    cod_material_cristal SERIAL PRIMARY KEY,
    nombre_material VARCHAR(100) NOT NULL,
    descripcion_material TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
---------------------------
INSERT INTO material_cristal (nombre_material, descripcion_material) VALUES
('Policarbonato', 'Un material resistente y ligero.'),
('Plástico', 'El material más común, flexible y accesible.'),
('Orgánico', 'Otro tipo de resina plástica que es más ligera que el vidrio.'),
('Vidrio', 'Material de cristal vidrio, generalmente más pesado que los demás');
