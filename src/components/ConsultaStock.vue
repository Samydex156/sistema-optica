<template>
  <div class="consulta-stock-container">
    <h3>Consulta de Stock de Productos</h3>
    <p class="subtitle">Visualiza las cantidades disponibles. Haz clic en una tarjeta para ver su historial.</p>

    <div class="toolbar">
      <div class="search-container">
        <input type="text" v-model="filtroBusqueda" placeholder="🔍 Buscar por nombre de producto..." class="search-input"/>
      </div>
      <div class="view-toggle">
        <button @click="vista = 'resumida'" :class="{ active: vista === 'resumida' }">Vista Resumida</button>
        <button @click="vista = 'detallada'" :class="{ active: vista === 'detallada' }">Vista Detallada</button>
      </div>
    </div>

    <div v-if="cargando" class="loading-indicator">
      Cargando datos de inventario...
    </div>

    <div v-else>
      <div v-if="vista === 'resumida'" class="stock-grid">
        <div 
          v-for="producto in productosFiltradosResumen" 
          :key="producto.cod_producto" 
          class="stock-card clickable" 
          :class="getCardColor(producto.total_stock, producto.stock_minimo_producto)"
          @click="mostrarHistorial(producto)"
          title="Ver historial de movimientos"
        >
          <h4>{{ producto.descripcion_producto }}</h4>
          <p class="total-stock">{{ producto.total_stock }}</p>
          <span class="stock-label">Stock Total</span>
          <small v-if="producto.stock_minimo_producto > 0" class="stock-minimo">
            Mínimo: {{ producto.stock_minimo_producto }}
          </small>
        </div>
        <p v-if="productosFiltradosResumen.length === 0" class="no-results">No se encontraron productos con ese nombre.</p>
      </div>

      <div v-if="vista === 'detallada'" class="table-container">
        <table>
          <thead>
            <tr>
              <th>Producto</th>
              <th>Tienda</th>
              <th>Cantidad Disponible</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in productosFiltradosDetalle" :key="`${item.productos.cod_producto}-${item.tiendas.cod_tienda}`">
              <td>{{ item.productos.descripcion_producto }}</td>
              <td>{{ item.tiendas.nombre_tienda }}</td>
              <td class="cantidad">{{ item.cantidad_disponible }}</td>
            </tr>
             <tr v-if="productosFiltradosDetalle.length === 0">
                <td colspan="3" class="no-results-table">No se encontraron registros.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <BaseModal 
      v-model="showHistoryModal" 
      :title="`Historial de: ${productoSeleccionado?.descripcion_producto}`" 
      size="lg"
    >
      <div v-if="cargandoHistorial" class="loading-indicator">Cargando historial...</div>
      <div v-else class="historial-content">
        <div class="historial-filtro">
          <label for="tienda-filtro">Filtrar por tienda:</label>
          <select id="tienda-filtro" v-model="tiendaFiltro">
            <option value="todas">Todas las tiendas</option>
            <option v-for="tienda in tiendas" :key="tienda.cod_tienda" :value="tienda.cod_tienda">
              {{ tienda.nombre_tienda }}
            </option>
          </select>
        </div>

        <div class="table-container-modal">
          <table>
            <thead>
              <tr>
                <th>Fecha y Hora</th>
                <th>Tipo</th>
                <th>Cantidad</th>
                <th>Tienda Origen</th>
                <th>Tienda Destino</th>
                <th>Motivo</th>
                <th>Usuario</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="mov in historialFiltrado" :key="mov.cod_movimiento">
                <td>{{ new Date(mov.fecha_movimiento).toLocaleString() }}</td>
                <td><span class="badge" :class="`badge-${mov.tipo_movimiento.toLowerCase()}`">{{ mov.tipo_movimiento }}</span></td>
                <td class="cantidad-movimiento">{{ mov.cantidad }}</td>
                <td>{{ mov.tienda_origen?.nombre_tienda || 'N/A' }}</td>
                <td>{{ mov.tienda_destino?.nombre_tienda || 'N/A' }}</td>
                <td class="motivo">{{ mov.motivo }}</td>
                <td>{{ mov.usuarios?.nombre_usuario || 'N/A' }}</td>
              </tr>
              <tr v-if="historialFiltrado.length === 0">
                <td colspan="7" class="no-results-table">No hay movimientos para esta selección.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <template #footer>
        <button @click="showHistoryModal = false" class="btn-secondary">Cerrar</button>
      </template>
    </BaseModal>

  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { supabase } from "../lib/supabaseClient.js";
