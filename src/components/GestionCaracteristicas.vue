<template>
  <v-container fluid>
    <!-- Encabezado de la página -->
    <v-row justify="center" class="text-center my-4">
      <v-col cols="12">
        <h1 class="text-h4 font-weight-bold text-grey-darken-3">Gestión de Características</h1>
        <p class="text-subtitle-1 text-grey-darken-1 mt-2">
          Seleccione una característica para administrar sus registros.
        </p>
      </v-col>
    </v-row>

    <!-- Cuadrícula de gestión -->
    <v-row justify="center">
      <v-col v-for="card in managementCards" :key="card.type" cols="12" sm="6" md="4" lg="2">
        <v-card @click="abrirDialogoGestion(card.type)" hover class="text-center pa-4" rounded="lg" elevation="2">
          <v-icon :icon="card.icon" color="primary" size="48" class="mb-3"></v-icon>
          <div class="font-weight-bold">{{ card.title }}</div>
        </v-card>
      </v-col>
    </v-row>

    <!-- Diálogo para CRUD -->
    <v-dialog v-model="showManagementDialog" max-width="1200px" persistent>
      <v-card>
        <v-toolbar color="primary" density="compact">
          <v-toolbar-title class="text-h6">{{ modalTitle }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-btn icon="mdi-close" @click="cerrarDialogoGestion"></v-btn>
        </v-toolbar>

        <v-card-text class="pt-4">
          <v-container>
            <v-row>
              <!-- Formulario a la izquierda -->
              <v-col cols="12" md="4">
                <v-card variant="outlined" class="sticky-form">
                  <v-card-title>{{ editId ? 'Editar Registro' : 'Nuevo Registro' }}</v-card-title>
                  <v-card-text>
                    <!-- Campos dinámicos del formulario -->
                    <template v-if="modalType === 'categoria'">
                      <v-text-field v-model="formState.nombre_categoria_producto" label="Nombre de la categoría *" variant="outlined" density="compact" ref="firstInput"></v-text-field>
                      <v-textarea v-model="formState.descripcion_categoria" label="Descripción (opcional)" variant="outlined" density="compact" rows="3"></v-textarea>
                    </template>
                    
                    <template v-if="modalType === 'proveedor'">
                      <v-text-field v-model="formState.nombre_proveedor" label="Nombre del proveedor *" variant="outlined" density="compact" ref="firstInput"></v-text-field>
                      <v-text-field v-model="formState.telefono_proveedor" label="Teléfono *" variant="outlined" density="compact"></v-text-field>
                      <v-text-field v-model="formState.razon_social_proveedor" label="Razón Social" variant="outlined" density="compact"></v-text-field>
                      <v-text-field v-model="formState.direccion_proveedor" label="Dirección" variant="outlined" density="compact"></v-text-field>
                      <v-text-field v-model="formState.email_proveedor" label="Email" type="email" variant="outlined" density="compact"></v-text-field>
                      <v-text-field v-model="formState.nit_proveedor" label="NIT" variant="outlined" density="compact"></v-text-field>
                      <v-checkbox v-model="formState.activo" label="Activo"></v-checkbox>
                    </template>

                    <template v-if="modalType === 'material'">
                      <v-text-field v-model="formState.descripcion_material" label="Descripción del material *" variant="outlined" density="compact" ref="firstInput"></v-text-field>
                    </template>

                    <template v-if="modalType === 'modelo'">
                      <v-text-field v-model="formState.descripcion_modelo" label="Descripción del modelo *" variant="outlined" density="compact" ref="firstInput"></v-text-field>
                    </template>

                    <template v-if="modalType === 'color'">
                      <v-text-field v-model="formState.nombre_color" label="Nombre del color *" variant="outlined" density="compact" ref="firstInput"></v-text-field>
                      <v-text-field v-model="formState.codigo_hex" label="Código Hexadecimal" variant="outlined" density="compact">
                        <template v-slot:prepend-inner>
                          <v-menu activator="parent" :close-on-content-click="false">
                            <v-color-picker v-model="formState.codigo_hex" hide-inputs></v-color-picker>
                          </v-menu>
                           <v-icon :style="{ backgroundColor: formState.codigo_hex, borderRadius: '4px', marginRight: '8px', border: '1px solid #ccc' }" />
                        </template>
                      </v-text-field>
                    </template>
                  </v-card-text>
                  <v-card-actions class="px-4 pb-4">
                    <v-btn color="primary" variant="flat" @click="guardarItem">{{ editId ? 'Actualizar' : 'Guardar' }}</v-btn>
                    <v-btn v-if="editId" variant="outlined" @click="cancelarEdicion">Cancelar</v-btn>
                  </v-card-actions>
                </v-card>
              </v-col>

              <!-- Tabla a la derecha -->
              <v-col cols="12" md="8">
                <v-data-table-server
                  :headers="modalConfig ? modalConfig.headers : []"
                  :items="data"
                  :items-length="data.length"
                  :loading="isLoading"
                  :item-value="modalConfig ? modalConfig.primaryKey : ''"
                  density="compact"
                  class="elevation-1"
                >
                  <template v-slot:item.activo="{ item }">
                    <v-chip :color="item.activo ? 'green' : 'red'" size="small" variant="flat">
                      {{ item.activo ? 'Sí' : 'No' }}
                    </v-chip>
                  </template>

                  <template v-slot:item.codigo_hex="{ item }">
                     <div class="d-flex align-center">
                        <v-sheet :color="item.codigo_hex" height="20" width="20" class="mr-2" border rounded></v-sheet>
                        <span>{{ item.codigo_hex }}</span>
                    </div>
                  </template>

                  <template v-slot:item.actions="{ item }">
                    <v-icon icon="mdi-pencil" class="me-2" color="orange" @click="editarItem(item)"></v-icon>
                    <v-icon icon="mdi-delete" color="red" @click="confirmarEliminacion(item[modalConfig.primaryKey])"></v-icon>
                  </template>
                </v-data-table-server>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
      </v-card>
    </v-dialog>

    <!-- Diálogo de confirmación de eliminación -->
    <v-dialog v-model="confirmDialog" max-width="400px">
        <v-card>
            <v-card-title class="text-h5">Confirmar Eliminación</v-card-title>
            <v-card-text>¿Estás seguro de que deseas eliminar este registro?</v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn text @click="confirmDialog = false">Cancelar</v-btn>
                <v-btn color="red" variant="flat" @click="ejecutarEliminacion">Eliminar</v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>

    <!-- Snackbar para notificaciones -->
    <v-snackbar v-model="snackbar.show" :color="snackbar.color" :timeout="3000" location="top right">
        {{ snackbar.text }}
    </v-snackbar>
  </v-container>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue';
import { supabase } from '../lib/supabaseClient.js'; 

// --- CONFIGURACIÓN CENTRAL (CORREGIDA USANDO TU VERSIÓN ANTIGUA) ---
const CONFIG = {
  categoria: {
    tableName: 'categoria_producto',
    primaryKey: 'cod_categoria',
    title: 'Gestionar Categorías',
    fields: { nombre_categoria_producto: '', descripcion_categoria: '' },
    headers: [
      { key: 'nombre_categoria_producto', title: 'Nombre' },
      { key: 'descripcion_categoria', title: 'Descripción' },
    ],
    requiredFields: ['nombre_categoria_producto'],
    orderBy: 'fecha_creacion_categoria',
    orderAscending: false
  },
  proveedor: {
    tableName: 'proveedores',
    primaryKey: 'cod_proveedor',
    title: 'Gestionar Proveedores',
    fields: { 
      razon_social_proveedor: '', 
      nombre_proveedor: '', 
      telefono_proveedor: '', 
      direccion_proveedor: '', 
      email_proveedor: '', 
      nit_proveedor: '', 
      activo: true 
    },
    headers: [
      { key: 'nombre_proveedor', title: 'Nombre' },
      { key: 'telefono_proveedor', title: 'Teléfono' },
      { key: 'email_proveedor', title: 'Email' },
      { key: 'activo', title: 'Activo' },
    ],
    requiredFields: ['nombre_proveedor', 'telefono_proveedor'],
    orderBy: 'fecha_creacion_proveedor',
    orderAscending: false
  },
  material: {
    tableName: 'material_producto',
    primaryKey: 'cod_material',
    title: 'Gestionar Materiales',
    fields: { descripcion_material: '' },
    headers: [{ key: 'descripcion_material', title: 'Descripción' }],
    requiredFields: ['descripcion_material'],
    orderBy: 'fecha_creacion_material',
    orderAscending: false
  },
  modelo: {
    tableName: 'modelo_producto',
    primaryKey: 'cod_modelo',
    title: 'Gestionar Modelos',
    fields: { descripcion_modelo: '' },
    headers: [{ key: 'descripcion_modelo', title: 'Descripción' }],
    requiredFields: ['descripcion_modelo'],
    orderBy: 'fecha_creacion_modelo',
    orderAscending: false
  },
  color: {
    tableName: 'color_montura',
    primaryKey: 'cod_color_montura',
    title: 'Gestionar Colores',
    fields: { nombre_color: '', codigo_hex: '#000000' },
     headers: [
      { key: 'nombre_color', title: 'Nombre Color' },
      { key: 'codigo_hex', title: 'Muestra' },
    ],
    requiredFields: ['nombre_color'],
    orderBy: 'nombre_color',
    orderAscending: true
  }
};

// -- ESTADO REACTIVO --
const showManagementDialog = ref(false);
const modalType = ref(null);
const isLoading = ref(false);
const editId = ref(null);
const data = ref([]);
const formState = ref({});
const firstInput = ref(null);
const confirmDialog = ref(false);
const itemAEliminarId = ref(null);
const snackbar = ref({ show: false, text: '', color: '' });

const managementCards = [
    { type: 'categoria', title: 'Categorías', icon: 'mdi-tag-outline' },
    { type: 'proveedor', title: 'Proveedores', icon: 'mdi-truck-delivery-outline' },
    { type: 'material', title: 'Materiales', icon: 'mdi-cog' },
    { type: 'modelo', title: 'Modelos', icon: 'mdi-glasses' },
    { type: 'color', title: 'Colores', icon: 'mdi-palette' },
];

// -- PROPIEDADES COMPUTADAS --
const modalConfig = computed(() => {
    if (!modalType.value) return null;
    const config = CONFIG[modalType.value];
    const actionsHeader = { title: 'Acciones', key: 'actions', sortable: false, align: 'end' };
    const headers = config.headers ? [...config.headers, actionsHeader] : [actionsHeader];
    return { ...config, headers };
});
const modalTitle = computed(() => modalConfig.value?.title || 'Gestionar');

// -- MÉTODOS --
function mostrarNotificacion(text, color = 'success') {
    snackbar.value.text = text;
    snackbar.value.color = color;
    snackbar.value.show = true;
}

function resetForm() {
    editId.value = null;
    formState.value = modalConfig.value ? { ...modalConfig.value.fields } : {};
}

function cancelarEdicion() {
    resetForm();
}

async function abrirDialogoGestion(type) {
    modalType.value = type;
    resetForm();
    showManagementDialog.value = true;
    await fetchData();
    nextTick(() => firstInput.value?.focus());
}

function cerrarDialogoGestion() {
    showManagementDialog.value = false;
    setTimeout(() => {
        modalType.value = null;
        data.value = [];
        editId.value = null;
    }, 300);
}

async function fetchData() {
    if (!modalConfig.value) return;
    isLoading.value = true;
    try {
        const { data: result, error } = await supabase
            .from(modalConfig.value.tableName)
            .select('*')
            .order(modalConfig.value.orderBy, { ascending: modalConfig.value.orderAscending });
        if (error) throw error;
        data.value = result || [];
    } catch (error) {
        mostrarNotificacion(`Error al cargar datos: ${error.message}`, 'error');
        data.value = [];
    } finally {
        isLoading.value = false;
    }
}

function editarItem(item) {
    const config = modalConfig.value;
    if (!config) return;
    editId.value = item[config.primaryKey];
    formState.value = { ...item };
    nextTick(() => firstInput.value?.focus());
}

async function guardarItem() {
    const config = modalConfig.value;
    if (!config) return;

    for (const field of config.requiredFields) {
        if (!formState.value[field]) {
            mostrarNotificacion(`El campo "${field.replace(/_/g, ' ')}" es obligatorio.`, 'warning');
            return;
        }
    }

    const dataToSave = { ...formState.value };
    Object.keys(dataToSave).forEach(key => {
        if (dataToSave[key] === '') dataToSave[key] = null;
    });

    try {
        let error;
        if (editId.value) {
            const { error: updateError } = await supabase
                .from(config.tableName)
                .update(dataToSave)
                .eq(config.primaryKey, editId.value);
            error = updateError;
        } else {
            delete dataToSave[config.primaryKey];
            const { error: insertError } = await supabase
                .from(config.tableName)
                .insert(dataToSave);
            error = insertError;
        }
        if (error) throw error;
        mostrarNotificacion(`Registro ${editId.value ? 'actualizado' : 'creado'} con éxito.`);
        resetForm();
        await fetchData();
    } catch (error) {
        mostrarNotificacion(`Error al guardar: ${error.message}`, 'error');
    }
}

function confirmarEliminacion(id) {
    itemAEliminarId.value = id;
    confirmDialog.value = true;
}

async function ejecutarEliminacion() {
    const config = modalConfig.value;
    if (!config || !itemAEliminarId.value) return;

    try {
        const { error } = await supabase
            .from(config.tableName)
            .delete()
            .eq(config.primaryKey, itemAEliminarId.value);
        if (error) throw error;
        mostrarNotificacion('Registro eliminado exitosamente.');
        await fetchData();
    } catch (error) {
        mostrarNotificacion(`Error al eliminar: ${error.message}`, 'error');
    } finally {
        confirmDialog.value = false;
        itemAEliminarId.value = null;
    }
}
</script>

<style scoped>
.sticky-form {
    position: sticky;
    top: 20px;
}
.v-data-table-server {
    max-height: 70vh;
}
</style>