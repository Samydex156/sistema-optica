create table public.tratamientos (
  cod_tratamiento serial not null,
  nombre_tratamiento character varying(100) not null,
  descripcion_tratamiento text null,
  constraint tratamientos_pkey primary key (cod_tratamiento),
  constraint uq_nombre_tratamiento unique (nombre_tratamiento)
) TABLESPACE pg_default;
