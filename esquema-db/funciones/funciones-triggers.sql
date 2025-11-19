
-- FUNCIONES PARA ACTUALIZAR STOCK AUTOMÁTICAMENTE
CREATE OR REPLACE FUNCTION actualizar_stock_montura()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo_producto = 'MONTURA' THEN
        IF NEW.tipo_movimiento = 'ENTRADA' THEN
            INSERT INTO stock_montura (montura, tienda, cantidad_stock)
            VALUES (NEW.referencia_producto, NEW.tienda, NEW.cantidad)
            ON CONFLICT (montura, tienda)
            DO UPDATE SET 
                cantidad_stock = stock_montura.cantidad_stock + NEW.cantidad,
                fecha_actualizacion = CURRENT_TIMESTAMP;
        ELSIF NEW.tipo_movimiento = 'SALIDA' THEN
            UPDATE stock_montura 
            SET cantidad_stock = cantidad_stock - NEW.cantidad,
                fecha_actualizacion = CURRENT_TIMESTAMP
            WHERE montura = NEW.referencia_producto AND tienda = NEW.tienda;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION actualizar_stock_producto()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo_producto = 'PRODUCTO' THEN
        IF NEW.tipo_movimiento = 'ENTRADA' THEN
            INSERT INTO stock_producto (producto, tienda, cantidad_stock)
            VALUES (NEW.referencia_producto, NEW.tienda, NEW.cantidad)
            ON CONFLICT (producto, tienda)
            DO UPDATE SET 
                cantidad_stock = stock_producto.cantidad_stock + NEW.cantidad,
                fecha_actualizacion = CURRENT_TIMESTAMP;
        ELSIF NEW.tipo_movimiento = 'SALIDA' THEN
            UPDATE stock_producto 
            SET cantidad_stock = cantidad_stock - NEW.cantidad,
                fecha_actualizacion = CURRENT_TIMESTAMP
            WHERE producto = NEW.referencia_producto AND tienda = NEW.tienda;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGERS
CREATE TRIGGER trigger_actualizar_stock
    AFTER INSERT ON movimientos_inventario
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_stock_montura();

CREATE TRIGGER trigger_actualizar_stock_producto
    AFTER INSERT ON movimientos_inventario
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_stock_producto();

-- ÍNDICES PARA OPTIMIZAR CONSULTAS
CREATE INDEX idx_montura_marca_modelo ON montura(marca_montura, modelo_montura);
CREATE INDEX idx_montura_activo ON montura(activo);
CREATE INDEX idx_producto_categoria ON producto(categoria);
CREATE INDEX idx_stock_montura_tienda ON stock_montura(tienda);
CREATE INDEX idx_stock_producto_tienda ON stock_producto(tienda);
CREATE INDEX idx_movimientos_fecha ON movimientos_inventario(fecha_movimiento);
CREATE INDEX idx_movimientos_tienda ON movimientos_inventario(tienda);