<template>
  <div class="page-container">
    <header class="page-header">
      <h1>Gestión de Clientes</h1>
      <div class="header-actions">
        <button @click="abrirModalCrear" class="btn btn-primary">
          &#10010; Nuevo Cliente
        </button>
      </div>
    </header>

    <div class="search-container">
      <span class="search-icon">&#128269;</span>
      <input
        v-model="busqueda"
        placeholder="Buscar cliente por nombre, teléfono, cód. receta, nro. sobre o pedido."
        class="search-input"
        ref="searchInputRef"
      />
    </div>
    
    <div v-if="cargando" class="loading-indicator">Cargando clientes...</div>

    <div v-else class="table-responsive">
      <table>
        <thead>
          <tr>
            <th>Nombre Completo</th>
            <th>Teléfono</th>
            <th>Cód. Receta</th>
            <th>Nro. Sobre</th>
            <th>Nro. Pedido</th>
            <th class="text-center">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="clientes.length === 0">
            <td colspan="6" class="no-results">No se encontraron clientes.</td>
          </tr>
          <tr v-for="cliente in clientes" :key="cliente.cod_cliente">
            <td data-label="Nombre">{{ cliente.nombreCompleto }}</td>
            <td data-label="Teléfono">{{ cliente.telefono_cliente || '-' }}</td>
            <td data-label="Cód. Receta">{{ cliente.cod_receta || '-' }}</td>
            <td data-label="Nro. Sobre">{{ cliente.num_sobre || '-' }}</td>
            <td data-label="Nro. Pedido">{{ cliente.pedidos || '-' }}</td>
            <td data-label="Acciones" class="actions-cell">
              <button @click="irAPanelCliente(cliente.cod_cliente)" class="btn-icon btn-panel" title="Ver Panel del Cliente">&#128221;</button>
              <button @click="editarCliente(cliente)" class="btn-icon btn-edit" title="Editar Cliente">&#9998;</button>
              <button @click="eliminarCliente(cliente.cod_cliente)" class="btn-icon btn-delete" title="Eliminar Cliente">&#128465;</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="!cargando && totalPaginas > 1" class="pagination-container">
      <button @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1" class="btn-pagination">
        &laquo; Anterior
      </button>
      <span class="pagination-info">
        Página {{ paginaActual }} de {{ totalPaginas }}
      </span>
      <button @click="cambiarPagina(paginaActual + 1)" :disabled="paginaActual === totalPaginas" class="btn-pagination">
        Siguiente &raquo;
      </button>
    </div>
    <BaseModal v-model="showModal" :title="editId ? 'Editar Cliente' : 'Registrar Nuevo Cliente'">
      <div class="form-container">
        <input v-model="nombreCliente" placeholder="Nombre del cliente *" ref="nameCliente" class="form-input" />
        <input v-model="apellidoPaterno" placeholder="Apellido paterno *" class="form-input" />
        <input v-model="apellidoMaterno" placeholder="Apellido materno" class="form-input" />
        <input v-model="telefonoCliente" placeholder="Teléfono" class="form-input" />
      </div>
      <template #footer>
        <button @click="cerrarModal" class="btn btn-secondary">Cancelar</button>
        <button @click="guardarCliente" class="btn btn-primary">Guardar</button>
      </template>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick, computed, watch } from "vue";
import { useRouter } from 'vue-router';
import { supabase } from "../lib/supabaseClient.js";
import BaseModal from "./BaseModal.vue";
import { debounce } from 'lodash-es';

const router = useRouter();

const clientes = ref([]);
const cargando = ref(true);
const showModal = ref(false);
const editId = ref(null);
const busqueda = ref("");

const paginaActual = ref(1);
const clientesPorPagina = ref(20);
const totalClientes = ref(0);

const nombreCliente = ref("");
const apellidoPaterno = ref("");
const apellidoMaterno = ref("");
const telefonoCliente = ref("");
const nameCliente = ref(null);
const searchInputRef = ref(null);

const totalPaginas = computed(() => {
  return Math.ceil(totalClientes.value / clientesPorPagina.value);
});

async function fetchClientes() {
  cargando.value = true;
  try {
    const limite = clientesPorPagina.value;
    const desplazamiento = (paginaActual.value - 1) * limite;

    const { data, error } = await supabase.rpc('buscar_clientes_con_prescripcion', {
      termino_busqueda: busqueda.value,
      limite: limite,
      desplazamiento: desplazamiento
    });
    
    if (error) throw error;

    clientes.value = (data || []).map(cliente => {
      const pedidos = [cliente.cod_pedido1, cliente.cod_pedido2].filter(p => {
        const val = (p || '').toString().trim();
        return val !== '' && val !== '0' && val !== '-';
      }).join(', ');
      
      return {
        ...cliente,
        nombreCompleto: `${cliente.nombre_cliente} ${cliente.apellido_paterno_cliente} ${cliente.apellido_materno_cliente || ''}`.trim(),
        pedidos: pedidos || '-'
      };
    });
    
    if (data && data.length > 0) {
      totalClientes.value = data[0].conteo_total;
    } else {
      totalClientes.value = 0;
    }

  } catch (error) {
    console.error("Error al obtener clientes:", error);
    alert("No se pudieron cargar los datos de los clientes.");
  } finally {
    cargando.value = false;
  }
}

watch(busqueda, debounce(() => {
  paginaActual.value = 1;
  fetchClientes();
}, 500));

function cambiarPagina(nuevaPagina) {
  if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
    paginaActual.value = nuevaPagina;
    fetchClientes();
  }
}

