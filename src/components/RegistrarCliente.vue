<template>
  <div class="page-container">
    <header class="page-header">
      <h1>Gestión de Clientes</h1>
      <v-btn color="primary" prepend-icon="mdi-plus" @click="abrirModalCrear">
        Registrar Cliente
      </v-btn>
    </header>

    <v-text-field
      ref="searchInputRef"
      v-model="busqueda"
      label="Buscar cliente por nombre, teléfono, cód. receta, nro. sobre o pedido."
      prepend-inner-icon="mdi-magnify"
      variant="outlined"
      density="compact"
      clearable
      class="my-4"
    ></v-text-field>

    <v-data-table-server
      v-model:items-per-page="itemsPerPage"
      :headers="headers"
      :items="clientes"
      :items-length="totalClientes"
      :loading="cargando"
      :search="busqueda"
      item-value="cod_cliente"
      class="elevation-1"
      @update:options="fetchClientes"
      hover
    >
      <template v-slot:item.actions="{ item }">
        <v-menu location="bottom end">
          <template v-slot:activator="{ props }">
            <v-btn
              icon="mdi-dots-vertical"
              variant="text"
              density="comfortable"
              v-bind="props"
            ></v-btn>
          </template>

          <v-list density="compact" elevation="2">
            <v-list-item @click="abrirHistorial(item)" base-color="primary">
              <template v-slot:prepend>
                <v-icon :icon="tieneHistorial(item) ? 'mdi-clipboard-text-clock' : 'mdi-glasses'"></v-icon>
              </template>
              <v-list-item-title>
                {{ tieneHistorial(item) ? 'Ver Historial / Recetas' : 'Nueva Prescripción' }}
              </v-list-item-title>
              <template v-slot:append v-if="tieneHistorial(item)">
                 <v-badge color="info" dot inline></v-badge>
              </template>
            </v-list-item>

            <v-list-item @click="editarCliente(item)">
              <template v-slot:prepend>
                <v-icon icon="mdi-pencil"></v-icon>
              </template>
              <v-list-item-title>Editar Cliente</v-list-item-title>
            </v-list-item>

            <v-divider class="my-1"></v-divider>

            <v-list-item @click="eliminarCliente(item.cod_cliente)" base-color="error">
              <template v-slot:prepend>
                <v-icon icon="mdi-delete"></v-icon>
              </template>
              <v-list-item-title class="text-error">Eliminar</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </template>

      <template v-slot:no-data>
        No se encontraron clientes.
      </template>
    </v-data-table-server>

    <v-dialog v-model="dialog" persistent max-width="600px">
      <v-card>
        <v-card-title>
          <span class="text-h5">{{ editId ? 'Editar Cliente' : 'Registrar Cliente' }}</span>
        </v-card-title>
        <v-card-text>
          <v-container>
            <v-row>
              <v-col cols="12">
                <v-text-field
                  ref="nameClienteInputRef"
                  v-model="formData.nombre_cliente"
                  label="Nombre del cliente *"
                  required
                  variant="outlined"
                  class="text-uppercase-input"
                ></v-text-field>
              </v-col>
              <v-col cols="12" sm="6">
                <v-text-field
                  v-model="formData.apellido_paterno_cliente"
                  label="Apellido paterno *"
                  required
                  variant="outlined"
                  class="text-uppercase-input"
                ></v-text-field>
              </v-col>
              <v-col cols="12" sm="6">
                <v-text-field
                  v-model="formData.apellido_materno_cliente"
                  label="Apellido materno"
                  variant="outlined"
                  class="text-uppercase-input"
                ></v-text-field>
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="formData.telefono_cliente"
                  label="Teléfono"
                  variant="outlined"
                ></v-text-field>
              </v-col>
            </v-row>
          </v-container>
          <small>* indica campo requerido</small>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="blue-darken-1" variant="text" @click="cerrarModal" :disabled="guardando">
            Cancelar
          </v-btn>
          <v-btn color="blue-darken-1" variant="text" @click="guardarCliente" :loading="guardando">
            Guardar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="dialogHistorial" max-width="900px" scrollable>
      <v-card class="historial-card">
        <v-toolbar color="primary" density="compact">
            <v-toolbar-title>Historial de Recetas: {{ clienteSeleccionado?.nombreCompleto }}</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn icon="mdi-close" @click="dialogHistorial = false"></v-btn>
        </v-toolbar>

        <v-card-text style="max-height: 600px;">
          <div v-if="cargandoHistorial" class="d-flex justify-center py-5">
            <v-progress-circular indeterminate color="primary"></v-progress-circular>
          </div>

          <div v-else>
            <div class="d-flex justify-end mb-4 pt-2">
                <v-btn color="secondary" prepend-icon="mdi-plus" @click="irANuevaPrescripcion(clienteSeleccionado.cod_cliente)">
                    Nueva Receta
                </v-btn>
            </div>

            <v-alert v-if="historial.length === 0" type="info" variant="tonal" class="mb-4">
                Este cliente no tiene prescripciones registradas.
            </v-alert>

            <v-row v-else>
                <v-col v-for="receta in historial" :key="receta.cod_prescripcion" cols="12" md="6">
                    <v-card variant="outlined" class="mb-2">
                        <v-card-item>
                            <template v-slot:prepend>
                                <v-avatar color="blue-lighten-4" icon="mdi-glasses"></v-avatar>
                            </template>
                            <v-card-title>Receta: {{ receta.cod_receta }}</v-card-title>
                            <v-card-subtitle>{{ formatearFecha(receta.fecha_prescripcion) }}</v-card-subtitle>
                        </v-card-item>
                        <v-divider></v-divider>
                        <v-card-text class="py-2">
                            <div class="d-flex justify-space-between text-caption">
                                <span><strong>Entrega:</strong> {{ formatearFecha(receta.fecha_entrega) }}</span>
                                <span><strong>Sobre:</strong> {{ receta.num_sobre || '-' }}</span>
                            </div>
                            <div class="text-caption mt-1 text-truncate">
                                <strong>Notas:</strong> {{ receta.notas_adicionales || 'Ninguna' }}
                            </div>
                        </v-card-text>
                        <v-divider></v-divider>
                        <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn 
                                size="small" 
                                variant="text" 
                                color="primary" 
                                prepend-icon="mdi-pencil"
                                @click="editarPrescripcion(receta.cod_prescripcion)"
                            >
                                Editar / Ver
                            </v-btn>
                            <v-btn 
                                size="small" 
                                variant="text" 
                                color="error" 
                                icon="mdi-delete"
                                @click="eliminarPrescripcion(receta.cod_prescripcion)"
                            ></v-btn>
                        </v-card-actions>
                    </v-card>
                </v-col>
            </v-row>
          </div>
        </v-card-text>
      </v-card>
    </v-dialog>

  </div>
