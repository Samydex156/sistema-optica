
create table public.prescripcion_cliente (
  cod_prescripcion serial not null,
  cod_receta character varying(20) not null default '-'::character varying,
  cliente integer not null,
  doctor_prescriptor integer not null,
  fecha_prescripcion date not null default CURRENT_DATE,
  observacion_prescripcion text not null default '-'::text,
  fecha_creacion_prescripcion_cliente timestamp without time zone not null default CURRENT_TIMESTAMP,
  armador_lente_id integer null,
  armazon_lente_id integer null,
  proveedor_id integer null,
  fecha_entrega date null,
  codigo_pedido character varying(6) null,
  constraint prescripcion_cliente_pkey primary key (cod_prescripcion),
  constraint fk_armador_lente foreign KEY (armador_lente_id) references armador_lente (cod_armador),
  constraint fk_armazon_lente foreign KEY (armazon_lente_id) references armazon_lente (cod_armazon),
  constraint fk_proveedores foreign KEY (proveedor_id) references proveedores (cod_proveedor),
  constraint prescripcion_cliente_cliente_fkey foreign KEY (cliente) references clientes (cod_cliente) on update CASCADE on delete RESTRICT,
  constraint prescripcion_cliente_doctor_prescriptor_fkey foreign KEY (doctor_prescriptor) references doctores (cod_doctor) on update CASCADE on delete RESTRICT
) TABLESPACE pg_default;