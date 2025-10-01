create table public.medida_lente (
  cod_medida_lente serial not null,
  prescripcion integer not null,
  tipo_lente character varying(20) not null default 'LEJOS'::character varying,
  esf_od character varying(10) not null default '-'::character varying,
  cil_od character varying(10) not null default '-'::character varying,
  eje_od smallint not null default 0,
  prisma_od character varying(10) not null default '0.00'::character varying,
  base_od character varying(10) null default null::character varying,
  altura_od character varying(10) not null default '0.00'::character varying,
  adic_od character varying(10) not null default '0.00'::character varying,
  esf_oi character varying(10) not null default '-'::character varying,
  cil_oi character varying(10) not null default '-'::character varying,
  eje_oi smallint not null default 0,
  prisma_oi character varying(10) not null default '0.00'::character varying,
  base_oi character varying(10) null default null::character varying,
  altura_oi character varying(10) not null default '0.00'::character varying,
  adic_oi character varying(10) not null default '0.00'::character varying,
  dip_lentes_binocular character varying(10) null,
  dip_lentes_od_monocular numeric(5, 2) null,
  dip_lentes_oi_monocular numeric(5, 2) null,
  fecha_creacion_medida timestamp without time zone not null default CURRENT_TIMESTAMP,
  constraint medida_lente_pkey primary key (cod_medida_lente),
  constraint medida_lente_prescripcion_fkey foreign KEY (prescripcion) references prescripcion_cliente (cod_prescripcion) on update CASCADE on delete CASCADE,
  constraint chk_prisma_base_od check (
    (
      (
        ((prisma_od)::text = '0.00'::text)
        and (base_od is null)
      )
      or (
        ((prisma_od)::text <> '0.00'::text)
        and (
          (base_od)::text = any (
            (
              array[
                'NASAL'::character varying,
                'TEMPORAL'::character varying,
                'SUPERIOR'::character varying,
                'INFERIOR'::character varying
              ]
            )::text[]
          )
        )
      )
    )
  ),
  constraint chk_prisma_base_oi check (
    (
      (
        ((prisma_oi)::text = '0.00'::text)
        and (base_oi is null)
      )
      or (
        ((prisma_oi)::text <> '0.00'::text)
        and (
          (base_oi)::text = any (
            (
              array[
                'NASAL'::character varying,
                'TEMPORAL'::character varying,
                'SUPERIOR'::character varying,
                'INFERIOR'::character varying
              ]
            )::text[]
          )
        )
      )
    )
  )
) TABLESPACE pg_default;