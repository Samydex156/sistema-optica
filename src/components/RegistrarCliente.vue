<template>
  <div class="page-container">
    <header class="page-header">
      <h3>Gestión de Clientes</h3>
      <div class="header-actions">
        <button @click="abrirModalCrear" class="btn btn-primary">
          <span class="icon">➕</span> Nuevo Cliente
        </button>
        <button @click="getClientes" class="btn btn-secondary">
          <span class="icon">🔄</span> Actualizar
        </button>
      </div>
    </header>

    <div class="search-container">
      <input
        v-model="busqueda"
        placeholder="Buscar por nombre, apellidos o teléfono..."
        class="search-input"
      />
      <span class="search-icon">🔍</span>
    </div>

    <div class="table-responsive">
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Nombre Completo</th>
            <th>Teléfono</th>
            <th>Fecha Registro</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(cliente, index) in clientesFiltrados" :key="cliente.cod_cliente">
            <td data-label="#">{{ index + 1 }}</td>
            <td data-label="Nombre">{{ cliente.nombre_cliente }} {{ cliente.apellido_paterno_cliente }} {{ cliente.apellido_materno_cliente || '' }}</td>
            <td data-label="Teléfono">{{ cliente.telefono_cliente || '-' }}</td>
            <td data-label="Registro">{{ formatearFecha(cliente.fecha_registro_cliente) }}</td>
            <td data-label="Acciones" class="actions-cell">
              <button @click="irAPanelCliente(cliente.cod_cliente)" class="btn-icon btn-panel" title="Panel del Cliente">⚙️</button>
              <button @click="editarCliente(cliente)" class="btn-icon btn-edit" title="Editar Cliente">✏️</button>
              <button @click="eliminarCliente(cliente.cod_cliente)" class="btn-icon btn-delete" title="Eliminar Cliente">🗑️</button>
              <button @click="crearOrdenTrabajo(cliente)" class="btn btn-success btn-orden" title="Crear Nueva Orden">Nueva Orden</button>
            </td>
          </tr>
           <tr v-if="clientesFiltrados.length === 0">
            <td colspan="5" class="text-center">No se encontraron clientes.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <BaseModal v-model="showModal" :title="editId ? 'Editar Cliente' : 'Registrar Nuevo Cliente'">
      <div class="form-container">
        <input v-model="nombreCliente" placeholder="Nombre del cliente *" ref="nameCliente" class="form-input" />
        <input v-model="apellidoPaterno" placeholder="Apellido paterno *" class="form-input" />
        <input v-model="apellidoMaterno" placeholder="Apellido materno" class="form-input" />
        <input v-model="telefonoCliente" placeholder="Teléfono" class="form-input" />
      </div>
      <template #footer>
        <button @click="guardarCliente" class="btn btn-primary">Guardar</button>
        <button @click="cerrarModal" class="btn btn-secondary">Cancelar</button>
      </template>
    </BaseModal>

    <BaseModal v-model="showModalOrden" title="Crear Nueva Orden de Trabajo" size="lg">
      <p class="orden-cliente-info">
        <strong>Cliente:</strong> {{ clienteSeleccionado?.nombre_cliente }} {{ clienteSeleccionado?.apellido_paterno_cliente }}
      </p>

      <h4 class="form-section-header">Información de la Orden</h4>
      <div class="form-grid-orden-info">
          <div class="form-group">
            <label for="nro-boleta">Nro. Sobre/Boleta *</label>
            <input id="nro-boleta" ref="nroSobreOrdenInput" v-model="formOrden.nro_boleta_sobre" type="number" placeholder="Ej: 12345" class="form-input"/>
          </div>
          <div class="form-group">
            <label for="fecha-pedido">Fecha Pedido</label>
            <input id="fecha-pedido" v-model="formOrden.fecha_pedido" type="date" class="form-input" @change="actualizarFechaEntrega"/>
          </div>
          <div class="form-group">
            <label for="fecha-entrega">Fecha Entrega</label>
            <input id="fecha-entrega" v-model="formOrden.fecha_entrega" type="date" class="form-input"/>
          </div>
          <div class="form-group">
            <label for="hora-entrega">Hora Entrega</label>
            <input id="hora-entrega" v-model="formOrden.hora_entrega" type="time" class="form-input"/>
          </div>
      </div>

      <h4 class="form-section-header">Detalles Financieros</h4>
      <div class="form-grid-orden-financiero">
           <div class="form-group">
            <label for="monto-total">Monto Total (Bs.)</label>
            <input id="monto-total" v-model="formOrden.monto_total" type="number" step="0.01" @input="calcularSaldo" class="form-input"/>
          </div>
          <div class="form-group">
            <label for="monto-acuenta">A Cuenta (Bs.)</label>
            <input id="monto-acuenta" v-model="formOrden.monto_acuenta" type="number" step="0.01" @input="calcularSaldo" class="form-input"/>
          </div>
          <div class="form-group">
            <label for="monto-saldo">Saldo (Bs.)</label>
            <input id="monto-saldo" v-model="formOrden.monto_saldo" type="number" step="0.01" readonly class="form-input input-readonly" />
          </div>
      </div>

      <h4 class="form-section-header">Notas Adicionales</h4>
       <div class="form-group full-width">
          <textarea id="observaciones" v-model="formOrden.observaciones_orden" rows="3" placeholder="Anotaciones adicionales sobre la orden..." class="form-input"></textarea>
        </div>

      <template #footer>
        <button @click="cerrarModalOrden" class="btn btn-secondary">Cancelar</button>
        <button @click="guardarOrdenTrabajo" class="btn btn-primary">Guardar Orden</button>
      </template>
    </BaseModal>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, computed } from "vue";
