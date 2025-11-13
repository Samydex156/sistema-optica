<template>
  <v-container fluid>
    
    <v-card max-width="1000" class="mx-auto" variant="flat" border>
      <v-toolbar color="grey-lighten-4">
        <v-card-title class="text-h6 font-weight-regular">
          <v-icon icon="mdi-swap-horizontal-bold" start></v-icon>
          Gestión de Inventario
        </v-card-title>
      </v-toolbar>

      <v-card-text>
        <p class="text-subtitle-1 text-grey-darken-1 mb-6">
          Realiza entradas, salidas y traspasos de productos entre tiendas.
        </p>

        <v-container>
          <v-row>
            <v-col cols="12" md="6">
              <v-autocomplete
                v-model="form.producto_id"
                :items="productoOptions"
                item-title="label"
                item-value="value"
                label="Producto"
                placeholder="Buscar producto por descripción..."
                variant="outlined"
                @update:modelValue="verificarStock"
              ></v-autocomplete>
            </v-col>

            <v-col cols="12" md="6">
              <v-radio-group 
                v-model="form.tipo_movimiento" 
                inline 
                label="Tipo de Movimiento"
              >
                <v-radio label="Entrada" value="ENTRADA"></v-radio>
                <v-radio label="Salida" value="SALIDA"></v-radio>
                <v-radio label="Traspaso" value="TRASPASO"></v-radio>
              </v-radio-group>
            </v-col>
          </v-row>
          
          <v-divider class="my-4"></v-divider>

          <v-row>
            <v-col
              v-if="form.tipo_movimiento === 'SALIDA' || form.tipo_movimiento === 'TRASPASO'"
              cols="12"
              md="6"
            >
              <v-select
                v-model="form.tienda_origen_id"
                :items="tiendas"
                item-title="nombre_tienda"
                item-value="cod_tienda"
                label="Tienda de Origen"
                variant="outlined"
                @update:modelValue="verificarStock"
              >
                <template v-slot:append-inner>
                  <v-chip
                    v-if="stockActual !== null"
                    :color="stockActual > 0 ? 'blue' : 'red'"
                    size="small"
                    label
                    variant="tonal"
                  >
                    Stock: {{ stockActual }}
                  </v-chip>
                </template>
              </v-select>
            </v-col>
            
            <v-col
              v-if="form.tipo_movimiento === 'ENTRADA' || form.tipo_movimiento === 'TRASPASO'"
              cols="12"
              md="6"
            >
              <v-select
                v-model="form.tienda_destino_id"
                :items="tiendas"
                item-title="nombre_tienda"
                item-value="cod_tienda"
                label="Tienda de Destino"
                variant="outlined"
              ></v-select>
            </v-col>

            <v-col cols="12" md="6">
              <v-text-field
                v-model.number="form.cantidad"
                label="Cantidad"
                type="number"
                min="1"
                variant="outlined"
              ></v-text-field>
            </v-col>
          </v-row>

          <v-row>
            <v-col cols="12">
              <v-text-field
                v-model.trim="form.motivo"
                label="Motivo del Movimiento"
                placeholder="Ej: Compra a proveedor, Venta, Ajuste..."
                variant="outlined"
              ></v-text-field>
            </v-col>
          </v-row>
        </v-container>
      </v-card-text>

      <v-card-actions class="pa-4 bg-grey-lighten-3">
        <v-spacer></v-spacer>
        <v-btn
          @click="ejecutarMovimiento"
          :disabled="!isFormValid"
          :loading="cargandoMovimiento"
          color="primary"
          variant="flat"
          size="large"
          prepend-icon="mdi-check-circle-outline"
        >
          Registrar Movimiento
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-container>
</template>

<script setup>
import { ref, onMounted, computed, watch } from "vue";
import { supabase } from "../lib/supabaseClient.js";
// Ya no se importa AutoComplete

// --- ESTADO ---
const form = ref({
  producto_id: null,
  tipo_movimiento: "ENTRADA",
  tienda_origen_id: null,
  tienda_destino_id: null,
  cantidad: 1,
  motivo: ""
});

const productos = ref([]);
const tiendas = ref([]);
const stockActual = ref(null);
const usuarioId = ref(1); // TODO: Reemplazar con el ID del usuario autenticado de useAuth()
const cargandoMovimiento = ref(false); // Estado de carga para el botón

