<template>
  <v-container fluid>
    
    <v-card variant="flat" border>
      <v-toolbar color="grey-lighten-4">
        <v-card-title class="text-h6 font-weight-regular">
          <v-icon icon="mdi-clipboard-list-outline" start></v-icon>
          Consulta de Stock de Productos
        </v-card-title>
      </v-toolbar>
      <v-card-text>
        <p class="text-subtitle-1 text-grey-darken-1 mb-4">
          Visualiza las cantidades disponibles. Clic en una tarjeta para ver su historial.
        </p>

        <v-row dense>
          <v-col cols="12" md="6">
            <v-text-field
              v-model="filtroBusqueda"
              label="Buscar por nombre de producto..."
              prepend-inner-icon="mdi-magnify"
              variant="outlined"
              density="compact"
              hide-details
            ></v-text-field>
          </v-col>

          <v-col cols="12" md="6">
            <v-btn-toggle
              v-model="vista"
              variant="outlined"
              color="primary"
              mandatory
              divided
            >
              <v-btn value="resumida" prepend-icon="mdi-view-grid">
                Vista Resumida
              </v-btn>
              <v-btn value="detallada" prepend-icon="mdi-view-list">
                Vista Detallada
              </v-btn>
            </v-btn-toggle>
          </v-col>
        </v-row>
      </v-card-text>

      <v-progress-linear
        v-if="cargando"
        indeterminate
        color="primary"
      ></v-progress-linear>

      <v-window v-model="vista" v-else>
        
        <v-window-item value="resumida">
          <v-container fluid class="pa-2">
            <v-row v-if="productosFiltradosResumen.length > 0">
              <v-col
                v-for="producto in productosFiltradosResumen"
                :key="producto.cod_producto"
                cols="12"
                sm="6"
                md="4"
                lg="3"
              >
                <v-card
                  variant="outlined"
                  class="stock-card"
                  @click="mostrarHistorial(producto)"
                  title="Ver historial de movimientos"
                  :style="{ borderLeft: `5px solid ${getCardColor(producto.total_stock, producto.stock_minimo_producto)}` }"
                >
                  <v-card-title class="text-subtitle-1 pb-0">
                    {{ producto.descripcion_producto }}
                  </v-card-title>
                  <v-card-text class="text-center">
                    <div 
                      class="text-h3 font-weight-bold"
                      :class="`text-${getCardColor(producto.total_stock, producto.stock_minimo_producto)}`"
                    >
                      {{ producto.total_stock }}
                    </div>
                    <span class="text-caption text-grey">Stock Total</span>
                    <v-chip v-if="producto.stock_minimo_producto > 0" size="small" class="mt-2">
                      Mínimo: {{ producto.stock_minimo_producto }}
                    </v-chip>
                  </v-card-text>
                </v-card>
              </v-col>
            </v-row>
            <v-alert v-else type="info" variant="tonal" class="ma-2">
              No se encontraron productos con ese nombre.
            </v-alert>
          </v-container>
        </v-window-item>
        
        <v-window-item value="detallada">
          <v-table fixed-header hover density="compact">
            <thead>
              <tr>
                <th class="text-left">Producto</th>
                <th class="text-left">Tienda</th>
                <th class="text-right">Cantidad Disponible</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in productosFiltradosDetalle" :key="`${item.productos.cod_producto}-${item.tiendas.cod_tienda}`">
                <td>{{ item.productos.descripcion_producto }}</td>
                <td>{{ item.tiendas.nombre_tienda }}</td>
                <td class="text-right font-weight-bold">{{ item.cantidad_disponible }}</td>
              </tr>
              <tr v-if="productosFiltradosDetalle.length === 0">
                <td colspan="3" class="text-center pa-4 text-grey">
                  No se encontraron registros.
                </td>
              </tr>
            </tbody>
          </v-table>
        </v-window-item>
      </v-window>
    </v-card>

    <v-dialog
      v-model="showHistoryModal"
      max-width="1200px"
      persistent
    >
      <v-card>
        <v-card-title class="text-h5 pa-4 bg-grey-lighten-3">
          Historial de: {{ productoSeleccionado?.descripcion_producto }}
        </v-card-title>

        <v-card-text>
          <v-progress-linear
            v-if="cargandoHistorial"
            indeterminate
            color="primary"
            class="my-4"
          ></v-progress-linear>

          <div v-else class="historial-content">
            <v-select
              v-model="tiendaFiltro"
              label="Filtrar por tienda"
              :items="[{cod_tienda: 'todas', nombre_tienda: 'Todas las tiendas'}, ...tiendas]"
              item-title="nombre_tienda"
              item-value="cod_tienda"
              variant="outlined"
              density="compact"
              hide-details
              class="mb-4"
              style="max-width: 300px;"
            ></v-select>

            <v-table fixed-header hover density="compact">
              <thead>
                <tr>
                  <th class="text-left">Fecha y Hora</th>
                  <th class="text-left">Tipo</th>
                  <th class="text-left">Cantidad</th>
                  <th class="text-left">Tienda Origen</th>
                  <th class="text-left">Tienda Destino</th>
                  <th class="text-left">Motivo</th>
                  <th class="text-left">Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="mov in historialFiltrado" :key="mov.cod_movimiento">
                  <td>{{ new Date(mov.fecha_movimiento).toLocaleString() }}</td>
                  <td>
                    <v-chip
                      :color="getMovimientoColor(mov.tipo_movimiento)"
                      size="small"
                      label
                      variant="flat"
                    >
                      {{ mov.tipo_movimiento }}
                    </v-chip>
                  </td>
                  <td class="font-weight-bold">{{ mov.cantidad }}</td>
                  <td>{{ mov.tienda_origen?.nombre_tienda || 'N/A' }}</td>
                  <td>{{ mov.tienda_destino?.nombre_tienda || 'N/A' }}</td>
                  <td>{{ mov.motivo }}</td>
                  <td>{{ mov.usuarios?.nombre_usuario || 'N/A' }}</td>
                </tr>
                <tr v-if="historialFiltrado.length === 0">
                  <td colspan="7" class="text-center pa-4 text-grey">
                    No hay movimientos para esta selección.
                  </td>
                </tr>
              </tbody>
            </v-table>
          </div>
        </v-card-text>

        <v-card-actions class="pa-4 bg-grey-lighten-3">
          <v-spacer></v-spacer>
          <v-btn color="grey-darken-1" variant="text" @click="showHistoryModal = false">
            Cerrar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

  </v-container>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { supabase } from "../lib/supabaseClient.js";

