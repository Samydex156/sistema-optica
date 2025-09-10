<template>
  <div class="page-container">
    <header class="page-header">
      <h3>Gestión de Características de Productos</h3>
      <div class="header-actions">
        </div>
    </header>

    <p class="page-description">
      Seleccione una característica para ver, agregar, editar o eliminar registros.
    </p>

    <div class="management-grid">
      <button @click="abrirModal('categoria')" class="btn-management">
        <span class="icon">🏷️</span>
        <span>Gestionar Categorías</span>
      </button>
      <button @click="abrirModal('proveedor')" class="btn-management">
        <span class="icon">🚚</span>
        <span>Gestionar Proveedores</span>
      </button>
      <button @click="abrirModal('material')" class="btn-management">
        <span class="icon">🧱</span>
        <span>Gestionar Materiales</span>
      </button>
      <button @click="abrirModal('modelo')" class="btn-management">
        <span class="icon">👓</span>
        <span>Gestionar Modelos</span>
      </button>
       <button @click="abrirModal('color')" class="btn-management">
        <span class="icon">🎨</span>
        <span>Gestionar Colores</span>
      </button>
    </div>

    <BaseModal v-model="showModal" :title="modalTitle" size="lg">
      <div class="modal-content">
        <div class="form-section">
          <h4>{{ editId ? 'Editar Registro' : 'Nuevo Registro' }}</h4>
          
          <div v-if="modalType === 'categoria'" class="form-container">
            <input v-model="formState.nombre_categoria_producto" placeholder="Nombre de la categoría *" class="form-input" ref="firstInput" />
            <textarea v-model="formState.descripcion_categoria" placeholder="Descripción (opcional)" rows="3" class="form-input"></textarea>
          </div>

          <div v-if="modalType === 'proveedor'" class="form-grid">
            <input v-model="formState.nombre_proveedor" placeholder="Nombre del proveedor *" class="form-input" ref="firstInput" />
            <input v-model="formState.telefono_proveedor" placeholder="Teléfono *" class="form-input" />
            <input v-model="formState.razon_social_proveedor" placeholder="Razón Social" class="form-input" />
            <input v-model="formState.direccion_proveedor" placeholder="Dirección" class="form-input" />
            <input v-model="formState.email_proveedor" type="email" placeholder="Email" class="form-input" />
            <input v-model="formState.nit_proveedor" placeholder="NIT" class="form-input" />
            <div class="form-checkbox">
              <input id="proveedor-activo" type="checkbox" v-model="formState.activo" />
              <label for="proveedor-activo">Activo</label>
            </div>
          </div>

          <div v-if="modalType === 'material'" class="form-container">
            <input v-model="formState.descripcion_material" placeholder="Descripción del material *" class="form-input" ref="firstInput" />
          </div>

          <div v-if="modalType === 'modelo'" class="form-container">
            <input v-model="formState.descripcion_modelo" placeholder="Descripción del modelo *" class="form-input" ref="firstInput" />
          </div>

          <div v-if="modalType === 'color'" class="form-grid-color">
            <input v-model="formState.nombre_color" placeholder="Nombre del color *" class="form-input" ref="firstInput" />
            <div class="color-picker-wrapper">
                <input v-model="formState.codigo_hex" type="color" class="color-picker-input" />
                <input v-model="formState.codigo_hex" placeholder="#FFFFFF" class="form-input hex-input" />
            </div>
          </div>


          <div class="form-actions">
            <button @click="guardarItem" class="btn btn-primary">
              {{ editId ? 'Actualizar' : 'Guardar' }}
            </button>
            <button v-if="editId" @click="cancelarEdicion" class="btn btn-secondary">
              Cancelar Edición
            </button>
          </div>
        </div>

        <div class="table-section">
          <h4>Registros Existentes</h4>
          <div class="table-responsive">
            <div v-if="isLoading" class="text-center">Cargando...</div>
            <table v-else>
              <thead>
                <tr v-if="modalConfig">
                  <th v-for="header in modalConfig.headers" :key="header.key">{{ header.label }}</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="data.length === 0">
                  <td :colspan="modalConfig ? modalConfig.headers.length + 1 : 1" class="text-center">
                    No se encontraron registros.
                  </td>
                </tr>
                <tr v-for="item in data" :key="item[modalConfig.primaryKey]">
                  <td v-for="header in modalConfig.headers" :key="header.key" :data-label="header.label">
                    <span v-if="header.key === 'activo'" :class="item[header.key] ? 'status-active' : 'status-inactive'">
                        {{ item[header.key] ? 'Sí' : 'No' }}
                    </span>
                    <span v-else-if="header.key === 'codigo_hex'" class="color-cell">
                        <span class="color-preview" :style="{ backgroundColor: item[header.key] }"></span>
                        {{ item[header.key] || '-' }}
                    </span>
                    <span v-else>
                        {{ item[header.key] || '-' }}
                    </span>
                  </td>
                  <td data-label="Acciones" class="actions-cell">
                    <button @click="editarItem(item)" class="btn-icon btn-edit" title="Editar">✏️</button>
                    <button @click="eliminarItem(item[modalConfig.primaryKey])" class="btn-icon btn-delete" title="Eliminar">🗑️</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <template #footer>
        <button @click="cerrarModal" class="btn btn-secondary">Cerrar</button>
      </template>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue';
