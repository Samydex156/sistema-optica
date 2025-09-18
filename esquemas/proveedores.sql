create table public.proveedores (
  cod_proveedor serial not null,
  razon_social_proveedor character varying(100) null default 'No especificada'::character varying,
  nombre_proveedor character varying(100) not null,
  telefono_proveedor character varying(20) not null,
  direccion_proveedor character varying(100) null default 'No especificada'::character varying,
  email_proveedor character varying(100) null default 'No especificada'::character varying,
  nit_proveedor character varying(20) null default 'No especificada'::character varying,
  activo boolean null default true,
  fecha_creacion_proveedor timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint proveedores_pkey primary key (cod_proveedor)
) TABLESPACE pg_default;

