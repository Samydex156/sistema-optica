<template>
  <div class="page-container">
    <header class="page-header">
      <h1>Gestión de Clientes</h1>
      <v-btn color="primary" prepend-icon="mdi-plus" @click="abrirModalCrear">
        Registrar Cliente
      </v-btn>
    </header>

    <v-text-field
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
        <v-icon size="small" class="me-2" @click="irAPanelCliente(item.cod_cliente)" title="Ver Panel del Cliente">
          mdi-text-box-search-outline
        </v-icon>
        <v-icon size="small" class="me-2" @click="editarCliente(item)" title="Editar Cliente">
          mdi-pencil
        </v-icon>
        <v-icon size="small" @click="eliminarCliente(item.cod_cliente)" title="Eliminar Cliente">
          mdi-delete
        </v-icon>
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
                  ref="nameCliente"
                  v-model="nombreCliente"
                  label="Nombre del cliente *"
                  required
                  variant="outlined"
                  class="text-uppercase-input"
                ></v-text-field>
              </v-col>
              <v-col cols="12" sm="6">
                <v-text-field
                  v-model="apellidoPaterno"
                  label="Apellido paterno *"
                  required
                  variant="outlined"
                  class="text-uppercase-input"
                ></v-text-field>
              </v-col>
              <v-col cols="12" sm="6">
                <v-text-field
                  v-model="apellidoMaterno"
                  label="Apellido materno"
                  variant="outlined"
                  class="text-uppercase-input"
                ></v-text-field>
              </v-col>
              <v-col cols="12">
                <v-text-field
                  v-model="telefonoCliente"
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
          <v-btn color="blue-darken-1" variant="text" @click="cerrarModal">
            Cancelar
          </v-btn>
          <v-btn color="blue-darken-1" variant="text" @click="guardarCliente">
            Guardar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup>
import { ref, nextTick, watch } from "vue";
import { useRouter } from 'vue-router';
import { supabase } from "../lib/supabaseClient.js";
import { debounce } from 'lodash-es';

const router = useRouter();

// Estados para la tabla 
const cargando = ref(true);
const clientes = ref([]);
const totalClientes = ref(0);
const itemsPerPage = ref(10);
const busqueda = ref("");
const headers = [
  { title: 'Nombre Completo', align: 'start', sortable: false, key: 'nombreCompleto' },
  { title: 'Teléfono', key: 'telefono_cliente', sortable: false },
  { title: 'Cód. Receta', key: 'cod_receta', sortable: false },
  { title: 'Nro. Sobre', key: 'num_sobre', sortable: false },
  { title: 'Nro. Pedido', key: 'pedidos', sortable: false },
  { title: 'Acciones', key: 'actions', sortable: false, align: 'center' },
];

// Estados para el cuadro de dialogo
const dialog = ref(false);
const editId = ref(null);
const nombreCliente = ref("");
const apellidoPaterno = ref("");
const apellidoMaterno = ref("");
const telefonoCliente = ref("");
const nameCliente = ref(null); // Para hacer focus al nombre cliente

// Esta función es llamada por el v-data-table-server al cargar la pagina y cuando la pagina o el item cambia.
async function fetchClientes({ page, itemsPerPage }) {
  cargando.value = true;
  try {
    const limite = itemsPerPage;
    const desplazamiento = (page - 1) * limite;

    // Esto asegura que la busqueda se realice directamente en el servidor de Supabase
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

// Debounce para el campo de búsqueda
// Este watcher asegura que llamamos a Supabase para la busqueda cuando el usaurio escribe.
watch(busqueda, debounce(() => {
    fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
}, 500));


function irAPanelCliente(clienteId) {
  router.push({ name: 'PanelCliente', params: { id: clienteId } });
}

async function guardarCliente() {
  if (!nombreCliente.value.trim() || !apellidoPaterno.value.trim()) {
      alert("El nombre y el apellido paterno son obligatorios.");
      return;
  }
  
  // Lógica para convertir a mayúsculas los campos del cliente.
  const clienteData = {
    nombre_cliente: nombreCliente.value.trim().toUpperCase(),
    apellido_paterno_cliente: apellidoPaterno.value.trim().toUpperCase(),
    apellido_materno_cliente: apellidoMaterno.value.trim() ? apellidoMaterno.value.trim().toUpperCase() : null,
    telefono_cliente: telefonoCliente.value.trim() || null
  };
    
  if (editId.value) {
    clienteData.cod_cliente = editId.value;
  }
  
  try {
    const { error } = await supabase.from("clientes").upsert(clienteData);
    if (error) throw error;
    alert(editId.value ? "Cliente actualizado exitosamente" : "Cliente registrado exitosamente");
    cerrarModal();
    // Vuelve a cargar la tabla con los datos actualizados.
    fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
  } catch (error) {
    alert("Error al guardar el cliente: " + error.message);
  }
}

async function eliminarCliente(id) {
  if (confirm("¿Quiere eliminar este cliente? Esta acción no se puede deshacer.")) {
    try {
      await supabase.from("prescripcion_clienten").delete().eq("cod_cliente", id);
      const { error } = await supabase.from("clientes").delete().eq("cod_cliente", id);
      if (error) throw error;
      alert("Cliente eliminado exitosamente");
      // Vuelve a cargar la tabla con los datos actualizados.
      fetchClientes({ page: 1, itemsPerPage: itemsPerPage.value });
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
  dialog.value = true;
  nextTick(() => { nameCliente.value?.focus(); });
}

function abrirModalCrear() {
  limpiarFormulario();
  dialog.value = true;
  nextTick(() => { nameCliente.value?.focus(); });
}

function cerrarModal() {
  dialog.value = false;
  limpiarFormulario();
}

function limpiarFormulario() {
  editId.value = null;
  nombreCliente.value = "";
  apellidoPaterno.value = "";
  apellidoMaterno.value = "";
  telefonoCliente.value = "";
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
</style>