import { supabase } from '../lib/supabaseClient.js'; 
import BaseModal from './BaseModal.vue';

// --- CONFIGURACIÓN CENTRAL (CORREGIDA) ---
const CONFIG = {
  categoria: {
    tableName: 'categoria_producto',
    primaryKey: 'cod_categoria',
    title: 'Gestionar Categorías',
    fields: { nombre_categoria_producto: '', descripcion_categoria: '' },
    headers: [
      { key: 'nombre_categoria_producto', label: 'Nombre' },
      { key: 'descripcion_categoria', label: 'Descripción' },
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
      { key: 'nombre_proveedor', label: 'Nombre' },
      { key: 'telefono_proveedor', label: 'Teléfono' },
      { key: 'email_proveedor', label: 'Email' },
      { key: 'activo', label: 'Activo' },
    ],
    requiredFields: ['nombre_proveedor', 'telefono_proveedor'],
    orderBy: 'fecha_creacion_proveedor',
    orderAscending: false
  },
  material: {
    tableName: 'material_producto',
    primaryKey: 'cod_material',
    title: 'Gestionar Materiales de Producto',
    fields: { descripcion_material: '' },
    headers: [{ key: 'descripcion_material', label: 'Descripción' }],
    requiredFields: ['descripcion_material'],
    orderBy: 'fecha_creacion_material',
    orderAscending: false
  },
  modelo: {
    tableName: 'modelo_producto',
    primaryKey: 'cod_modelo',
    title: 'Gestionar Modelos de Producto',
    fields: { descripcion_modelo: '' },
    headers: [{ key: 'descripcion_modelo', label: 'Descripción' }],
    requiredFields: ['descripcion_modelo'],
    orderBy: 'fecha_creacion_modelo',
    orderAscending: false
  },
  color: {
    tableName: 'color_montura',
    primaryKey: 'cod_color_montura',
    title: 'Gestionar Colores de Montura',
    fields: { nombre_color: '', codigo_hex: '#000000' },
     headers: [
      { key: 'nombre_color', label: 'Nombre Color' },
      { key: 'codigo_hex', label: 'Muestra' },
    ],
    requiredFields: ['nombre_color'],
    orderBy: 'nombre_color', // <-- CORRECCIÓN: Ordenar por nombre
    orderAscending: true     // <-- CORRECCIÓN: Ordenar de forma ascendente (A-Z)
  }
};

