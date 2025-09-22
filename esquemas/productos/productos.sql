create table public.productos (
  cod_producto serial not null,
  cod_categoria integer not null,
  proveedor_producto integer not null,
  material_producto integer not null,
  modelo_producto integer not null,
  color_producto integer not null,
  genero_producto character varying(20) null default 'UNISEX'::character varying,
  descripcion_producto character varying(100) not null,
  precio_compra_producto numeric(10, 2) not null default 0.00,
  precio_venta_producto numeric(10, 2) not null default 0.00,
  stock_minimo_producto integer not null default 0,
  activo boolean null default true,
  ingresado_por integer not null,
  fecha_creacion_producto timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint productos_pkey primary key (cod_producto),
  constraint productos_color_producto_fkey foreign KEY (color_producto) references color_montura (cod_color_montura),
  constraint productos_ingresado_por_fkey foreign KEY (ingresado_por) references usuarios (cod_usuario),
  constraint productos_cod_categoria_fkey foreign KEY (cod_categoria) references categoria_producto (cod_categoria),
  constraint productos_modelo_producto_fkey foreign KEY (modelo_producto) references modelo_producto (cod_modelo),
  constraint productos_proveedor_producto_fkey foreign KEY (proveedor_producto) references proveedores (cod_proveedor),
  constraint productos_material_producto_fkey foreign KEY (material_producto) references material_producto (cod_material)
) TABLESPACE pg_default;

create table public.tiendas (
  cod_tienda serial not null,
  nombre_tienda character varying(100) not null,
  direccion_tienda character varying(100) not null,
  telefono_tienda character varying(20) not null,
  email_tienda character varying(100) null default 'No especificado'::character varying,
  fecha_creacion_tienda timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint tiendas_pkey primary key (cod_tienda)
) TABLESPACE pg_default;

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

create table public.roles (
  cod_rol serial not null,
  nombre_rol character varying(20) not null default 'VENDEDOR'::character varying,
  creado_en timestamp without time zone null default CURRENT_TIMESTAMP,
  constraint roles_pkey primary key (cod_rol)
) TABLESPACE pg_default;