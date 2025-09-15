create table public.clientes (
  cod_cliente serial not null,
  nombre_cliente character varying(100) not null,
  apellido_paterno_cliente character varying(100) not null,
  apellido_materno_cliente character varying(100) null,
  telefono_cliente character varying(20) null,
  fecha_registro_cliente timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint clientes_pkey primary key (cod_cliente)
) TABLESPACE pg_default;