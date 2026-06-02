<template>
  <div class="page-container">
    <header class="page-header">
      <h1>Gestión de Clientes</h1>
      <v-btn color="primary" prepend-icon="mdi-plus" @click="abrirModalCrear" class="responsive-header-btn">
        Registrar Cliente
      </v-btn>
    </header>

    <!-- Filtro por Letra -->
    <div class="d-flex flex-wrap gap-1 mb-4 justify-center">
      <v-chip v-for="letra in alfabeto" :key="letra" :color="filtroLetra === letra ? 'primary' : 'default'"
        :variant="filtroLetra === letra ? 'flat' : 'outlined'" class="ma-1 cursor-pointer" size="small"
        @click="seleccionarLetra(letra)">
        {{ letra }}
      </v-chip>
      <v-chip v-if="filtroLetra" color="error" variant="text" class="ma-1 cursor-pointer" size="small"
        prepend-icon="mdi-close" @click="seleccionarLetra(null)">
        Limpiar Filtro
      </v-chip>
      <v-chip :color="filtroSinReceta ? 'warning' : 'default'" :variant="filtroSinReceta ? 'flat' : 'outlined'"
        class="ma-1 cursor-pointer" size="small"
        :prepend-icon="filtroSinReceta ? 'mdi-filter-remove' : 'mdi-filter-outline'" @click="toggleFiltroSinReceta">
        {{ filtroSinReceta ? 'Sin Prescripción (Activo)' : 'Filtrar: Sin Prescripción' }}
      </v-chip>
    </div>

    <v-text-field ref="searchInputRef" v-model="busqueda"
      label="Buscar cliente..." placeholder="Por nombre, teléfono, receta, sobre o pedido" prepend-inner-icon="mdi-magnify"
      variant="outlined" density="compact" clearable class="mb-4" hide-details></v-text-field>

    <v-data-table-server v-model:items-per-page="itemsPerPage" :headers="headers" :items="clientes"
      :items-length="totalClientes" :loading="cargando" :search="busqueda" item-value="cod_cliente"
      class="elevation-1 mt-4 cursor-pointer" @update:options="fetchClientes" hover density="compact"
      @click:row="(event, { item }) => manejarClickIcono(item)">
      <template v-slot:item.nombreCompleto="{ item }">
        <div class="d-flex align-center">
          <v-tooltip location="top"
            :text="item.hasHistory ? 'Ver / Editar Última Receta' : 'Registrar Primera Receta (Pendiente)'">
            <template v-slot:activator="{ props }">
              <v-btn v-bind="props" icon size="x-small" variant="text" :color="item.hasHistory ? 'success' : 'warning'"
                @click.stop="manejarClickIcono(item)" class="mr-2">
                <v-icon size="medium">{{ item.hasHistory ? 'mdi-check-circle' : 'mdi-alert-circle-outline' }}</v-icon>
              </v-btn>
            </template>
          </v-tooltip>
          <span>{{ item.nombreCompleto }}</span>
        </div>
      </template>

      <template v-slot:item.actions="{ item }">
        <div class="d-flex align-center justify-center">
          <v-tooltip location="top" :text="tieneHistorial(item) ? 'Ver / Editar Receta' : 'Nueva Receta'">
            <template v-slot:activator="{ props }">
              <v-btn v-bind="props" icon size="small" variant="text" color="primary" @click.stop="abrirHistorial(item)">
                <v-badge v-if="tieneHistorial(item)" color="info" dot>
                  <v-icon>mdi-clipboard-text-clock</v-icon>
                </v-badge>
                <v-icon v-else>mdi-glasses</v-icon>
              </v-btn>
            </template>
          </v-tooltip>

          <v-tooltip location="top" text="Editar Cliente">
            <template v-slot:activator="{ props }">
              <v-btn v-bind="props" icon size="small" variant="text" color="grey-darken-2" @click.stop="editarCliente(item)">
                <v-icon>mdi-pencil</v-icon>
              </v-btn>
            </template>
          </v-tooltip>

          <v-tooltip location="top" text="Eliminar Cliente">
            <template v-slot:activator="{ props }">
              <v-btn v-bind="props" icon size="small" variant="text" color="error" @click.stop="eliminarCliente(item.cod_cliente)">
                <v-icon>mdi-delete</v-icon>
              </v-btn>
            </template>
          </v-tooltip>
        </div>
      </template>

      <template v-slot:no-data>
        No se encontraron clientes.
      </template>
    </v-data-table-server>

    <v-dialog v-model="dialog" persistent max-width="500px" transition="dialog-bottom-transition">
      <v-card class="rounded-lg elevation-4">
        <v-toolbar color="primary" density="compact">
          <v-toolbar-title class="text-h6 font-weight-bold">
            <v-icon :icon="editId ? 'mdi-account-edit' : 'mdi-account-plus'" class="mr-2"></v-icon>
            {{ editId ? 'Editar Cliente' : 'Registrar Cliente' }}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn icon="mdi-close" variant="text" @click="cerrarModal"></v-btn>
        </v-toolbar>

        <v-card-text class="pa-4">
          <v-row dense>
            <v-col cols="12">
              <v-text-field ref="nameClienteInputRef" v-model="formData.nombre_cliente" label="Nombre del cliente *"
                placeholder="Ej. JOHN WILLIAM" prepend-inner-icon="mdi-account" required variant="outlined"
                class="text-uppercase-input" color="primary" density="compact"></v-text-field>
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field v-model="formData.apellido_paterno_cliente" label="Apellido paterno *"
                placeholder="Ej. LOPEZ" required variant="outlined" class="text-uppercase-input" color="primary"
                density="compact"></v-text-field>
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field v-model="formData.apellido_materno_cliente" label="Apellido materno"
                placeholder="Ej. GARCIA" variant="outlined" class="text-uppercase-input" color="primary"
                density="compact"></v-text-field>
            </v-col>
            <v-col cols="12">
              <v-text-field v-model="formData.telefono_cliente" label="Teléfono" placeholder="Ej. 78912345"
                prepend-inner-icon="mdi-phone" variant="outlined" color="primary" density="compact"></v-text-field>
            </v-col>
          </v-row>
          <div class="text-caption text-grey-darken-1 mt-2">* Campos obligatorios</div>
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions class="pa-4 pt-2">
          <v-spacer></v-spacer>
          <v-btn color="grey-darken-1" variant="text" @click="cerrarModal" :disabled="guardando" class="px-4">
            Cancelar
          </v-btn>
          <v-btn color="primary" variant="elevated" @click="guardarCliente" :loading="guardando" class="px-6"
            prepend-icon="mdi-content-save">
            Guardar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-snackbar v-model="snackbar" :color="snackbarColor" :timeout="3000" location="top right">
      {{ snackbarText }}
      <template v-slot:actions>
        <v-btn variant="text" @click="snackbar = false" icon="mdi-close"></v-btn>
      </template>
    </v-snackbar>

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
              <v-btn color="secondary" prepend-icon="mdi-plus"
                @click="irANuevaPrescripcion(clienteSeleccionado.cod_cliente)">
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
                    <v-btn size="small" variant="text" color="primary" prepend-icon="mdi-pencil"
                      @click="editarPrescripcion(receta.cod_prescripcion)">
                      Editar / Ver
                    </v-btn>
                    <v-btn size="small" variant="text" color="error" icon="mdi-delete"
                      @click="eliminarPrescripcion(receta.cod_prescripcion)"></v-btn>
                  </v-card-actions>
                </v-card>
              </v-col>
            </v-row>
          </div>
        </v-card-text>
      </v-card>
    </v-dialog>

    <!-- Diálogo de Confirmación Genérico -->
    <v-dialog v-model="dialogConfirmacion" max-width="400px" persistent>
      <v-card class="rounded-lg text-center pa-4 elevation-10">
        <v-card-text>
          <v-icon :icon="confirmacionDatos.icono" :color="confirmacionDatos.color" size="64" class="mb-4"></v-icon>
          <h3 class="text-h6 font-weight-bold mb-2">{{ confirmacionDatos.titulo }}</h3>
          <p class="text-body-1 text-grey-darken-1">{{ confirmacionDatos.mensaje }}</p>
        </v-card-text>
        <v-card-actions class="justify-center pt-0 pb-4">
          <v-btn color="grey-darken-1" variant="text" class="px-4" @click="responderConfirmacion(false)">
            Cancelar
          </v-btn>
          <v-btn :color="confirmacionDatos.color" variant="elevated" class="px-6" @click="responderConfirmacion(true)">
            Sí, Eliminar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

  </div>
