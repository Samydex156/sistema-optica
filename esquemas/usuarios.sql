create table public.usuarios (
  cod_usuario serial not null,
  nombre_usuario character varying(255) not null,
  email_usuario character varying(255) not null,
  password_usuario character varying(255) not null,
  rol_usuario integer not null,
  tienda_usuario integer null,
  activo boolean null default true,
  creado_en timestamp without time zone null default CURRENT_TIMESTAMP,
  constraint usuarios_pkey primary key (cod_usuario),
  constraint usuarios_email_usuario_key unique (email_usuario),
  constraint usuarios_nombre_usuario_key unique (nombre_usuario),
  constraint usuarios_rol_usuario_fkey foreign KEY (rol_usuario) references roles (cod_rol),
  constraint usuarios_tienda_usuario_fkey foreign KEY (tienda_usuario) references tiendas (cod_tienda)
) TABLESPACE pg_default;