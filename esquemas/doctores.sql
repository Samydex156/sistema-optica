create table public.doctores (
  cod_doctor serial not null,
  nombre_doctor character varying(100) not null,
  telefono_doctor character varying(20) not null default '-'::character varying,
  direccion_doctor character varying(100) not null default '-'::character varying,
  email_doctor character varying(100) not null default '-'::character varying,
  especialidad_doctor character varying(100) not null default '-'::character varying,
  fecha_creacion_doctor timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint doctores_pkey primary key (cod_doctor)
) TABLESPACE pg_default;