create table public.pagos_orden (
  cod_pago serial not null,
  nro_boleta_sobre integer not null default 0,
  tipo_pago character varying(20) not null default 'EFECTIVO'::character varying,
  monto_pago numeric(10, 2) not null default 0.00,
  fecha_pago date null,
  constraint pagos_orden_pkey primary key (cod_pago)
) TABLESPACE pg_default;