</template>

<script setup>
import { ref, reactive, nextTick, watch, onMounted, onUnmounted } from "vue";
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
const itemsPerPage = ref(20);
const busqueda = ref("");

// --- Filtro por Letra y Sin Receta ---
const filtroLetra = ref(null);
const filtroSinReceta = ref(false);
const alfabeto = ['A', 'B', 'C', 'CH', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'LL', 'M', 'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

const headers = [
  { title: 'Nombre Completo', align: 'start', sortable: true, key: 'nombreCompleto' },
  { title: 'Teléfono', key: 'telefono_cliente', sortable: true },
  { title: 'Código Receta', key: 'cod_receta', sortable: false },
  { title: 'Nro. Sobre', key: 'num_sobre', sortable: false },
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

// --- Estado del Snackbar ---
const snackbar = ref(false);
const snackbarText = ref("");
const snackbarColor = ref("success");

function mostrarMensaje(mensaje, color = "success") {
  snackbarText.value = mensaje;
  snackbarColor.value = color;
  snackbar.value = true;
}

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
  window.addEventListener('keydown', handleGlobalKeydown);
});

onUnmounted(() => {
  window.removeEventListener('keydown', handleGlobalKeydown);
});

function handleGlobalKeydown(e) {
  if (e.key === 'Enter') {
    if (!dialog.value && !dialogHistorial.value && !dialogConfirmacion.value) {
      if (document.activeElement && document.activeElement.tagName === 'BUTTON') {
        return;
      }
      e.preventDefault();
      abrirModalCrear();
    }
  }
}

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