import BaseModal from "./BaseModal.vue"; // Importamos el modal

// --- ESTADO GENERAL ---
const vista = ref('resumida');
const inventarioDetallado = ref([]);
const inventarioResumido = ref([]);
const tiendas = ref([]);
const filtroBusqueda = ref('');
const cargando = ref(true);

// --- NUEVO: ESTADO PARA EL MODAL DE HISTORIAL ---
const showHistoryModal = ref(false);
const productoSeleccionado = ref(null);
const movimientosProducto = ref([]);
const cargandoHistorial = ref(false);
const tiendaFiltro = ref('todas');

// --- OBTENCIÓN DE DATOS ---
async function getStock() {
  cargando.value = true;
  await Promise.all([
    getInventarioDetallado(),
    getInventarioResumido(),
    getTiendas() // Necesitamos la lista de tiendas para el filtro
  ]);
  cargando.value = false;
}

async function getInventarioDetallado() {
  const { data, error } = await supabase
    .from('inventario')
    .select(`*, productos(*), tiendas(*)`)
    .order('cantidad_disponible', { ascending: false });
  if (error) console.error("Error fetching detailed stock:", error);
  else inventarioDetallado.value = data;
}

async function getInventarioResumido() {
  const { data, error } = await supabase
    .from('productos')
    .select(`*, inventario(cantidad_disponible)`);
  if (error) console.error("Error fetching summarized stock:", error);
  else {
    inventarioResumido.value = data.map(p => ({
      ...p,
      total_stock: p.inventario.reduce((sum, item) => sum + item.cantidad_disponible, 0)
    }))
    .sort((a, b) => a.descripcion_producto.localeCompare(b.descripcion_producto));
  }
}

async function getTiendas() {
  const { data } = await supabase.from("tiendas").select("*").order("nombre_tienda");
  tiendas.value = data || [];
}

// --- NUEVO: LÓGICA PARA MOSTRAR Y OBTENER HISTORIAL ---
async function mostrarHistorial(producto) {
  productoSeleccionado.value = producto;
  showHistoryModal.value = true;
  cargandoHistorial.value = true;
  tiendaFiltro.value = 'todas'; // Reseteamos el filtro
  
  const { data, error } = await supabase
    .from('movimientos_inventario')
    .select(`
      *,
      tienda_origen:tiendas!movimientos_inventario_tienda_origen_id_fkey(nombre_tienda),
      tienda_destino:tiendas!movimientos_inventario_tienda_destino_id_fkey(nombre_tienda),
      usuarios(nombre_usuario)
    `)
    .eq('producto_id', producto.cod_producto)
    .order('fecha_movimiento', { ascending: false });

  if (error) {
    console.error("Error al obtener historial:", error);
    alert("No se pudo cargar el historial del producto.");
  } else {
    movimientosProducto.value = data;
  }
  cargandoHistorial.value = false;
}

// --- COMPUTED PROPERTIES (Añadimos el filtro de historial) ---
const productosFiltradosResumen = computed(() => {
  if (!filtroBusqueda.value) return inventarioResumido.value;
  return inventarioResumido.value.filter(p =>
    p.descripcion_producto.toLowerCase().includes(filtroBusqueda.value.toLowerCase())
  );
});

const productosFiltradosDetalle = computed(() => {
  if (!filtroBusqueda.value) return inventarioDetallado.value;
  return inventarioDetallado.value.filter(item =>
    item.productos.descripcion_producto.toLowerCase().includes(filtroBusqueda.value.toLowerCase())
  );
});

const historialFiltrado = computed(() => {
  if (tiendaFiltro.value === 'todas') {
    return movimientosProducto.value;
  }
  const idTienda = parseInt(tiendaFiltro.value);
  return movimientosProducto.value.filter(mov => 
    mov.tienda_origen_id === idTienda || mov.tienda_destino_id === idTienda
  );
});

