CREATE TABLE tipo_lente (
    id_tipo_lente SERIAL PRIMARY KEY,
    nombre_tipo_lente VARCHAR(255) NOT NULL,
    descripcion_tipo TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
-----------------------------------
INSERT INTO tipo_lente (nombre_tipo_lente, descripcion_tipo) VALUES
('Varilux', 'Una marca conocida por sus lentes progresivos.'),
('Ovation', 'Otra marca o modelo de lentes.'),
('High Lite', 'Un tipo de lente, posiblemente de alto índice o delgadez.'),
('Bifocal', 'Lentes con dos zonas de visión.'),
('Photo', 'Lentes que se oscurecen con la luz solar.'),
('Transition', 'Lentes fotosensibles de la marca Transitions.'),
('Cincromatico', 'También lentes que reaccionan a la luz.'),
('Gradal Top', 'Un tipo de lente progresivo.'),
('Xtractive', 'Un tipo de lente.');

---------------------------------
