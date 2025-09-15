create table public.medida_lente_tratamiento (
  cod_medida_lente_tratamiento serial not null,
  cod_medida_lente integer not null,
  cod_tratamiento integer not null,
  fecha_asociacion timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint medida_lente_tratamiento_pkey primary key (cod_medida_lente_tratamiento),
  constraint uq_medida_tratamiento unique (cod_medida_lente, cod_tratamiento),
  constraint medida_lente_tratamiento_medida_lente_fkey foreign KEY (cod_medida_lente) references medida_lente (cod_medida_lente) on update CASCADE on delete CASCADE,
  constraint medida_lente_tratamiento_tratamiento_fkey foreign KEY (cod_tratamiento) references tratamientos (cod_tratamiento) on update CASCADE on delete RESTRICT
) TABLESPACE pg_default;