import { useRouter } from 'vue-router';
import { supabase } from "../lib/supabaseClient.js";
import BaseModal from "./BaseModal.vue";

const router = useRouter();

const clientes = ref([]);
const showModal = ref(false);
const showModalOrden = ref(false);
const editId = ref(null);
const clienteSeleccionado = ref(null);
const busqueda = ref("");
const tiendaUsuario = ref(null);

const nombreCliente = ref("");
const apellidoPaterno = ref("");
const apellidoMaterno = ref("");
const telefonoCliente = ref("");

const formOrden = ref({
  nro_boleta_sobre: "",
  cliente: "",
  tienda: "",
  fecha_pedido: new Date().toISOString().split('T')[0],
  fecha_entrega: "",
  hora_entrega: "16:00",
  monto_total: 0,
  monto_acuenta: 0,
  monto_saldo: 0,
  observaciones_orden: "",
  estado_orden: "PENDIENTE"
});

const nameCliente = ref(null);
const nroSobreOrdenInput = ref(null);

const clientesFiltrados = computed(() => {
  if (!busqueda.value) {
    return clientes.value;
  }
  const termino = busqueda.value.toLowerCase();
  return clientes.value.filter(cliente => {
    const nombreCompleto = `${cliente.nombre_cliente} ${cliente.apellido_paterno_cliente} ${cliente.apellido_materno_cliente || ''}`.toLowerCase();
    const telefono = (cliente.telefono_cliente || '').toString().toLowerCase();
    return nombreCompleto.includes(termino) || telefono.includes(termino);
  });
});

function actualizarFechaEntrega() {
  if (formOrden.value.fecha_pedido) {
    const fechaPedido = new Date(formOrden.value.fecha_pedido + 'T00:00:00');
    fechaPedido.setDate(fechaPedido.getDate() + 2);
    formOrden.value.fecha_entrega = fechaPedido.toISOString().split('T')[0];
  }
}

async function getClientes() {
  const { data } = await supabase
    .from("clientes")
    .select("*")
    .order("fecha_registro_cliente", { ascending: false });
  clientes.value = data || [];
}

async function getTiendaDelUsuarioActual() {
    const { data, error } = await supabase.from("tiendas").select("cod_tienda").limit(1).single();
    if (error) {
        console.error("Error obteniendo la tienda por defecto:", error);
        alert("No se pudo determinar la tienda del usuario. No se podrán crear órdenes.");
    }
    if (data) {
        tiendaUsuario.value = data.cod_tienda;
    }
}

function irAPanelCliente(clienteId) {
  router.push({ name: 'PanelCliente', params: { id: clienteId } });
}

async function guardarCliente() {
  const clienteData = {
    nombre_cliente: nombreCliente.value,
    apellido_paterno_cliente: apellidoPaterno.value,
    apellido_materno_cliente: apellidoMaterno.value || null,
    telefono_cliente: telefonoCliente.value || null
  };

  try {
    let error;
    if (editId.value) {
      ({ error } = await supabase
        .from("clientes")
        .update(clienteData)
        .eq("cod_cliente", editId.value));
    } else {
      ({ error } = await supabase
        .from("clientes")
        .insert(clienteData));
    }
    
    if (error) throw error;
    
    alert(editId.value ? "Cliente actualizado exitosamente" : "Cliente creado exitosamente");
    cerrarModal();
  } catch (error) {
    alert("Error: " + error.message);
  }
}

