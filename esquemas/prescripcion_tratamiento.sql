create table public.prescripcion_tratamiento (
  cod_prescripcion_tratamiento serial not null,
  cod_prescripcion integer not null,
  cod_tratamiento integer not null,
  numero_lente smallint not null,
  constraint prescripcion_tratamiento_pkey primary key (cod_prescripcion_tratamiento),
  constraint uq_prescripcion_tratamiento_lente unique (cod_prescripcion, cod_tratamiento, numero_lente),
  constraint prescripcion_tratamiento_cod_tratamiento_fkey foreign KEY (cod_tratamiento) references tratamientos (cod_tratamiento) on delete RESTRICT,
  constraint prescripcion_tratamiento_numero_lente_check check ((numero_lente = any (array[1, 2])))
) TABLESPACE pg_default;