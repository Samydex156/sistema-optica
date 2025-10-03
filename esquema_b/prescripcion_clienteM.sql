create table prescripcion_cliente(
  cod_prescripcion serial primary key,
  cod_cliente integer not null references cliente(cod_cliente),
  
  cod_receta varchar(10) not null,
  fecha_prescripcion date,
  doctor_prescriptor integer not null references doctor(cod_doctor),

  distancia_lente1 varchar(20) not null,
  l1_dip varchar(10) not null default '-',
  l1_esf_od varchar(20) not null default '-',
  l1_cil_od varchar(20) not null default '-',
  l1_eje_od varchar(20) not null default '-',
  l1_esf_oi varchar(20) not null default '-',
  l1_cil_oi varchar(20) not null default '-',
  l1_eje_oi varchar(20) not null default '-',

  distancia_lente2 varchar(20) not null,
  l2_dip varchar(10) not null default '-',
  l2_esf_od varchar(20) not null default '-',
  l2_cil_od varchar(20) not null default '-',
  l2_eje_od varchar(20) not null default '-',
  l2_esf_oi varchar(20) not null default '-',
  l2_cil_oi varchar(20) not null default '-',
  l2_eje_oi varchar(20) not null default '-',

  l1_cantidad_cristal integer not null default 0,
  l1_material_cristal integer not null references material_cristal(cod_material_cristal),
  l1_tipo_lente integer not null references tipo_lente(cod_tipo_lente),
  l1_color_cristal integer not null references color_cristal(cod_color_cristal),
  l1_extra_cristal varchar(100) not null default '-',

  l2_cantidad_cristal integer not null default 0,
  l2_material_cristal integer not null references material_cristal(cod_material_cristal),
  l2_tipo_lente integer not null references tipo_lente(cod_tipo_lente),
  l2_color_cristal integer not null references color_cristal(cod_color_cristal),
  l2_extra_cristal varchar(100) not null default '-',

  cod_proveedor integer not null references proveedor(cod_proveedor),
  cod_armador integer not null references armador_lente(cod_armador),
  cod_armazon integer not null references armazon_lente(cod_armazon),
  fecha_entrega date,

  num_sobre integer not null default 0,
  cod_pedido1 integer not null default 0,
  cod_pedido2 integer not null default 0,
  notas_adicionales varchar(100) not null default '-',
  fecha_registro timestamp with time zone default current_timestamp
);