</template>

<script setup>
import { ref, reactive, nextTick, watch, onMounted } from "vue";
import { useRouter } from 'vue-router';
import { supabase } from "../lib/supabaseClient.js";
import { debounce } from 'lodash-es';

const router = useRouter();

// --- Referencias DOM ---
const searchInputRef = ref(null); 
const nameClienteInputRef = ref(null); 

// --- Estado de la Tabla Principal ---
const cargando = ref(true);
const clientes = ref([]);
const totalClientes = ref(0);
const itemsPerPage = ref(10);
const busqueda = ref("");

const headers = [
  { title: 'Nombre Completo', align: 'start', sortable: false, key: 'nombreCompleto' },
  { title: 'Teléfono', key: 'telefono_cliente', sortable: false },
  { title: 'Última Receta', key: 'cod_receta', sortable: false }, // Cambié el título para ser más claro
  { title: 'Nro. Sobre', key: 'num_sobre', sortable: false },
  { title: 'Acciones', key: 'actions', sortable: false, align: 'center' },
];

// --- Estado del Modal Cliente (Crear/Editar) ---
const dialog = ref(false);
const guardando = ref(false);
const editId = ref(null);
const formDefault = {
  nombre_cliente: "",
  apellido_paterno_cliente: "",
  apellido_materno_cliente: "",
  telefono_cliente: ""
};
const formData = reactive({ ...formDefault });