// --- ESTADO GENERAL ---
const vista = ref('resumida'); // v-btn-toggle usará esto
const inventarioDetallado = ref([]);
const inventarioResumido = ref([]);
const tiendas = ref([]);
const filtroBusqueda = ref('');
const cargando = ref(true);

// --- ESTADO PARA EL MODAL DE HISTORIAL ---
const showHistoryModal = ref(false); // v-dialog usará esto
const productoSeleccionado = ref(null);
const movimientosProducto = ref([]);
const cargandoHistorial = ref(false);
const tiendaFiltro = ref('todas'); // v-select usará esto

// --- OBTENCIÓN DE DATOS ---
// (Lógica sin cambios)
async function getStock() {
  cargando.value = true;
  await Promise.all([
    getInventarioDetallado(),
    getInventarioResumido(),
    getTiendas()
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

// --- LÓGICA PARA MOSTRAR Y OBTENER HISTORIAL ---
// (Lógica sin cambios)
async function mostrarHistorial(producto) {
  productoSeleccionado.value = producto;
  showHistoryModal.value = true;
  cargandoHistorial.value = true;
  tiendaFiltro.value = 'todas';
  
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

// --- COMPUTED PROPERTIES ---
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

// --- FUNCIONES HELPER (Adaptadas para Vuetify) ---

/**
 * Devuelve un color de Vuetify basado en el estado del stock.
 * Se usa para el borde de la tarjeta y el color del texto.
 */
function getCardColor(cantidad, minimo) {
  if (cantidad <= 0) return 'red';
  if (cantidad > 0 && cantidad <= minimo) return 'orange';
  return 'green';
}

/**
 * Devuelve un color de Vuetify para los v-chip
 * basado en el tipo de movimiento.
 */
function getMovimientoColor(tipoMovimiento) {
  switch (tipoMovimiento.toLowerCase()) {
    case 'entrada': return 'green';
    case 'salida': return 'red';
    case 'traspaso': return 'blue';
    case 'ajuste': return 'grey';
    case 'devolucion': return 'cyan';
    default: return 'black';
  }
}

// --- CICLO DE VIDA ---
onMounted(getStock);
</script>

<style scoped>

.stock-card {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.stock-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 10px rgba(0,0,0,0.1);
}
</style>