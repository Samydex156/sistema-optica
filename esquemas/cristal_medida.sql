create table public.cristal_medida (
  cod_cristal_medida serial not null,
  cod_medida_lente integer not null,
  cod_material_cristal integer null,
  cod_color_cristal integer null,
  cod_tipo_lente integer null,
  cantidad integer not null default 1,
  nro_sobre character varying(50) null,
  fecha_creacion_cristal_medida timestamp without time zone not null default CURRENT_TIMESTAMP,
  descripcion_cristal text null,
  constraint cristal_medida_pkey primary key (cod_cristal_medida),
  constraint fk_cristal_medida_color foreign KEY (cod_color_cristal) references color_cristal (cod_color_cristal) on update CASCADE on delete RESTRICT,
  constraint fk_cristal_medida_material foreign KEY (cod_material_cristal) references material_cristal (cod_material_cristal) on update CASCADE on delete RESTRICT,
  constraint fk_cristal_medida_medida_lente foreign KEY (cod_medida_lente) references medida_lente (cod_medida_lente) on update CASCADE on delete CASCADE,
  constraint fk_cristal_medida_tipo_lente foreign KEY (cod_tipo_lente) references tipo_lente (id_tipo_lente) on update CASCADE on delete RESTRICT
) TABLESPACE pg_default;