// --- COMPUTED PROPERTIES ---
const productoOptions = computed(() =>
  productos.value.map(p => ({
    value: p.cod_producto,
    label: p.descripcion_producto
  }))
);

const isFormValid = computed(() => {
  if (!form.value.producto_id || form.value.cantidad <= 0 || !form.value.motivo) {
    return false;
  }
  if (form.value.tipo_movimiento === 'ENTRADA' && !form.value.tienda_destino_id) return false;
  if (form.value.tipo_movimiento === 'SALIDA' && !form.value.tienda_origen_id) return false;
  if (form.value.tipo_movimiento === 'TRASPASO' && (!form.value.tienda_origen_id || !form.value.tienda_destino_id)) return false;
  
  // Evitar traspasos a la misma tienda
  if (form.value.tipo_movimiento === 'TRASPASO' && form.value.tienda_origen_id === form.value.tienda_destino_id) {
    return false;
  }
  
  // Evitar estado de carga
  if (cargandoMovimiento.value) return false;
  
  return true;
});

// --- MÉTODOS ---
// (Lógica sin cambios)
async function fetchData() {
  const { data: productosData } = await supabase.from("productos").select("cod_producto, descripcion_producto").order("descripcion_producto");
  productos.value = productosData || [];

  const { data: tiendasData } = await supabase.from("tiendas").select("*").order("nombre_tienda");
  tiendas.value = tiendasData || [];
}

async function verificarStock() {
  stockActual.value = null;
  const tiendaId = form.value.tienda_origen_id;
  const productoId = form.value.producto_id;

  if (!tiendaId || !productoId) return;

  const { data, error } = await supabase
    .from("inventario")
    .select("cantidad_disponible")
    .eq("producto_id", productoId)
    .eq("tienda_id", tiendaId)
    .single();

  if (error && error.code !== 'PGRST116') { // PGRST116 = 'single() did not return a row'
    console.error("Error al verificar stock:", error);
  }
  
  stockActual.value = data ? data.cantidad_disponible : 0;
}

async function ejecutarMovimiento() {
  if (!isFormValid.value) {
    alert("Por favor, complete todos los campos requeridos.");
    return;
  }

  // Validar stock antes de enviar la petición para salidas y traspasos
  if ((form.value.tipo_movimiento === 'SALIDA' || form.value.tipo_movimiento === 'TRASPASO') && form.value.cantidad > stockActual.value) {
      alert(`Stock insuficiente. Disponible: ${stockActual.value}, Solicitado: ${form.value.cantidad}`);
      return;
  }

  cargandoMovimiento.value = true;

  const params = {
    p_producto_id: form.value.producto_id,
    p_tienda_origen_id: form.value.tipo_movimiento === 'ENTRADA' ? null : form.value.tienda_origen_id,
    p_tienda_destino_id: form.value.tipo_movimiento === 'SALIDA' ? null : form.value.tienda_destino_id,
    p_tipo_movimiento: form.value.tipo_movimiento,
    p_motivo: form.value.motivo,
    p_cantidad: form.value.cantidad,
    p_usuario_id: usuarioId.value
  };

  const { error } = await supabase.rpc('registrar_movimiento_inventario', params);

  if (error) {
    console.error("Error al registrar movimiento:", error);
    alert(`Error: ${error.message}`);
  } else {
    alert("¡Movimiento registrado exitosamente!");
    resetForm();
    await verificarStock(); // Actualizar el stock
  }
  
  cargandoMovimiento.value = false;
}

function resetForm() {
  form.value = {
    producto_id: null,
    tipo_movimiento: "ENTRADA",
    tienda_origen_id: null,
    tienda_destino_id: null,
    cantidad: 1,
    motivo: ""
  };
  stockActual.value = null;
}

// --- WATCHERS ---
watch(() => form.value.tipo_movimiento, (newType) => {
  // Limpiar tiendas al cambiar de tipo para evitar selecciones inválidas
  form.value.tienda_origen_id = null;
  form.value.tienda_destino_id = null;
  stockActual.value = null;
});

onMounted(fetchData);

</script>

<style scoped>

</style>