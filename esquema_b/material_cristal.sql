create table material_cristal(
    cod_material_cristal serial primary key,
    nombre_material_cristal varchar(50) not null default '-',
    descripcion_material_cristal varchar(50) not null default '-',
    fecha_registro timestamp with time zone default current_timestamp
);