function irAPanelCliente(clienteId) {
  router.push({ name: 'PanelCliente', params: { id: clienteId } });
}

async function guardarCliente() {
  if (!nombreCliente.value.trim() || !apellidoPaterno.value.trim()) {
      alert("El nombre y el apellido paterno son obligatorios.");
      return;
  }
  
  // ---> INICIO: Lógica para convertir a mayúsculas antes de guardar
  const clienteData = {
    nombre_cliente: nombreCliente.value.trim().toUpperCase(),
    apellido_paterno_cliente: apellidoPaterno.value.trim().toUpperCase(),
    apellido_materno_cliente: apellidoMaterno.value.trim() ? apellidoMaterno.value.trim().toUpperCase() : null,
    telefono_cliente: telefonoCliente.value.trim() || null
  };
  // ---> FIN: Lógica para convertir a mayúsculas
  
  if (editId.value) {
    clienteData.cod_cliente = editId.value;
  }
  
  try {
    const { error } = await supabase.from("clientes").upsert(clienteData);
    if (error) throw error;
    alert(editId.value ? "Cliente actualizado exitosamente" : "Cliente creado exitosamente");
    cerrarModal();
    fetchClientes();
  } catch (error) {
    alert("Error al guardar el cliente: " + error.message);
  }
}

async function eliminarCliente(id) {
  if (confirm("¿Está seguro de que desea eliminar este cliente? Esta acción no se puede deshacer.")) {
    try {
      await supabase.from("prescripcion_clienten").delete().eq("cod_cliente", id);
      const { error } = await supabase.from("clientes").delete().eq("cod_cliente", id);
      if (error) throw error;
      alert("Cliente eliminado exitosamente");
      fetchClientes();
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

onMounted(() => {
  fetchClientes();
  nextTick(()=>{
    searchInputRef.value?.focus();
  });
});

</script>

<style scoped>
.page-container {
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  padding: .1rem 3rem;
  background-color: #f8f9fa;
  color: #212529;
}
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding-bottom: .5rem;
  border-bottom: 1px solid #b4b4b4;
}
.page-header h1 {
  margin: 0;
  font-size: 1.75rem;
  font-weight: 600;
}
.btn {
  padding: 0.6rem 4rem;
  border: 1px solid transparent;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: background-color 0.2s, color 0.2s, box-shadow 0.2s;
}
.btn-primary {
  background-color: #005A9C;
  color: white;
}
.btn-primary:hover {
  background-color: #00487c;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}
.btn-secondary {
  background-color: #6c757d;
  color: white;
}
.btn-secondary:hover {
  background-color: #5a6268;
}
.btn-icon {
  background-color: transparent;
  border: none;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  font-size: 1.1rem;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.2s;
}
.btn-icon:hover {
  background-color: #e6f0f7;
}
.btn-panel { color: #0d6efd; }
.btn-edit { color: #198754; }
.btn-delete { color: #dc3545; }
.search-container {
  position: relative;
  margin-bottom: 2rem;
  box-shadow: 5px 5px 5px #b6b6b6;
}
.search-input {
  width: 100%;
  padding: 0.75rem 1rem 0.75rem 2.5rem;
  font-size: 1rem;
  border: 1px solid #7c7c7c;
  border-radius: 6px;
  box-sizing: border-box;
  transition: border-color 0.2s, box-shadow 0.2s;
}
.search-input:focus {
  outline: none;
  border-color: #005A9C;
  box-shadow: 0 0 0 3px rgba(0, 90, 156, 0.2);
}
.search-icon {
  position: absolute;
  left: 0.75rem;
  top: 50%;
  transform: translateY(-50%);
  color: #6c757d;
  font-size: 1.2rem;
}
.table-responsive {
  overflow-x: auto;
  background-color: #ffffff;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}
table {
  width: 100%;
  border-collapse: collapse;
}
th, td {
  padding: .2rem 2rem;
  text-align: left;
  border-bottom: 1px solid #dee2e6;
  vertical-align: middle;
}
thead {
  background-color: #f8f9fa;

}
th {
  font-size: 0.75rem;
  font-weight: 600;
  color: #6c757d;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  padding: 1rem 2rem;
}
tbody tr:last-child td {
  border-bottom: none;
}
tbody tr:hover {
  background-color: #e6f0f7;
}
td {
  font-size: 0.9rem;
  color: #212529;
}
.actions-cell {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
  white-space: nowrap;
}
.text-center {
  text-align: center;
}
.loading-indicator, .no-results {
  text-align: center;
  padding: 2rem;
  color: #6c757d;
}
.form-container {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.form-input {
  width: 100%;
  padding: 0.75rem 1rem;
  font-size: 1rem;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  box-sizing: border-box;
  transition: border-color 0.2s, box-shadow 0.2s;
  /* ---> INICIO: Estilo para transformar visualmente a mayúsculas */
  text-transform: uppercase;
  /* ---> FIN: Estilo para transformar visualmente a mayúsculas */
}
.form-input:focus {
  outline: none;
  border-color: #005A9C;
  box-shadow: 0 0 0 3px rgba(0, 90, 156, 0.2);
}
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
}
.btn-pagination {
  background-color: #fff;
  border: 1px solid #dee2e6;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.2s;
}
.btn-pagination:hover:not(:disabled) {
  background-color: #f8f9fa;
}
.btn-pagination:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}
.pagination-info {
  font-size: 0.9rem;
  color: #6c757d;
}
</style>