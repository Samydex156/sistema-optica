create table doctor_prescriptor(
    cod_doctor serial primary key,
    nombre_doctor varchar(30) not null default 'Sin nombre',
    apaterno_doctor varchar(30) not null default '-',
    amaterno_doctor varchar(30) not null default '-',
    direccion_doctor varchar(70) not null default '-',
    telefono_doctor varchar(30) not null default '-',
    email_doctor varchar(50) not null default '-',
    especialidad_doctor varchar(50) not null default '-',
    fecha_registro timestamp with time zone default current_timestamp
);