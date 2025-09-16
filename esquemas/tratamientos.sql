create table public.tratamientos (
  cod_tratamiento serial not null,
  nombre_tratamiento character varying(100) not null,
  descripcion_tratamiento text null,
  constraint tratamientos_pkey primary key (cod_tratamiento),
  constraint uq_nombre_tratamiento unique (nombre_tratamiento)
) TABLESPACE pg_default;
------------------------------------------------

INSERT INTO public.tratamientos (nombre_tratamiento, descripcion_tratamiento) VALUES
('Clear Blue Filter', 'Un filtro para la luz azul.'),
('Antirreflex', 'Para reducir los reflejos en la superficie de la lente.'),
('Antirrayas', 'Para proteger la superficie de la lente.'),
('Endurecido', 'Para proteger la superficie de la lente.'),
('Vision Free', 'Probablemente se refiere a un diseño de lente o un tratamiento óptico específico.');