// --- ESTADO DEL COMPONENTE ---
const showModal = ref(false);
const modalType = ref(null);
const isLoading = ref(false);
const editId = ref(null);
const data = ref([]);
const formState = ref({});
const firstInput = ref(null);

// --- PROPIEDADES COMPUTADAS ---
const modalConfig = computed(() => modalType.value ? CONFIG[modalType.value] : null);
const modalTitle = computed(() => modalConfig.value?.title || 'Gestionar');

// --- MÉTODOS DEL MODAL Y FORMULARIO ---
function resetForm() {
  editId.value = null;
  if (modalConfig.value) {
    // Clona el objeto de campos para evitar reactividad no deseada
    formState.value = { ...modalConfig.value.fields };
  } else {
    formState.value = {};
  }
}

function cancelarEdicion() {
    resetForm();
}

async function abrirModal(type) {
  modalType.value = type;
  resetForm();
  showModal.value = true;
  await fetchData();
  nextTick(() => firstInput.value?.focus());
}

function cerrarModal() {
  showModal.value = false;
  modalType.value = null;
  data.value = [];
  editId.value = null;
}

// --- MÉTODOS DE DATOS (CRUD) ---

// fetchData (CORREGIDO)
async function fetchData() {
  if (!modalConfig.value) return;
  isLoading.value = true;
  try {
    const { data: result, error } = await supabase
      .from(modalConfig.value.tableName)
      .select('*')
      .order(modalConfig.value.orderBy, { ascending: modalConfig.value.orderAscending }); // <-- LÓGICA CORREGIDA

    if (error) throw error;
    data.value = result || [];
  } catch (error) {
    alert(`Error al cargar los datos: ${error.message}`);
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

  // Validación
  for (const field of config.requiredFields) {
    if (!formState.value[field]) {
      alert(`El campo "${field.replace(/_/g, ' ')}" es obligatorio.`);
      return;
    }
  }

  // Limpiar campos nulos que no son requeridos
  const dataToSave = { ...formState.value };
  Object.keys(dataToSave).forEach(key => {
    if (dataToSave[key] === '') {
        dataToSave[key] = null;
    }
  });


  try {
    let error;
    if (editId.value) {
      // Actualizar
      const { error: updateError } = await supabase
        .from(config.tableName)
        .update(dataToSave)
        .eq(config.primaryKey, editId.value);
      error = updateError;
    } else {
      // Insertar (quitamos el id primario si existe en el form)
      delete dataToSave[config.primaryKey];
      const { error: insertError } = await supabase
        .from(config.tableName)
        .insert(dataToSave);
      error = insertError;
    }

    if (error) throw error;
    
    alert(`Registro ${editId.value ? 'actualizado' : 'creado'} exitosamente.`);
    resetForm();
    await fetchData();

  } catch (error) {
    alert(`Error al guardar: ${error.message}`);
  }
}

async function eliminarItem(id) {
  const config = modalConfig.value;
  if (!config || !confirm('¿Estás seguro de que deseas eliminar este registro?')) {
    return;
  }

  try {
    const { error } = await supabase
      .from(config.tableName)
      .delete()
      .eq(config.primaryKey, id);

    if (error) throw error;

    alert('Registro eliminado exitosamente.');
    await fetchData();

  } catch (error) {
    alert(`Error al eliminar: ${error.message}`);
  }
}
</script>


<style scoped>
.page-container {
  font-family: 'Segoe UI', system-ui, sans-serif;
  padding: 24px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid #dee2e6;
}

.page-header h3 {
  margin: 0;
  color: #212529;
  font-size: 1.75rem;
  font-weight: 600;
}

.page-description {
    margin-bottom: 24px;
    color: #555;
    font-size: 1rem;
}

.management-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
}

