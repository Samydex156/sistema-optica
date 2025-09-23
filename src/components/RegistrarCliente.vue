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
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(cliente, index) in clientesFiltrados" :key="cliente.cod_cliente">
            <td data-label="#">{{ index + 1 }}</td>
            <td data-label="Nombre">{{ cliente.nombre_cliente }} {{ cliente.apellido_paterno_cliente }} {{ cliente.apellido_materno_cliente || '' }}</td>
            <td data-label="Teléfono">{{ cliente.telefono_cliente || '-' }}</td>

            <td data-label="Acciones" class="actions-cell">
              <button @click="irAPanelCliente(cliente.cod_cliente)" class="btn-icon btn-panel" title="Panel del Cliente">⚙️</button>
              <button @click="editarCliente(cliente)" class="btn-icon btn-edit" title="Editar Cliente">✏️</button>
              <button @click="eliminarCliente(cliente.cod_cliente)" class="btn-icon btn-delete" title="Eliminar Cliente">🗑️</button>
              <!-- BOTÓN DE 'NUEVA ORDEN' ELIMINADO DE AQUÍ -->
            </td>
          </tr>
           <tr v-if="clientesFiltrados.length === 0">
            <td colspan="5" class="text-center">No se encontraron clientes.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal para Crear/Editar Cliente (sin cambios) -->
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

    <!-- MODAL DE 'NUEVA ORDEN' ELIMINADO DE AQUÍ -->
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
const editId = ref(null);
const busqueda = ref("");

const nombreCliente = ref("");
const apellidoPaterno = ref("");
const apellidoMaterno = ref("");
const telefonoCliente = ref("");

const nameCliente = ref(null);

// LÓGICA DE ÓRDENES COMPLETAMENTE ELIMINADA DEL SCRIPT

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

async function getClientes() {
  const { data } = await supabase
    .from("clientes")
    .select("*")
    .order("fecha_registro_cliente", { ascending: false });
  clientes.value = data || [];
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
      ({ error } = await supabase.from("clientes").update(clienteData).eq("cod_cliente", editId.value));
    } else {
      ({ error } = await supabase.from("clientes").insert(clienteData));
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
  nextTick(() => { nameCliente.value.focus(); });
}

function abrirModalCrear() {
  limpiarFormulario();
  showModal.value = true;
  nextTick(() => { nameCliente.value.focus(); });
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

function subscribeToClientes() {
  const channel = supabase
    .channel("clientes")
    .on("postgres_changes", { event: "*", schema: "public", table: "clientes" },
      (payload) => {
        if (payload.eventType === "INSERT") {
          clientes.value.unshift(payload.new);
        } else if (payload.eventType === "UPDATE") {
          const index = clientes.value.findIndex(c => c.cod_cliente === payload.new.cod_cliente);
          if (index !== -1) clientes.value[index] = payload.new;
        } else if (payload.eventType === "DELETE") {
          clientes.value = clientes.value.filter(c => c.cod_cliente !== payload.old.cod_cliente);
        }
      }
    ).subscribe();
  return () => supabase.removeChannel(channel);
}

onMounted(() => {
  getClientes();
  const unsubscribe = subscribeToClientes();
  onUnmounted(unsubscribe);
});
</script>

<style scoped>
/* ESTILOS SIN CAMBIOS - SOLO SE MANTIENEN LOS NECESARIOS PARA ESTE COMPONENTE */
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
</style>
