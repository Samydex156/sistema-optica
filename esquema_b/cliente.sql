create table cliente (
  cod_cliente serial primary key,
  nombre varchar(30) not null default 'Sin nombre',
  apellido_paterno varchar(30) not null default '-',
  apellido_materno varchar(30) not null default '-',
  telefono_cliente varchar(30) not null default '-',
  fecha_registro timestamp with time zone default current_timestamp
);