async function eliminarCliente(id) {
  if (confirm("¿Estás seguro de que deseas eliminar este cliente?")) {
    try {
      const { error } = await supabase.from("clientes").delete().eq("cod_cliente", id);
      if (error) throw error;
      alert("Cliente eliminado exitosamente");
    } catch (error) {
      alert("Error al eliminar el cliente: " + error.message);
    }
  }
}

function editarCliente(cliente) {
  editId.value = cliente.cod_cliente;
  nombreCliente.value = cliente.nombre_cliente;
  apellidoPaterno.value = cliente.apellido_paterno_cliente;
  apellidoMaterno.value = cliente.apellido_materno_cliente || "";
  telefonoCliente.value = cliente.telefono_cliente || "";
  showModal.value = true;

  nextTick(() => {
    nameCliente.value.focus();
  });
}

function abrirModalCrear() {
  limpiarFormulario();
  showModal.value = true;

  nextTick(() => {
    nameCliente.value.focus();
  });
}

function cerrarModal() {
  showModal.value = false;
  limpiarFormulario();
}

function limpiarFormulario() {
  editId.value = null;
  nombreCliente.value = "";
  apellidoPaterno.value = "";
  apellidoMaterno.value = "";
  telefonoCliente.value = "";
}

function crearOrdenTrabajo(cliente) {
  clienteSeleccionado.value = cliente;
  limpiarFormularioOrden();
  formOrden.value.cliente = cliente.cod_cliente;
  
  showModalOrden.value = true;

  nextTick(() => {
    if (nroSobreOrdenInput.value) {
      nroSobreOrdenInput.value.focus();
    }
  });
}

async function guardarOrdenTrabajo() {
  if (!formOrden.value.nro_boleta_sobre) {
    alert("El número de sobre es requerido");
    return;
  }
  if (!tiendaUsuario.value) {
    alert("No se ha podido asignar una tienda a la orden. Recargue la página.");
    return;
  }

  const ordenData = {
    nro_boleta_sobre: parseInt(formOrden.value.nro_boleta_sobre),
    cliente: parseInt(formOrden.value.cliente),
    tienda: tiendaUsuario.value,
    fecha_pedido: formOrden.value.fecha_pedido,
    fecha_entrega: formOrden.value.fecha_entrega || null,
    hora_entrega: formOrden.value.hora_entrega || null,
    monto_total: parseFloat(formOrden.value.monto_total) || 0,
    monto_acuenta: parseFloat(formOrden.value.monto_acuenta) || 0,
    monto_saldo: parseFloat(formOrden.value.monto_saldo) || 0,
    observaciones_orden: formOrden.value.observaciones_orden || null,
    estado_orden: formOrden.value.estado_orden
  };

  try {
    const { error } = await supabase
      .from("orden_trabajo")
      .insert(ordenData);

    if (error) {
      if (error.code === '23505') {
        alert("Error: Ya existe una orden con este número de sobre.");
      } else {
        throw error;
      }
    } else {
      alert("Orden de trabajo creada exitosamente");
      cerrarModalOrden();
    }
  } catch (error) {
    alert("Error al crear la orden: " + error.message);
  }
}

function cerrarModalOrden() {
  showModalOrden.value = false;
  clienteSeleccionado.value = null;
  limpiarFormularioOrden();
}

function limpiarFormularioOrden() {
  const hoy = new Date().toISOString().split('T')[0];
  formOrden.value = {
    nro_boleta_sobre: "",
    cliente: "",
    tienda: "",
    fecha_pedido: hoy,
    fecha_entrega: "",
    hora_entrega: "16:00",
    monto_total: 0,
    monto_acuenta: 0,
    monto_saldo: 0,
    observaciones_orden: "",
    estado_orden: "PENDIENTE"
  };
  actualizarFechaEntrega();
}

function calcularSaldo() {
  const total = parseFloat(formOrden.value.monto_total) || 0;
  const acuenta = parseFloat(formOrden.value.monto_acuenta) || 0;
  formOrden.value.monto_saldo = total - acuenta;
}

function formatearFecha(fecha) {
  if (!fecha) return '-';
  const fechaLocal = new Date(fecha + 'T00:00:00');
  return fechaLocal.toLocaleDateString('es-ES', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  });
}

function subscribeToClientes() {
  const channel = supabase
    .channel("clientes")
    .on(
      "postgres_changes",
      { event: "*", schema: "public", table: "clientes" },
      (payload) => {
        if (payload.eventType === "INSERT") {
          clientes.value.unshift(payload.new);
        } else if (payload.eventType === "UPDATE") {
          const index = clientes.value.findIndex(c => c.cod_cliente === payload.new.cod_cliente);
          if (index !== -1) {
            clientes.value[index] = payload.new;
          }
        } else if (payload.eventType === "DELETE") {
          clientes.value = clientes.value.filter(
            (c) => c.cod_cliente !== payload.old.cod_cliente
          );
        }
      }
    )
    .subscribe();
  return () => supabase.removeChannel(channel);
}