// --- LÓGICA ADICIONAL (sin cambios) ---
function getCardColor(cantidad, minimo) {
  if (cantidad <= 0) return 'stock-cero';
  if (cantidad <= minimo) return 'stock-bajo';
  return 'stock-ok';
}

// --- CICLO DE VIDA ---
onMounted(getStock);
</script>

<style scoped>
/* --- ESTILOS EXISTENTES (Añadimos .clickable) --- */
.consulta-stock-container { padding: 2rem; background-color: #f9fafb; }
h3 { font-size: 24px; font-weight: 600; border-bottom: 1px solid #e0e0e0; padding-bottom: 15px; margin-bottom: 5px; }
.subtitle { color: #6b7280; margin-bottom: 2rem; }
.toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem; }
.search-input { padding: 10px 15px; border: 1px solid #ced4da; border-radius: 6px; min-width: 300px; font-size: 14px; }
.view-toggle button { padding: 10px 20px; border: 1px solid #007bff; background-color: white; color: #007bff; cursor: pointer; }
.view-toggle button:first-child { border-top-left-radius: 6px; border-bottom-left-radius: 6px; }
.view-toggle button:last-child { border-top-right-radius: 6px; border-bottom-right-radius: 6px; border-left: none; }
.view-toggle button.active { background-color: #007bff; color: white; }
.stock-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 1.5rem; }
.stock-card { background-color: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-left: 5px solid; text-align: center; }
.stock-card h4 { margin: 0 0 0.5rem 0; font-size: 1rem; color: #333; }
.total-stock { font-size: 2.5rem; font-weight: 700; margin: 0; }
.stock-label { color: #6c757d; font-size: 0.9rem; }
.stock-minimo { display: block; margin-top: 10px; font-size: 0.8rem; color: #4b5563; background-color: #f3f4f6; padding: 3px 6px; border-radius: 4px; }
.stock-ok { border-color: #28a745; }
.stock-ok .total-stock { color: #28a745; }
.stock-bajo { border-color: #ffc107; }
.stock-bajo .total-stock { color: #ffc107; }
.stock-cero { border-color: #dc3545; }
.stock-cero .total-stock { color: #dc3545; }
.table-container { background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
table { width: 100%; border-collapse: collapse; }
th { background: #343a40; color: white; padding: 12px 15px; text-align: left; font-size: 13px; font-weight: 500; }
td { padding: 12px 15px; border-bottom: 1px solid #dee2e6; font-size: 14px; }
tr:last-child td { border-bottom: none; }
tr:hover { background: #f8f9fa; }
td.cantidad { font-weight: 600; text-align: right; }
.loading-indicator, .no-results, .no-results-table { text-align: center; padding: 3rem; color: #6c757d; font-size: 1.1rem; }

/* --- NUEVOS ESTILOS --- */
.clickable { cursor: pointer; transition: transform 0.2s ease, box-shadow 0.2s ease; }
.clickable:hover { transform: translateY(-5px); box-shadow: 0 8px 15px rgba(0,0,0,0.1); }
.historial-content { display: flex; flex-direction: column; gap: 1.5rem; }
.historial-filtro { display: flex; align-items: center; gap: 0.5rem; padding-bottom: 1rem; border-bottom: 1px solid #eee; }
.historial-filtro label { font-weight: 500; }
.historial-filtro select { padding: 8px; border-radius: 4px; border: 1px solid #ccc; font-size: 14px; }
.table-container-modal { max-height: 55vh; overflow-y: auto; }
.badge { padding: 0.25em 0.6em; font-size: 75%; font-weight: 700; line-height: 1; text-align: center; white-space: nowrap; vertical-align: baseline; border-radius: 0.375rem; color: #fff; }
.badge-entrada { background-color: #28a745; }
.badge-salida { background-color: #dc3545; }
.badge-traspaso { background-color: #007bff; }
.badge-ajuste { background-color: #6c757d; }
.badge-devolucion { background-color: #17a2b8; }
.btn-secondary { background-color: #6c757d; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
.btn-secondary:hover { background-color: #5a6268; }
td.motivo { max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
td.cantidad-movimiento { font-weight: bold; text-align: center; }
</style>