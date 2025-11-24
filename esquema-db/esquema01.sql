create table public.armador_lente (
  cod_armador serial not null,
  nombre_armador character varying(100) not null,
  fecha_timestamp timestamp with time zone null default now(),
  constraint armador_lente_pkey primary key (cod_armador)
) TABLESPACE pg_default;

create table public.armazon_lente (
  cod_armazon serial not null,
  nombre_armazon character varying(255) not null,
  fecha_timestamp timestamp with time zone null default now(),
  constraint armazon_lente_pkey primary key (cod_armazon)
) TABLESPACE pg_default;

create table public.categoria_producto (
  cod_categoria serial not null,
  nombre_categoria_producto character varying(100) not null,
  descripcion_categoria text null,
  fecha_creacion_categoria timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint categoria_producto_pkey primary key (cod_categoria)
) TABLESPACE pg_default;

create table public.clientes (
  cod_cliente serial not null,
  nombre_cliente character varying(100) not null,
  apellido_paterno_cliente character varying(100) not null,
  apellido_materno_cliente character varying(100) null,
  telefono_cliente character varying(20) null,
  fecha_registro_cliente timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint clientes_pkey primary key (cod_cliente)
) TABLESPACE pg_default;

create table public.color_cristal (
  cod_color_cristal serial not null,
  nombre_color character varying(100) not null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint color_cristal_pkey primary key (cod_color_cristal)
) TABLESPACE pg_default;

create table public.color_montura (
  cod_color_montura serial not null,
  nombre_color character varying(50) not null,
  codigo_hex character varying(7) null,
  constraint color_montura_pkey primary key (cod_color_montura),
  constraint color_montura_nombre_color_key unique (nombre_color)
) TABLESPACE pg_default;

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

create table public.inventario (
  cod_inventario serial not null,
  producto_id integer not null,
  tienda_id integer not null,
  cantidad_disponible integer not null default 0,
  ultima_actualizacion timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint inventario_pkey primary key (cod_inventario),
  constraint inventario_producto_tienda_unique unique (producto_id, tienda_id),
  constraint inventario_producto_id_fkey foreign KEY (producto_id) references productos (cod_producto),
  constraint inventario_tienda_id_fkey foreign KEY (tienda_id) references tiendas (cod_tienda)
) TABLESPACE pg_default;

create table public.material_cristal (
  cod_material_cristal serial not null,
  nombre_material character varying(100) not null,
  descripcion_material text null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint material_cristal_pkey primary key (cod_material_cristal)
) TABLESPACE pg_default;

create table public.material_producto (
  cod_material serial not null,
  descripcion_material character varying(100) not null,
  fecha_creacion_material timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint material_producto_pkey primary key (cod_material)
) TABLESPACE pg_default;

create table public.modelo_producto (
  cod_modelo serial not null,
  descripcion_modelo character varying(100) not null,
  fecha_creacion_modelo timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint modelo_producto_pkey primary key (cod_modelo)
) TABLESPACE pg_default;

create table public.movimientos_inventario (
  cod_movimiento serial not null,
  producto_id integer not null,
  tienda_origen_id integer null,
  tienda_destino_id integer null,
  tipo_movimiento character varying(20) not null,
  motivo character varying(255) not null,
  cantidad integer not null,
  fecha_movimiento timestamp with time zone null default CURRENT_TIMESTAMP,
  usuario_id integer not null,
  referencia_externa character varying(100) null,
  constraint movimientos_inventario_pkey primary key (cod_movimiento),
  constraint movimientos_inventario_producto_id_fkey foreign KEY (producto_id) references productos (cod_producto),
  constraint movimientos_inventario_tienda_destino_id_fkey foreign KEY (tienda_destino_id) references tiendas (cod_tienda),
  constraint movimientos_inventario_tienda_origen_id_fkey foreign KEY (tienda_origen_id) references tiendas (cod_tienda),
  constraint movimientos_inventario_usuario_id_fkey foreign KEY (usuario_id) references usuarios (cod_usuario),
  constraint movimientos_inventario_tipo_movimiento_check check (
    (
      (tipo_movimiento)::text = any (
        (
          array[
            'ENTRADA'::character varying,
            'SALIDA'::character varying,
            'TRASPASO'::character varying,
            'AJUSTE'::character varying,
            'DEVOLUCION'::character varying
          ]
        )::text[]
      )
    )
  )
) TABLESPACE pg_default;