onMounted(() => {
  getClientes();
  getTiendaDelUsuarioActual();
  const unsubscribe = subscribeToClientes();
  onUnmounted(unsubscribe);
});
</script>

<style scoped>
:root {
  --primary-color: #005A9C;
  --secondary-color: #6c757d;
  --success-color: #28a745;
  --danger-color: #dc3545;
  --warning-color: #ffc107;
  --light-gray: #f8f9fa;
  --border-color: #dee2e6;
  --text-color: #212529;
  --text-color-light: #ffffff;
  --font-family: 'Segoe UI', system-ui, sans-serif;
}

.page-container {
  font-family: 'Segoe UI', system-ui, sans-serif;
  padding: 24px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #dee2e6;
}

.page-header h3 {
  margin: 0;
  color: #212529;
  font-size: 1.75rem;
  font-weight: 600;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 8px 10px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 12px;
  font-weight: 500;
  text-decoration: none;
  transition: all 0.1s;
  }
.btn .icon {
  font-size: 16px;
}
.btn:hover {
  transform: translateY(-2px);
  box-shadow: 4px 4px 8px rgba(0,0,0,0.1);
}
.btn-primary { background-color: #b1e2eb}
.btn-primary:hover { background-color: #338fcc; color:white }
.btn-secondary { background-color: #b1e2eb; }
.btn-secondary:hover { background-color: #338fcc; color: white }
.btn-success { background-color: #51db7f; }
.btn-success:hover { background-color: #218838; }

.btn-icon {
  background: none;
  border: 1px solid transparent;
  padding: 1px;
  border-radius: 50%;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.1s;
  width: 32px;
  height: 32px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.btn-icon:hover {
  background-color: #ffffff;
}
.btn-edit { color: #51db7f; }
.btn-delete { color: #dc3545; }
.btn-panel { color: #005A9C; }


.search-container {
  position: relative;
  margin-bottom: 20px;
}

.search-input {
  width: 100%;
  padding: 10px 40px 12px 16px;
  font-size: 14px;
  border: 1px solid #b6b6b6;
  border-radius: 10px;
  box-sizing: border-box;
  transition: border-color 0.1s, box-shadow 0.1s;
}
.search-input:focus {
  outline: none;
  border-color: #b6b6b6;
  box-shadow: 0 0 0 3px rgba(0, 90, 156, 0.2);
}

.search-icon {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: #999;
}

.table-responsive {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  background-color: #ffffff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  border-radius: 8px;
  overflow: hidden;
}

th, td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #b6b6b6;
}

th {
  background-color: #6c757d;
  font-size: 12px;
  font-weight: 600;
  color: #ffffff;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

tr:nth-child(even) {
  background-color: #fdfdfd;
}

tr:hover {
  background-color: #f3f3f3;
}

td {
  font-size: 12px;
  color: #212529;
}
.actions-cell {
  display: flex;
  align-items: center;
  gap: 5px;
}
.text-center {
  text-align: center;
  color: #777;
  padding: 24px;
}

/* --- INICIO: ESTILOS DE FORMULARIO --- */
.form-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-input {
  width: 100%;
  padding: 12px 16px;
  font-size: 14px;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  transition: border-color 0.2s, box-shadow 0.2s;
  box-sizing: border-box;
}

.form-input:focus {
  outline: none;
  border-color: #1163b4;
  box-shadow: 5px 2px 0 3px rgba(0, 90, 156, 0.5);
}

.input-readonly {
  background-color: #e9ecef;
  cursor: not-allowed;
}

.form-section-header {
  font-size: 16px;
  font-weight: 600;
  color: #343a40;
  margin: 20px 0 15px 0;
  padding-bottom: 8px;
  border-bottom: 1px solid #e0e0e0;
}
.form-section-header:first-of-type {
  margin-top: 0;
}

.form-grid-orden-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 16px;
}

.form-grid-orden-financiero {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-group label {
  font-weight: 500;
  color: #444;
  font-size: 13px;
  white-space: nowrap;
}

.orden-cliente-info {
  font-size: 1rem;
  padding: 12px 16px;
  background-color: #e7f3ff;
  border: 1px solid #b3d7ff;
  border-radius: 6px;
  margin-bottom: 20px;
}
/* --- FIN: ESTILOS DE FORMULARIO --- */

@media (max-width: 768px) {
  .form-grid-orden-info,
  .form-grid-orden-financiero {
    grid-template-columns: 1fr;
  }
}
</style>