function toggleFiltroSinReceta() {
  filtroSinReceta.value = !filtroSinReceta.value;
  if (filtroSinReceta.value) {
    busqueda.value = ""; // Limpiar búsqueda si se activa el filtro
  }
  fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
}

async function fetchClientes({ page, itemsPerPage, sortBy }) {
  cargando.value = true;
  try {
    const limite = itemsPerPage;
    const desplazamiento = (page - 1) * limite;

    let data = [];
    let count = 0;

    // CASO 1: Búsqueda por texto (Usamos RPC para búsqueda global)
    if (busqueda.value) {
      // Nota: El RPC 'buscar_clientes_con_prescripcion' actualmente hace su propio ordenamiento por relevancia/coincidencia.
      // Si se quisiera ordenar los resultados de la búsqueda, habría que filtrar en cliente o modificar el RPC.
      // Por ahora mantenemos el comportamiento de mostrar resultados por relevancia.
      const { data: rpcData, error: rpcError } = await supabase.rpc('buscar_clientes_con_prescripcion', {
        termino_busqueda: busqueda.value,
        limite: limite,
        desplazamiento: desplazamiento
      });
      if (rpcError) throw rpcError;
      data = rpcData || [];
      count = (data && data.length > 0) ? data[0].conteo_total : 0;
    }
    // CASO 2: Navegación Estándar (Filtros o Lista Completa)
    else {
      let query = supabase
        .from(filtroSinReceta.value ? 'clientes_sin_prescripcion' : 'clientes')
        .select('*', { count: 'exact' });

      // -- Filtros --
      if (filtroLetra.value) {
        if (filtroLetra.value === 'CH') {
          query = query.ilike('apellido_paterno_cliente', 'CH%');
        } else if (filtroLetra.value === 'LL') {
          query = query.ilike('apellido_paterno_cliente', 'LL%');
        } else {
          query = query.ilike('apellido_paterno_cliente', `${filtroLetra.value}%`);
        }
      }

      // -- Ordenamiento --
      if (sortBy && sortBy.length > 0) {
        const sort = sortBy[0];
        const order = sort.order === 'asc';

        if (sort.key === 'nombreCompleto') {
          // Ordenar por Apellidos y luego Nombre
          query = query.order('apellido_paterno_cliente', { ascending: order })
            .order('apellido_materno_cliente', { ascending: order })
            .order('nombre_cliente', { ascending: order });
        } else if (sort.key === 'telefono_cliente') {
          query = query.order('telefono_cliente', { ascending: order });
        } else {
          // Fallback para otras columnas si se mapearan directamente
          // Nota: cod_receta, num_sobre no existen en la tabla clientes, por lo que no ordenarán aquí.
          // Se debería deshabilitar sortable en esas columnas o usar una vista.
          query = query.order('apellido_paterno_cliente', { ascending: true });
        }
      } else {
        // Orden por defecto: Fecha de registro descendente (lo más nuevo primero)
        query = query.order('fecha_registro_cliente', { ascending: false });
      }

      // -- Paginación --
      query = query.range(desplazamiento, desplazamiento + limite - 1);

      const { data: clientesData, error: clientesError, count: total } = await query;
      if (clientesError) throw clientesError;

      count = total;

      // -- Enriquecer con Prescripciones (Join Manual) --
      if (clientesData && clientesData.length > 0) {
        // Optimización: Si filtramos "Sin Receta", no buscamos recetas
        if (filtroSinReceta.value) {
          data = clientesData.map(c => ({ ...c, cod_receta: '-', num_sobre: '-', conteo_total: count }));
        } else {
          const ids = clientesData.map(c => c.cod_cliente);
          const { data: prescripciones, error: prescError } = await supabase
            .from('prescripcion_clienten')
            .select('cod_cliente, cod_prescripcion, cod_receta, num_sobre, cod_pedido1, cod_pedido2')
            .in('cod_cliente', ids)
            .order('fecha_prescripcion', { ascending: false });

          if (!prescError && prescripciones) {
            data = clientesData.map(cliente => {
              // Encontrar la receta más reciente para este cliente
              const ultimaReceta = prescripciones.find(p => p.cod_cliente === cliente.cod_cliente);
              return {
                ...cliente,
                cod_prescripcion: ultimaReceta?.cod_prescripcion,
                cod_receta: ultimaReceta?.cod_receta || '-',
                num_sobre: ultimaReceta?.num_sobre || '-',
                cod_pedido1: ultimaReceta?.cod_pedido1,
                cod_pedido2: ultimaReceta?.cod_pedido2,
                conteo_total: count
              };
            });
          } else {
            data = clientesData.map(c => ({ ...c, cod_receta: '-', num_sobre: '-', conteo_total: count }));
          }
        }
      } else {
        data = [];
      }
    }

    clientes.value = (data || []).map(cliente => {
      const pedidosArr = [cliente.cod_pedido1, cliente.cod_pedido2]
        .filter(p => p && String(p).trim() !== '' && String(p).trim() !== '0' && String(p).trim() !== '-');

      return {
        ...cliente,
        nombreCompleto: `${cliente.apellido_paterno_cliente} ${cliente.apellido_materno_cliente || ''} ${cliente.nombre_cliente}`.trim(),
        pedidos: pedidosArr.length > 0 ? pedidosArr.join(', ') : '-',
        hasHistory: !!(cliente.cod_receta && cliente.cod_receta !== '-')
      };
    });

    totalClientes.value = count;

  } catch (error) {
    console.error("Error al obtener clientes:", error);
    mostrarMensaje("No se pudieron cargar los datos de los clientes.", "error");
  } finally {
    cargando.value = false;
  }
}