create table public.orden_trabajo (
  nro_boleta_sobre integer not null,
  cliente integer not null,
  tienda integer not null,
  creado_por integer null,
  fecha_pedido date not null default CURRENT_TIMESTAMP,
  fecha_entrega date null,
  hora_entrega time without time zone null,
  monto_total numeric(10, 2) not null default 0.00,
  monto_acuenta numeric(10, 2) not null default 0.00,
  monto_saldo numeric(10, 2) not null default 0.00,
  observaciones_orden text null,
  estado_orden character varying(20) not null default 'PENDIENTE'::character varying,
  creado_en timestamp without time zone not null default CURRENT_TIMESTAMP,
  fecha_pago_total date null,
  constraint orden_trabajo_pkey primary key (nro_boleta_sobre),
  constraint orden_trabajo_cliente_fkey foreign KEY (cliente) references clientes (cod_cliente),
  constraint orden_trabajo_creado_por_fkey foreign KEY (creado_por) references usuarios (cod_usuario),
  constraint orden_trabajo_tienda_fkey foreign KEY (tienda) references tiendas (cod_tienda)
) TABLESPACE pg_default;

create table public.pagos_orden (
  cod_pago serial not null,
  nro_boleta_sobre integer not null default 0,
  tipo_pago character varying(20) not null default 'EFECTIVO'::character varying,
  monto_pago numeric(10, 2) not null default 0.00,
  fecha_pago date null,
  constraint pagos_orden_pkey primary key (cod_pago)
) TABLESPACE pg_default;

create table public.prescripcion_clienten (
  cod_prescripcion serial not null,
  cod_cliente integer not null,
  cod_receta character varying(10) not null,
  fecha_prescripcion date null,
  doctor_prescriptor integer not null,
  distancia_lente1 character varying(20) not null,
  l1_dip character varying(10) not null default '-'::character varying,
  l1_esf_od character varying(20) not null default '-'::character varying,
  l1_cil_od character varying(20) not null default '-'::character varying,
  l1_eje_od character varying(20) not null default '-'::character varying,
  l1_esf_oi character varying(20) not null default '-'::character varying,
  l1_cil_oi character varying(20) not null default '-'::character varying,
  l1_eje_oi character varying(20) not null default '-'::character varying,
  distancia_lente2 character varying(20) not null,
  l2_dip character varying(10) not null default '-'::character varying,
  l2_esf_od character varying(20) not null default '-'::character varying,
  l2_cil_od character varying(20) not null default '-'::character varying,
  l2_eje_od character varying(20) not null default '-'::character varying,
  l2_esf_oi character varying(20) not null default '-'::character varying,
  l2_cil_oi character varying(20) not null default '-'::character varying,
  l2_eje_oi character varying(20) not null default '-'::character varying,
  l1_cantidad_cristal integer not null default 0,
  l1_material_cristal integer null,
  l1_tipo_lente integer null,
  l1_color_cristal integer null,
  l1_extra_cristal character varying(100) not null default '-'::character varying,
  l2_cantidad_cristal integer not null default 0,
  l2_material_cristal integer null,
  l2_tipo_lente integer null,
  l2_color_cristal integer null,
  l2_extra_cristal character varying(100) not null default '-'::character varying,
  cod_proveedor integer null,
  cod_armador integer null,
  cod_armazon integer null,
  fecha_entrega date null,
  num_sobre character varying(20) not null default '-'::character varying,
  cod_pedido1 character varying(20) not null default '-'::character varying,
  cod_pedido2 character varying(20) not null default '-'::character varying,
  notas_adicionales character varying(100) not null default '-'::character varying,
  fecha_registro timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint prescripcion_clienten_pkey primary key (cod_prescripcion),
  constraint prescripcion_clienten_cod_armazon_fkey foreign KEY (cod_armazon) references armazon_lente (cod_armazon),
  constraint prescripcion_clienten_cod_cliente_fkey foreign KEY (cod_cliente) references clientes (cod_cliente),
  constraint prescripcion_clienten_cod_proveedor_fkey foreign KEY (cod_proveedor) references proveedores (cod_proveedor),
  constraint prescripcion_clienten_doctor_prescriptor_fkey foreign KEY (doctor_prescriptor) references doctores (cod_doctor),
  constraint prescripcion_clienten_l1_color_cristal_fkey foreign KEY (l1_color_cristal) references color_cristal (cod_color_cristal),
  constraint prescripcion_clienten_cod_armador_fkey foreign KEY (cod_armador) references armador_lente (cod_armador),
  constraint prescripcion_clienten_l1_tipo_lente_fkey foreign KEY (l1_tipo_lente) references tipo_lente (id_tipo_lente),
  constraint prescripcion_clienten_l2_color_cristal_fkey foreign KEY (l2_color_cristal) references color_cristal (cod_color_cristal),
  constraint prescripcion_clienten_l2_material_cristal_fkey foreign KEY (l2_material_cristal) references material_cristal (cod_material_cristal),
  constraint prescripcion_clienten_l2_tipo_lente_fkey foreign KEY (l2_tipo_lente) references tipo_lente (id_tipo_lente),
  constraint prescripcion_clienten_l1_material_cristal_fkey foreign KEY (l1_material_cristal) references material_cristal (cod_material_cristal)
) TABLESPACE pg_default;

