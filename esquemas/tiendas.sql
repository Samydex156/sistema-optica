create table public.tiendas (
  cod_tienda serial not null,
  nombre_tienda character varying(100) not null,
  direccion_tienda character varying(100) not null,
  telefono_tienda character varying(20) not null,
  email_tienda character varying(100) null default 'No especificado'::character varying,
  fecha_creacion_tienda timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint tiendas_pkey primary key (cod_tienda)
) TABLESPACE pg_default;