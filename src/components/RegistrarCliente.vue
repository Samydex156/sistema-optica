<template>
  <div class="page-container">
    <header class="page-header">
      <h1>Gestión de Clientes</h1>
      <v-btn color="primary" prepend-icon="mdi-plus" @click="abrirModalCrear">
        Registrar Cliente
      </v-btn>
    </header>

    <!-- Filtro por Letra -->
    <div class="d-flex flex-wrap gap-1 mb-4 justify-center">
      <v-chip
        v-for="letra in alfabeto"
        :key="letra"
        :color="filtroLetra === letra ? 'primary' : 'default'"
        :variant="filtroLetra === letra ? 'flat' : 'outlined'"
        class="ma-1 cursor-pointer"
        size="small"
        @click="seleccionarLetra(letra)"
      >
        {{ letra }}
      </v-chip>
      <v-chip
        v-if="filtroLetra"
        color="error"
        variant="text"
        class="ma-1 cursor-pointer"
        size="small"
        prepend-icon="mdi-close"
        @click="seleccionarLetra(null)"
      >
        Limpiar Filtro
      </v-chip>
    </div>

    <v-text-field
      ref="searchInputRef"
      v-model="busqueda"
      label="Buscar cliente por nombre, teléfono, cód. receta, nro. sobre o pedido."
      prepend-inner-icon="mdi-magnify"
      variant="outlined"
      density="compact"
      clearable
      class="mb-4"
      hide-details
    ></v-text-field>

    <v-data-table-server
      v-model:items-per-page="itemsPerPage"
      :headers="headers"
      :items="clientes"
      :items-length="totalClientes"
      :loading="cargando"
      :search="busqueda"
      item-value="cod_cliente"
      class="elevation-1 mt-4"
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

// --- Filtro por Letra ---
const filtroLetra = ref(null);
const alfabeto = ['A', 'B', 'C', 'CH', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'LL', 'M', 'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

const headers = [
  { title: 'Nombre Completo', align: 'start', sortable: true, key: 'nombreCompleto' },
  { title: 'Teléfono', key: 'telefono_cliente', sortable: true },
  { title: 'Código Receta', key: 'cod_receta', sortable: true },
  { title: 'Nro. Sobre', key: 'num_sobre', sortable: true },
  { title: 'Número de Pedido', key: 'pedidos', sortable: false },
  { title: 'Acciones', key: 'actions', sortable: true, align: 'center' },
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

function seleccionarLetra(letra) {
  if (filtroLetra.value === letra) {
    filtroLetra.value = null; // Deseleccionar si ya estaba seleccionada
  } else {
    filtroLetra.value = letra;
    busqueda.value = ""; // Limpiar búsqueda textual al seleccionar letra
  }
  fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
}

async function fetchClientes({ page, itemsPerPage }) {
  cargando.value = true;
  try {
    const limite = itemsPerPage;
    const desplazamiento = (page - 1) * limite;

    let data = [];
    let count = 0;

    // CASO 1: Búsqueda por texto (Prioridad)
    if (busqueda.value) {
      const { data: rpcData, error: rpcError } = await supabase.rpc('buscar_clientes_con_prescripcion', {
        termino_busqueda: busqueda.value,
        limite: limite,
        desplazamiento: desplazamiento
      });
      if (rpcError) throw rpcError;
      data = rpcData || [];
      count = (data && data.length > 0) ? data[0].conteo_total : 0;
    } 
    // CASO 2: Filtro por Letra
    else if (filtroLetra.value) {
      let query = supabase
        .from('clientes')
        .select('*', { count: 'exact' });

      // Lógica específica para CH y LL
      if (filtroLetra.value === 'CH') {
        query = query.ilike('apellido_paterno_cliente', 'CH%');
      }else if (filtroLetra.value === 'LL') {
        query = query.ilike('apellido_paterno_cliente', 'LL%');
      }else {
        // Caso normal
        query = query.ilike('apellido_paterno_cliente', `${filtroLetra.value}%`);
      }

      query = query
        .order('apellido_paterno_cliente', { ascending: true })
        .order('apellido_materno_cliente', { ascending: true })
        .order('nombre_cliente', { ascending: true })
        .range(desplazamiento, desplazamiento + limite - 1);

      const { data: clientesData, error: clientesError, count: total } = await query;
      if (clientesError) throw clientesError;

      count = total;
      
      // Para mantener consistencia con la vista de búsqueda, necesitamos enriquecer con la última receta
      // Hacemos una consulta adicional para estos clientes específicos
      if (clientesData && clientesData.length > 0) {
        const ids = clientesData.map(c => c.cod_cliente);
        
        // Traemos la última prescripción para cada cliente de la página actual
        // Nota: Esto es una aproximación. Lo ideal sería una View o RPC, pero para mantenerlo simple en frontend:
        const { data: prescripciones, error: prescError } = await supabase
          .from('prescripcion_clienten')
          .select('cod_cliente, cod_receta, num_sobre, cod_pedido1, cod_pedido2')
          .in('cod_cliente', ids)
          .order('fecha_prescripcion', { ascending: false }); // Ordenar por fecha para que al buscar encontremos la reciente

        if (!prescError && prescripciones) {
          // Mapeamos para unir datos
          data = clientesData.map(cliente => {
            // Encontrar la primera coincidencia (la más reciente por el order)
            const ultimaReceta = prescripciones.find(p => p.cod_cliente === cliente.cod_cliente);
            return {
              ...cliente,
              cod_receta: ultimaReceta?.cod_receta || '-',
              num_sobre: ultimaReceta?.num_sobre || '-',
              cod_pedido1: ultimaReceta?.cod_pedido1,
              cod_pedido2: ultimaReceta?.cod_pedido2,
              conteo_total: count // Para mantener estructura
            };
          });
        } else {
          data = clientesData.map(c => ({ ...c, cod_receta: '-', num_sobre: '-', conteo_total: count }));
        }
      } else {
        data = [];
      }
    } 
    // CASO 3: Sin filtros (Carga inicial o limpia)
    else {
       const { data: rpcData, error: rpcError } = await supabase.rpc('buscar_clientes_con_prescripcion', {
        termino_busqueda: "",
        limite: limite,
        desplazamiento: desplazamiento
      });
      if (rpcError) throw rpcError;
      data = rpcData || [];
      count = (data && data.length > 0) ? data[0].conteo_total : 0;
    }

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
    
    totalClientes.value = count;

  } catch (error) {
    console.error("Error al obtener clientes:", error);
    alert("No se pudieron cargar los datos de los clientes.");
  } finally {
    cargando.value = false;
  }
}

watch(busqueda, debounce(() => {
    if (busqueda.value) {
        filtroLetra.value = null; // Limpiar filtro de letra si se busca por texto
    }
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