create table public.prescripcion_tratamiento (
  cod_prescripcion_tratamiento serial not null,
  cod_prescripcion integer not null,
  cod_tratamiento integer not null,
  numero_lente smallint not null,
  constraint prescripcion_tratamiento_pkey primary key (cod_prescripcion_tratamiento),
  constraint uq_prescripcion_tratamiento_lente unique (cod_prescripcion, cod_tratamiento, numero_lente),
  constraint prescripcion_tratamiento_cod_tratamiento_fkey foreign KEY (cod_tratamiento) references tratamientos (cod_tratamiento) on delete RESTRICT,
  constraint prescripcion_tratamiento_numero_lente_check check ((numero_lente = any (array[1, 2])))
) TABLESPACE pg_default;

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

create table public.roles (
  cod_rol serial not null,
  nombre_rol character varying(20) not null default 'VENDEDOR'::character varying,
  creado_en timestamp without time zone null default CURRENT_TIMESTAMP,
  constraint roles_pkey primary key (cod_rol)
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

create table public.tipo_lente (
  id_tipo_lente serial not null,
  nombre_tipo_lente character varying(255) not null,
  descripcion_tipo text null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint tipo_lente_pkey primary key (id_tipo_lente)
) TABLESPACE pg_default;

create table public.tratamientos (
  cod_tratamiento serial not null,
  nombre_tratamiento character varying(100) not null,
  descripcion_tratamiento text null,
  constraint tratamientos_pkey primary key (cod_tratamiento),
  constraint uq_nombre_tratamiento unique (nombre_tratamiento)
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


create table public.pedidos_sobres (
  numero_sobre integer not null,
  fecha_pedido date not null default CURRENT_DATE,
  fecha_entrega date null,
  hora_entrega time without time zone null,
  nombre_cliente character varying(150) not null,
  fecha_cancelacion_total date null,
  cod_doctor integer null,
  monto_total numeric(10, 2) not null default 0.00,
  monto_a_cuenta numeric(10, 2) not null default 0.00,
  saldo numeric GENERATED ALWAYS as ((monto_total - monto_a_cuenta)) STORED (10, 2) null,
  momento_ingreso timestamp with time zone not null default now(),
  estado_pedido character varying(20) not null default 'pendiente'::character varying,
  cod_tienda integer null,
  constraint pedidos_sobres_pkey primary key (numero_sobre),
  constraint pedidos_sobres_cod_doctor_fkey foreign KEY (cod_doctor) references doctores (cod_doctor),
  constraint pedidos_sobres_cod_tienda_fkey foreign KEY (cod_tienda) references tiendas (cod_tienda)
) TABLESPACE pg_default;