// --- Estado del Modal Historial ---
const dialogHistorial = ref(false);
const cargandoHistorial = ref(false);
const historial = ref([]);
const clienteSeleccionado = ref(null);

// --- Lifecycle Hooks ---
onMounted(() => {
  nextTick(() => {
    searchInputRef.value?.focus();
  });
});

// --- Funciones de Datos (Clientes) ---

async function fetchClientes({ page, itemsPerPage }) {
  cargando.value = true;
  try {
    const limite = itemsPerPage;
    const desplazamiento = (page - 1) * limite;

    const { data, error } = await supabase.rpc('buscar_clientes_con_prescripcion', {
      termino_busqueda: busqueda.value,
      limite: limite,
      desplazamiento: desplazamiento
    });
    
    if (error) throw error;

    clientes.value = (data || []).map(cliente => {
      const pedidosArr = [cliente.cod_pedido1, cliente.cod_pedido2]
        .filter(p => p && String(p).trim() !== '' && String(p).trim() !== '0' && String(p).trim() !== '-');
      
      return {
        ...cliente,
        nombreCompleto: `${cliente.nombre_cliente} ${cliente.apellido_paterno_cliente} ${cliente.apellido_materno_cliente || ''}`.trim(),
        pedidos: pedidosArr.length > 0 ? pedidosArr.join(', ') : '-',
        // Flag auxiliar para saber si tiene historial en la vista de tabla
        hasHistory: !!(cliente.cod_receta && cliente.cod_receta !== '-')
      };
    });
    
    totalClientes.value = (data && data.length > 0) ? data[0].conteo_total : 0;

  } catch (error) {
    console.error("Error al obtener clientes:", error);
    alert("No se pudieron cargar los datos de los clientes.");
  } finally {
    cargando.value = false;
  }
}

watch(busqueda, debounce(() => {
    fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
}, 500));

// Helper visual para el icono del menú
function tieneHistorial(item) {
    return item.hasHistory; 
}

// --- Funciones de Historial (Lo que hacía PanelCliente) ---

async function abrirHistorial(cliente) {
    clienteSeleccionado.value = cliente;
    // Si NO tiene historial según la tabla, podemos ir directo a crear si prefieres,
    // pero mejor abrimos el modal para que vea que está vacío y decida crear.
    dialogHistorial.value = true;
    await cargarPrescripciones(cliente.cod_cliente);
}

async function cargarPrescripciones(clienteId) {
    cargandoHistorial.value = true;
    historial.value = [];
    try {
        const { data, error } = await supabase
            .from('prescripcion_clienten')
            .select('*')
            .eq('cod_cliente', clienteId)
            .order('fecha_prescripcion', { ascending: false }); // Las más nuevas primero
        
        if (error) throw error;
        historial.value = data;
    } catch (error) {
        console.error("Error cargando historial:", error);
        alert("Error al cargar el historial del cliente.");
    } finally {
        cargandoHistorial.value = false;
    }
}

function irANuevaPrescripcion(clienteId) {
  router.push({ 
    name: 'CrearPrescripcion', 
    params: { clienteId: clienteId } 
  });
}

function editarPrescripcion(prescripcionId) {
    // Redirige al componente RegistrarPrescripcion en modo edición
    router.push({
        name: 'EditarPrescripcion',
        params: {
            clienteId: clienteSeleccionado.value.cod_cliente,
            prescripcionId: prescripcionId
        }
    });
}

