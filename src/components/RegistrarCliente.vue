<template>
  <div class="page-container">
    <header class="page-header">
      <h2>Registro de Clientes</h2>
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
            <th>Pedidos</th>
            <th class="text-center">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="clientesFiltrados.length === 0">
            <td colspan="6" class="no-results">No se encontraron clientes que coincidan con la búsqueda.</td>
          </tr>
          <tr v-for="cliente in clientesFiltrados" :key="cliente.cod_cliente">
            <td data-label="Nombre">{{ cliente.nombreCompleto }}</td>
            <td data-label="Teléfono">{{ cliente.telefono_cliente || '-' }}</td>
            <td data-label="Cód. Receta">{{ cliente.cod_receta || '-' }}</td>
            <td data-label="Nro. Sobre">{{ cliente.nro_sobre || '-' }}</td>
            <td data-label="Pedidos">{{ cliente.pedidos || '-' }}</td>
            <td data-label="Acciones" class="actions-cell">
              <button @click="irAPanelCliente(cliente.cod_cliente)" class="btn-icon btn-panel" title="Ver Panel del Cliente">&#128221;</button>
              <button @click="editarCliente(cliente)" class="btn-icon btn-edit" title="Editar Cliente">&#9998;</button>
              <button @click="eliminarCliente(cliente.cod_cliente)" class="btn-icon btn-delete" title="Eliminar Cliente">&#128465;</button>
            </td>
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
        <button @click="cerrarModal" class="btn btn-secondary">Cancelar</button>
        <button @click="guardarCliente" class="btn btn-primary">Guardar</button>
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
const cargando = ref(true);
const showModal = ref(false);
const editId = ref(null);
const busqueda = ref("");

const nombreCliente = ref("");
const apellidoPaterno = ref("");
const apellidoMaterno = ref("");
const telefonoCliente = ref("");
const nameCliente = ref(null);

// PROPIEDAD COMPUTADA PARA PROCESAR Y APLANAR LOS DATOS
const clientesConDatos = computed(() => {
  return clientes.value.map(cliente => {
    // Ordenar prescripciones para obtener la más reciente primero
    const prescripcionesOrdenadas = [...(cliente.prescripcion_cliente || [])]
      .sort((a, b) => new Date(b.fecha_prescripcion) - new Date(a.fecha_prescripcion));
    
    const ultimaPrescripcion = prescripcionesOrdenadas[0];

    // Extraer los números de pedido de los cristales asociados a la última prescripción
    let pedidos = [];
    if (ultimaPrescripcion?.medida_lente) {
        pedidos = ultimaPrescripcion.medida_lente
            .flatMap(medida => medida.cristal_medida || [])
            .map(cristal => cristal.nro_sobre)
            .filter(Boolean); // Filtrar valores nulos o vacíos
    }

    return {
      ...cliente,
      nombreCompleto: `${cliente.nombre_cliente} ${cliente.apellido_paterno_cliente} ${cliente.apellido_materno_cliente || ''}`.trim(),
      cod_receta: ultimaPrescripcion?.cod_receta,
      nro_sobre: ultimaPrescripcion?.codigo_pedido,
      pedidos: pedidos.join(', ')
    };
  });
});

// PROPIEDAD COMPUTADA PARA FILTRAR SOBRE LOS DATOS YA PROCESADOS
const clientesFiltrados = computed(() => {
  if (!busqueda.value) {
    return clientesConDatos.value;
  }
  const termino = busqueda.value.toLowerCase();
  return clientesConDatos.value.filter(cliente => {
    return (
      cliente.nombreCompleto.toLowerCase().includes(termino) ||
      (cliente.telefono_cliente || '').toLowerCase().includes(termino) ||
      (cliente.cod_receta || '').toLowerCase().includes(termino) ||
      (cliente.nro_sobre || '').toLowerCase().includes(termino) ||
      (cliente.pedidos || '').toLowerCase().includes(termino)
    );
  });
});

async function getClientes() {
  cargando.value = true;
  try {
    const { data, error } = await supabase
      .from("clientes")
      .select(`
        *,
        prescripcion_cliente (
          cod_receta,
          codigo_pedido,
          fecha_prescripcion,
          medida_lente (
            cristal_medida (
              nro_sobre
            )
          )
        )
      `)
      .order("fecha_registro_cliente", { ascending: false });
    
    if (error) throw error;
    clientes.value = data || [];
  } catch (error) {
    console.error("Error al obtener clientes:", error);
    alert("No se pudieron cargar los datos de los clientes.");
  } finally {
    cargando.value = false;
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

  const clienteData = {
    nombre_cliente: nombreCliente.value.trim(),
    apellido_paterno_cliente: apellidoPaterno.value.trim(),
    apellido_materno_cliente: apellidoMaterno.value.trim() || null,
    telefono_cliente: telefonoCliente.value.trim() || null
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
    alert("Error al guardar el cliente: " + error.message);
  }
}

async function eliminarCliente(id) {
  if (confirm("¿Está seguro de que desea eliminar este cliente? Esta acción no se puede deshacer.")) {
    try {
      const { error } = await supabase.from("clientes").delete().eq("cod_cliente", id);
      if (error) {
          if (error.code === '23503') { // Foreign key violation
               alert("Error: No se puede eliminar el cliente porque tiene prescripciones u órdenes asociadas.");
          } else {
              throw error;
          }
      } else {
        alert("Cliente eliminado exitosamente");
      }
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
        // Para asegurar que los datos anidados se recarguen, es mejor re-llamar a getClientes.
        getClientes();
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
/* ESTILOS GENERALES Y VARIABLES */

.page-container {
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  padding: 2rem;
  background-color: #f8f9fa;
  color: #212529;
}

/* CABECERA */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #dee2e6;
}

.page-header h1 {
  margin: 0;
  font-size: 1.75rem;
  font-weight: 600;
}

/* BOTONES */
.btn {
  padding: 0.6rem 1rem;
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

/* BÚSQUEDA */
.search-container {
  position: relative;
  margin-bottom: 2rem;
}

.search-input {
  width: 100%;
  padding: 0.75rem 1rem 0.75rem 2.5rem;
  font-size: 1rem;
  border: 1px solid #dee2e6;
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

/* TABLA */
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
  padding: 1rem;
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

/* FORMULARIO EN MODAL */
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
}

.form-input:focus {
  outline: none;
  border-color: #005A9C;
  box-shadow: 0 0 0 3px rgba(0, 90, 156, 0.2);
}
</style>