watch(busqueda, debounce(() => {
  if (busqueda.value) {
    filtroLetra.value = null; // Limpiar filtro de letra si se busca por texto
    filtroSinReceta.value = false; // Limpiar filtro sin receta
  }
  fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
}, 500));

// Helper visual para el icono del menú
function tieneHistorial(item) {
  return item.hasHistory;
}

function manejarClickIcono(item) {
  if (item.hasHistory) {
    if (item.cod_prescripcion) {
      clienteSeleccionado.value = item;
      editarPrescripcion(item.cod_prescripcion);
    } else {
      abrirHistorial(item);
    }
  } else {
    irANuevaPrescripcion(item.cod_cliente);
  }
}


// --- Funciones de Historial (Lo que hacía PanelCliente) ---

async function abrirHistorial(cliente) {

  clienteSeleccionado.value = cliente;

  // Si el cliente NO tiene historial, redirigir directamente a Nueva Receta
  if (!tieneHistorial(cliente)) {
    irANuevaPrescripcion(cliente.cod_cliente);
    return;
  }

  // Si tiene historial, abrir el diálogo para ver/editar/agregar
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
    mostrarMensaje("Error al cargar el historial del cliente.", "error");
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
  const confirmado = await confirmarAccion(
    "Eliminar Receta",
    "¿Estás seguro de que deseas eliminar esta receta? Esta acción no se puede deshacer."
  );
  if (!confirmado) return;

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
    mostrarMensaje('Error al eliminar: ' + error.message, "error");
  }
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-';
  return new Date(fecha + 'T00:00:00').toLocaleDateString('es-ES');
};