async function eliminarPrescripcion(prescripcionId) {
    if (!confirm('¿Seguro que desea eliminar esta receta?')) return;
    
    try {
        // Primero borramos los tratamientos asociados (si no hay Cascade delete)
        await supabase.from('prescripcion_tratamiento').delete().eq('cod_prescripcion', prescripcionId);
        
        const { error } = await supabase
            .from('prescripcion_clienten')
            .delete()
            .eq('cod_prescripcion', prescripcionId);

        if (error) throw error;

        // Recargar la lista del modal
        await cargarPrescripciones(clienteSeleccionado.value.cod_cliente);
        // Recargar la tabla principal para actualizar la columna de "Última receta"
        fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });

    } catch (error) {
        alert('Error al eliminar: ' + error.message);
    }
}

const formatearFecha = (fecha) => {
    if (!fecha) return '-';
    return new Date(fecha + 'T00:00:00').toLocaleDateString('es-ES');
};

// --- Acciones CRUD Clientes (Sin cambios mayores) ---

async function guardarCliente() {
  if (!formData.nombre_cliente.trim() || !formData.apellido_paterno_cliente.trim()) {
      alert("El nombre y el apellido paterno son obligatorios.");
      return;
  }
  guardando.value = true;
  try {
    const clienteData = {
      nombre_cliente: formData.nombre_cliente.trim().toUpperCase(),
      apellido_paterno_cliente: formData.apellido_paterno_cliente.trim().toUpperCase(),
      apellido_materno_cliente: formData.apellido_materno_cliente?.trim()?.toUpperCase() || null,
      telefono_cliente: formData.telefono_cliente?.trim() || null
    };
      
    if (editId.value) clienteData.cod_cliente = editId.value;
    
    const { error } = await supabase.from("clientes").upsert(clienteData);
    if (error) throw error;
    
    alert(editId.value ? "Actualizado correctamente" : "Registrado correctamente");
    cerrarModal();
    fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
  } catch (error) {
    console.error(error);
    alert("Error al guardar: " + error.message);
  } finally {
    guardando.value = false;
  }
}

async function eliminarCliente(id) {
  if (!confirm("¿Eliminar cliente y TODO su historial?")) return;
  try {
    const { error: errorPresc } = await supabase.from("prescripcion_clienten").delete().eq("cod_cliente", id);
    if (errorPresc) throw errorPresc;
    const { error: errorCliente } = await supabase.from("clientes").delete().eq("cod_cliente", id);
    if (errorCliente) throw errorCliente;
    alert("Cliente eliminado.");
    fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
  } catch (error) {
    alert("Error al eliminar: " + error.message);
  }
}

// --- Gestión del Modal Cliente ---
function editarCliente(cliente) {
  editId.value = cliente.cod_cliente;
  formData.nombre_cliente = cliente.nombre_cliente;
  formData.apellido_paterno_cliente = cliente.apellido_paterno_cliente;
  formData.apellido_materno_cliente = cliente.apellido_materno_cliente || "";
  formData.telefono_cliente = cliente.telefono_cliente || "";
  dialog.value = true;
  nextTick(() => nameClienteInputRef.value?.focus());
}
function abrirModalCrear() {
  limpiarFormulario();
  dialog.value = true;
  nextTick(() => nameClienteInputRef.value?.focus());
}
function cerrarModal() {
  dialog.value = false;
  limpiarFormulario();
}
function limpiarFormulario() {
  editId.value = null;
  Object.assign(formData, formDefault);
}
</script>

<style scoped>
.page-container {
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  padding: 1rem 2rem;
  background-color: #f8f9fa;
  color: #212529;
}
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding-bottom: .5rem;
  border-bottom: 1px solid #dee2e6;
}
.page-header h1 {
  margin: 0;
  font-size: 1.75rem;
  font-weight: 600;
}
.text-uppercase-input :deep(input) {
  text-transform: uppercase;
}
/* Estilos para el modal de historial */
.historial-card {
    display: flex;
    flex-direction: column;
}
</style>