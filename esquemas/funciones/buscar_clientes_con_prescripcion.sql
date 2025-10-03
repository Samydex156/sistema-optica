CREATE OR REPLACE FUNCTION buscar_clientes_con_prescripcion(
    termino_busqueda TEXT,
    limite INT,
    desplazamiento INT
)
RETURNS TABLE (
    cod_cliente INT,
    nombre_cliente VARCHAR,
    apellido_paterno_cliente VARCHAR,
    apellido_materno_cliente VARCHAR,
    telefono_cliente VARCHAR,
    fecha_registro_cliente TIMESTAMP,
    -- Columnas de la última prescripción
    cod_receta VARCHAR,
    num_sobre VARCHAR,
    cod_pedido1 VARCHAR,
    cod_pedido2 VARCHAR,
    fecha_prescripcion DATE,
    -- Conteo total para la paginación
    conteo_total BIGINT
) AS $$
BEGIN
    RETURN QUERY
    WITH ranked_prescripciones AS (
        -- Subconsulta para obtener la última prescripción de cada cliente
        SELECT 
            p.*,
            ROW_NUMBER() OVER(PARTITION BY p.cod_cliente ORDER BY p.fecha_prescripcion DESC, p.cod_prescripcion DESC) as rn
        FROM prescripcion_clienten p
    ),
    clientes_filtrados AS (
      -- Subconsulta para filtrar clientes según el término de búsqueda
      SELECT
        c.cod_cliente
      FROM
        clientes c
        LEFT JOIN ranked_prescripciones p ON c.cod_cliente = p.cod_cliente AND p.rn = 1
      WHERE
        -- Si el término de búsqueda está vacío, no se aplica filtro
        termino_busqueda IS NULL OR termino_busqueda = '' OR
        -- Búsqueda case-insensitive en múltiples campos
        (c.nombre_cliente || ' ' || c.apellido_paterno_cliente || ' ' || COALESCE(c.apellido_materno_cliente, '')) ILIKE '%' || termino_busqueda || '%' OR
        c.telefono_cliente ILIKE '%' || termino_busqueda || '%' OR
        p.cod_receta ILIKE '%' || termino_busqueda || '%' OR
        p.num_sobre ILIKE '%' || termino_busqueda || '%' OR
        p.cod_pedido1 ILIKE '%' || termino_busqueda || '%' OR
        p.cod_pedido2 ILIKE '%' || termino_busqueda || '%'
    )
    -- Consulta final que une todo y aplica paginación
    SELECT
        c.cod_cliente,
        c.nombre_cliente,
        c.apellido_paterno_cliente,
        c.apellido_materno_cliente,
        c.telefono_cliente,
        c.fecha_registro_cliente,
        p.cod_receta,
        p.num_sobre,
        p.cod_pedido1,
        p.cod_pedido2,
        p.fecha_prescripcion,
        (SELECT COUNT(*) FROM clientes_filtrados) AS conteo_total -- Obtenemos el conteo total
    FROM
        clientes c
        -- Nos unimos solo con los clientes que pasaron el filtro
        JOIN clientes_filtrados cf ON c.cod_cliente = cf.cod_cliente
        -- Obtenemos los datos de la última prescripción
        LEFT JOIN ranked_prescripciones p ON c.cod_cliente = p.cod_cliente AND p.rn = 1
    ORDER BY
        c.fecha_registro_cliente DESC
    LIMIT limite
    OFFSET desplazamiento;
END;
$$ LANGUAGE plpgsql;