// --- Acciones CRUD Clientes (Sin cambios mayores) ---

async function guardarCliente() {
  if (!formData.nombre_cliente.trim() || !formData.apellido_paterno_cliente.trim()) {
    mostrarMensaje("El nombre y el apellido paterno son obligatorios.", "warning");
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

    mostrarMensaje(editId.value ? "Cliente actualizado correctamente" : "Cliente registrado correctamente", "success");
    cerrarModal();
    fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
  } catch (error) {
    console.error(error);
    mostrarMensaje("Error al guardar: " + error.message, "error");
  } finally {
    guardando.value = false;
  }
}

async function eliminarCliente(id) {
  const confirmado = await confirmarAccion(
    "Eliminar Cliente",
    "¿Estás seguro de que deseas eliminar este cliente y TODO su historial? Esta acción es irreversible."
  );
  if (!confirmado) return;
  try {
    const { error: errorPresc } = await supabase.from("prescripcion_clienten").delete().eq("cod_cliente", id);
    if (errorPresc) throw errorPresc;
    const { error: errorCliente } = await supabase.from("clientes").delete().eq("cod_cliente", id);
    if (errorCliente) throw errorCliente;
    mostrarMensaje("Cliente eliminado.", "success");
    fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
  } catch (error) {
    mostrarMensaje("Error al eliminar: " + error.message, "error");
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

// --- Funciones del Diálogo de Confirmación ---
const dialogConfirmacion = ref(false);
const confirmacionDatos = reactive({
  titulo: '',
  mensaje: '',
  color: 'error',
  icono: 'mdi-alert-circle-outline'
});
let resolveConfirmacion = null;

function confirmarAccion(titulo, mensaje, color = 'error', icono = 'mdi-alert-circle-outline') {
  confirmacionDatos.titulo = titulo;
  confirmacionDatos.mensaje = mensaje;
  confirmacionDatos.color = color;
  confirmacionDatos.icono = icono;
  dialogConfirmacion.value = true;
  return new Promise((resolve) => {
    resolveConfirmacion = resolve;
  });
}

function responderConfirmacion(respuesta) {
  dialogConfirmacion.value = false;
  if (resolveConfirmacion) {
    resolveConfirmacion(respuesta);
    resolveConfirmacion = null;
  }
}
</script>

<style scoped>
.page-container {
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  padding: 1rem 0.75rem;
  background-color: #f8f9fa;
  color: #212529;
}

@media (min-width: 600px) {
  .page-container {
    padding: 1rem 2rem;
  }
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

@media (max-width: 600px) {
  .page-header {
    flex-direction: column;
    align-items: stretch;
    gap: 0.75rem;
    text-align: center;
  }

  .responsive-header-btn {
    width: 100% !important;
  }
}

.text-uppercase-input :deep(input) {
  text-transform: uppercase;
}

/* Estilos para el modal de historial */
.historial-card {
  display: flex;
  flex-direction: column;
}

/* Control de altura de filas */
:deep(.v-data-table tbody tr) {
  cursor: pointer;
}

:deep(.v-data-table__td) {
  height: 30px !important;
  /* Puedes cambiar este valor (ej. 30px, 50px) */
  padding-top: 0 !important;
  padding-bottom: 0 !important;
  font-size: 0.85rem;
}

/* Estilos para el encabezado de la tabla */
:deep(.v-data-table__th) {
  background-color: #2c3e50 !important;
  color: #ffffff !important;
  font-weight: 600 !important;
  text-transform: uppercase;
  font-size: 0.85rem;
}

:deep(.v-data-table__th:hover) {
  background-color: #34495e !important;
}

:deep(.v-data-table-header__sort-icon) {
  color: rgba(255, 255, 255, 0.7) !important;
}
</style>