.btn-management {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 12px;
    padding: 24px;
    background-color: #ffffff;
    border: 1px solid #dee2e6;
    border-radius: 8px;
    cursor: pointer;
    text-align: center;
    font-size: 1rem;
    font-weight: 600;
    color: #005A9C;
    transition: all 0.2s ease-in-out;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.btn-management:hover {
    transform: translateY(-4px);
    box-shadow: 0 6px 12px rgba(0, 90, 156, 0.15);
    background-color: #f8f9fa;
    color: #004a80;
}

.btn-management .icon {
    font-size: 2.5rem;
}

/* Modal Content Layout */
.modal-content {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: 24px;
    align-items: flex-start;
}

.form-section {
    position: sticky;
    top: 20px;
}

.form-section h4, .table-section h4 {
    margin-top: 0;
    margin-bottom: 16px;
    padding-bottom: 8px;
    border-bottom: 1px solid #dee2e6;
    color: #005A9C;
}

.table-section {
    max-height: 60vh;
    overflow-y: auto;
}

/* Estilos de Formularios (copiados y adaptados) */
.form-container, .form-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
}
.form-grid-color {
    display: grid;
    grid-template-columns: 1fr;
    gap: 12px;
}
.color-picker-wrapper {
    display: flex;
    align-items: center;
    gap: 8px;
}
.color-picker-input {
    padding: 0;
    border: none;
    width: 40px;
    height: 40px;
    border-radius: 6px;
    cursor: pointer;
}
.hex-input {
    flex-grow: 1;
}

.form-input {
  width: 100%;
  padding: 12px 16px;
  font-size: 14px;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  box-sizing: border-box;
}
.form-input:focus {
  outline: none;
  border-color: #1163b4;
  box-shadow: 5px 2px 0 3px rgba(0, 90, 156, 0.5);
}

.form-checkbox {
    display: flex;
    align-items: center;
    gap: 8px;
    grid-column: 1 / -1;
    padding: 8px 0;
}
.form-checkbox label {
    font-size: 14px;
    cursor: pointer;
}

.form-actions {
    margin-top: 16px;
    display: flex;
    gap: 12px;
}

/* Estilos de Tabla (copiados y adaptados) */
.table-responsive {
  overflow-x: auto;
}
table {
  width: 100%;
  border-collapse: collapse;
}
th, td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #dee2e6;
  font-size: 13px;
}
th {
  background-color: #f8f9fa;
  font-weight: 600;
}
.actions-cell {
  display: flex;
  align-items: center;
  gap: 5px;
}
.text-center {
  text-align: center;
  padding: 24px;
  color: #777;
}

/* Botones genéricos */
.btn {
  display: inline-flex; align-items: center; gap: 4px; padding: 8px 10px;
  border: none; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 500;
}
.btn-primary { background-color: #b1e2eb; }
.btn-primary:hover { background-color: #338fcc; color: white; }
.btn-secondary { background-color: #b1e2eb; }
.btn-secondary:hover { background-color: #338fcc; color: white; }
.btn-icon {
    background: none; border: none; padding: 4px; border-radius: 50%; cursor: pointer;
    font-size: 16px; width: 32px; height: 32px; display: inline-flex;
    align-items: center; justify-content: center;
}
.btn-edit { color: #51db7f; }
.btn-delete { color: #dc3545; }

/* Estilos para celdas especiales */
.status-active { color: #28a745; font-weight: 500; }
.status-inactive { color: #dc3545; font-weight: 500; }
.color-cell { display: flex; align-items: center; gap: 8px; }
.color-preview {
    width: 20px;
    height: 20px;
    border-radius: 4px;
    border: 1px solid #dee2e6;
    flex-shrink: 0;
}

/* Media Queries para responsividad */
@media (max-width: 992px) {
    .modal-content {
        grid-template-columns: 1fr;
    }
    .table-section {
        max-height: 40vh; /* Ajustar altura en vistas más pequeñas */
    }
    .form-section {
        position: static;
    }
}
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
}
</style>