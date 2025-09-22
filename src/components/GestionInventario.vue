<template>
  <div class="inventario-container">
    <h3>Gestión de Inventario</h3>
    <p class="subtitle">Realiza entradas, salidas y traspasos de productos entre tiendas.</p>

    <div class="form-inventario">
      <div class="form-section">
        <div class="form-group">
          <label>Producto:</label>
          <AutoComplete
            v-model="form.producto_id"
            :options="productoOptions"
            placeholder="Buscar producto por descripción..."
            @change="verificarStock"
          />
        </div>

        <div class="form-group">
          <label>Tipo de Movimiento:</label>
          <div class="radio-group">
            <label><input type="radio" v-model="form.tipo_movimiento" value="ENTRADA"> Entrada</label>
            <label><input type="radio" v-model="form.tipo_movimiento" value="SALIDA"> Salida</label>
            <label><input type="radio" v-model="form.tipo_movimiento" value="TRASPASO"> Traspaso</label>
          </div>
        </div>
      </div>

      <div class="form-section tiendas-section">
        <div v-if="form.tipo_movimiento === 'SALIDA' || form.tipo_movimiento === 'TRASPASO'" class="form-group">
          <label>Tienda de Origen:</label>
          <select v-model="form.tienda_origen_id" @change="verificarStock">
            <option disabled value="">Seleccione una tienda</option>
            <option v-for="tienda in tiendas" :key="tienda.cod_tienda" :value="tienda.cod_tienda">{{ tienda.nombre_tienda }}</option>
          </select>
          <div v-if="stockActual !== null" class="stock-info">
            Stock disponible: <strong>{{ stockActual }}</strong>
          </div>
        </div>

        <div v-if="form.tipo_movimiento === 'ENTRADA' || form.tipo_movimiento === 'TRASPASO'" class="form-group">
          <label>Tienda de Destino:</label>
          <select v-model="form.tienda_destino_id">
            <option disabled value="">Seleccione una tienda</option>
            <option v-for="tienda in tiendas" :key="tienda.cod_tienda" :value="tienda.cod_tienda">{{ tienda.nombre_tienda }}</option>
          </select>
        </div>

        <div class="form-group">
          <label>Cantidad:</label>
          <input v-model.number="form.cantidad" type="number" placeholder="0" min="1" />
        </div>

        <div class="form-group">
          <label>Motivo:</label>
          <input v-model.trim="form.motivo" type="text" placeholder="Ej: Compra a proveedor, Venta, Ajuste..." />
        </div>
      </div>

      <div class="form-actions">
        <button @click="ejecutarMovimiento" :disabled="!isFormValid" class="btn-principal">
          Registrar Movimiento
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from "vue";
import { supabase } from "../lib/supabaseClient.js";
import AutoComplete from "./Autocomplete.vue"; // Reutilizamos tu componente!

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
  if (form.value.tipo_movimiento === 'TRASPASO' && form.value.tienda_origen_id === form.value.tienda_destino_id) {
    // Evitar traspasos a la misma tienda
    return false;
  }
  return true;
});

// --- MÉTODOS ---
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
  }
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
.inventario-container {
  padding: 2rem;
  background-color: #f9fafb;
}
h3 {
  font-size: 24px;
  font-weight: 600;
  border-bottom: 1px solid #e0e0e0;
  padding-bottom: 15px;
  margin-bottom: 5px;
}
.subtitle {
  color: #6b7280;
  margin-bottom: 2rem;
}
.form-inventario {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
  border: 1px solid #e5e7eb;
}
.form-section {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}
.tiendas-section {
  border-top: 1px dashed #ccc;
  padding-top: 1.5rem;
}
.form-group {
  display: flex;
  flex-direction: column;
}
.form-group label {
  font-weight: 500;
  margin-bottom: 0.5rem;
  font-size: 14px;
}
.form-group input[type="text"],
.form-group input[type="number"],
.form-group select {
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  width: 100%;
}
.radio-group {
  display: flex;
  gap: 1rem;
  align-items: center;
  padding: 8px 0;
}
.radio-group label {
  font-weight: normal;
  display: flex;
  align-items: center;
  gap: 0.3rem;
  margin: 0;
}
.stock-info {
  margin-top: 8px;
  font-size: 13px;
  color: #007bff;
}
.form-actions {
  display: flex;
  justify-content: flex-end;
  border-top: 1px solid #e0e0e0;
  padding-top: 1.5rem;
}
.btn-principal {
  background-color: #007bff;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.2s;
}
.btn-principal:hover {
  background-color: #0056b3;
}
.btn-principal:disabled {
  background-color: #a0c7f0;
  cursor: not-allowed;
}
</style>