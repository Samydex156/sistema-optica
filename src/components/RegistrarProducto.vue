<template>
  <div>
    <h3>Registro de Productos</h3>
    <div class="botones-arriba">
      <button @click="abrirModalCrear" class="btn-nuevo-producto">Nuevo Producto</button>
      <button @click="getProductos">Actualizar</button>
    </div>
    
    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Descripción</th>
          <th>Color</th>
          <th>Precio Venta</th>
          <th>Activo</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(producto, index) in productos" :key="producto.cod_producto">
          <td>{{ index + 1 }}</td>
          <td>{{ producto.descripcion_producto }}</td>
          <td>
            <div class="color-info">
              <div 
                class="color-sample" 
                :style="{ backgroundColor: producto.color_hex || '#ccc' }"
                :title="producto.color_nombre"
              ></div>
              {{ producto.color_nombre }}
            </div>
          </td>
          <td>Bs. {{ producto.precio_venta_producto }}</td>
          <td>
            <span :class="producto.activo ? 'activo-si' : 'activo-no'">
              {{ producto.activo ? 'Sí' : 'No' }}
            </span>
          </td>
          <td>
            <button @click="editarProducto(producto)">Editar</button>
            <button @click="cambiarEstado(producto.cod_producto, !producto.activo)" 
                    :class="producto.activo ? 'btn-desactivar' : 'btn-activar'">
              {{ producto.activo ? 'Desactivar' : 'Activar' }}
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <BaseModal 
      v-model="showModal" 
      :title="editId ? 'Editar Producto' : 'Registrar Producto'" 
      size="lg"
    >
      <div class="form-grid">
        <div class="form-group">
          <label>Categoría:</label>
          <AutoComplete
            ref="categoriaAutoComplete"
            v-model="formProducto.cod_categoria"
            :options="categoriaOptions"
            placeholder="Buscar categoría..."
            @change="actualizarDescripcion"
          />
        </div>

        <div class="form-group">
          <label>Proveedor / Marca:</label>
          <AutoComplete
            v-model="formProducto.proveedor_producto"
            :options="proveedorOptions"
            placeholder="Buscar proveedor o marca..."
            @change="actualizarDescripcion"
          />
        </div>

        <div class="form-group">
          <label>Material:</label>
          <AutoComplete
            v-model="formProducto.material_producto"
            :options="materialOptions"
            placeholder="Buscar material..."
            @change="actualizarDescripcion"
          />
        </div>

        <div class="form-group">
          <label>Modelo:</label>
          <AutoComplete
            v-model="formProducto.modelo_producto"
            :options="modeloOptions"
            placeholder="Buscar modelo..."
            @change="actualizarDescripcion"
          />
        </div>

        <div class="form-group">
          <label>Color:</label>
          <AutoComplete
            v-model="formProducto.color_producto"
            :options="colorOptions"
            placeholder="Buscar color..."
            @change="actualizarDescripcion"
          />
        </div>

        <div class="form-group">
          <label>Género:</label>
          <select v-model="formProducto.genero_producto" @change="actualizarDescripcion">
            <option value="UNISEX">Unisex</option>
            <option value="MASCULINO">Masculino</option>
            <option value="FEMENINO">Femenino</option>
          </select>
        </div>

        <div class="form-group form-group-full">
          <label>Descripción:</label>
          <input v-model="formProducto.descripcion_producto" placeholder="Descripción del producto" />
          <small class="help-text">La descripción se genera automáticamente, pero puedes editarla</small>
        </div>

        <div class="form-group">
          <label>Precio Compra:</label>
          <input v-model="formProducto.precio_compra_producto" type="number" step="0.01" placeholder="0.00" />
        </div>

        <div class="form-group">
          <label>Precio Venta:</label>
          <input v-model="formProducto.precio_venta_producto" type="number" step="0.01" placeholder="0.00" />
        </div>

        <div class="form-group">
          <label>Stock Mínimo:</label>
          <input v-model="formProducto.stock_minimo_producto" type="number" placeholder="0" />
        </div>

        <div class="form-group">
          <label>Estado:</label>
          <select v-model="formProducto.activo">
            <option :value="true">Activo</option>
            <option :value="false">Inactivo</option>
          </select>
        </div>
      </div>

      <template #footer>
        <button @click="guardarProducto" class="btn-guardar">Guardar</button>
        <button @click="cerrarModal" class="btn-cancelar">Cancelar</button>
      </template>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, computed } from "vue";
import { supabase } from "../lib/supabaseClient.js";
import AutoComplete from "./AutoComplete.vue";
import BaseModal from "./BaseModal.vue";

// --- ESTADO GENERAL ---
const productos = ref([]);
const categorias = ref([]);
const proveedores = ref([]);
const materiales = ref([]);
const modelos = ref([]);
const colores = ref([]);
const showModal = ref(false);
const editId = ref(null);

const categoriaAutoComplete = ref(null);

// --- FORMULARIO DEL PRODUCTO ---
const formProducto = ref({
  cod_categoria: "",
  proveedor_producto: "",
  material_producto: "",
  modelo_producto: "",
  color_producto: "",
  genero_producto: "UNISEX",
  descripcion_producto: "",
  precio_compra_producto: 0,
  precio_venta_producto: 0,
  stock_minimo_producto: 0,
  activo: true
});

// --- OPCIONES PARA AUTOCOMPLETE ---
const categoriaOptions = computed(() =>
  categorias.value.map(c => ({
    value: c.cod_categoria,
    label: c.nombre_categoria_producto
  }))
);

const proveedorOptions = computed(() => 
  proveedores.value.map(p => ({
    value: p.cod_proveedor,
    label: p.nombre_proveedor
  }))
);

const materialOptions = computed(() => 
  materiales.value.map(m => ({
    value: m.cod_material,
    label: m.descripcion_material
  }))
);

const modeloOptions = computed(() => 
  modelos.value.map(mo => ({
    value: mo.cod_modelo,
    label: mo.descripcion_modelo
  }))
);

const colorOptions = computed(() => 
  colores.value.map(c => ({
    value: c.cod_color_montura,
    label: c.nombre_color
  }))
);

// --- OBTENCIÓN DE DATOS ---
async function getProductos() {
  const { data, error } = await supabase
    .from("productos")
    .select(`
      cod_producto, 
      descripcion_producto, 
      precio_venta_producto, 
      activo, 
      cod_categoria,
      proveedor_producto, 
      material_producto, 
      modelo_producto, 
      color_producto, 
      genero_producto, 
      precio_compra_producto, 
      stock_minimo_producto,
      color_montura(nombre_color, codigo_hex),
      categoria_producto(nombre_categoria_producto)
    `)
    .order("fecha_creacion_producto", { ascending: false });

  if (error) {
    console.error("Error al obtener productos:", error);
    return;
  }

  productos.value = (data || []).map(producto => ({
    ...producto,
    color_nombre: producto.color_montura?.nombre_color || 'N/A',
    color_hex: producto.color_montura?.codigo_hex || '#ccc',
    categoria_nombre: producto.categoria_producto?.nombre_categoria_producto || 'N/A'
  }));
}

async function getCategorias() {
  const { data } = await supabase.from("categoria_producto").select("*").order("nombre_categoria_producto");
  categorias.value = data || [];
}

async function getProveedores() {
  const { data } = await supabase.from("proveedores").select("*").order("nombre_proveedor");
  proveedores.value = data || [];
}

async function getMateriales() {
  const { data } = await supabase.from("material_producto").select("*").order("descripcion_material");
  materiales.value = data || [];
}

async function getModelos() {
  const { data } = await supabase.from("modelo_producto").select("*").order("descripcion_modelo");
  modelos.value = data || [];
}

async function getColores() {
  const { data } = await supabase.from("color_montura").select("*").order("nombre_color");
  colores.value = data || [];
}

// --- LÓGICA DEL COMPONENTE ---
function actualizarDescripcion() {
  const categoria = categorias.value.find(c => c.cod_categoria == formProducto.value.cod_categoria);
  const proveedor = proveedores.value.find(p => p.cod_proveedor == formProducto.value.proveedor_producto);
  const material = materiales.value.find(m => m.cod_material == formProducto.value.material_producto);
  const modelo = modelos.value.find(mo => mo.cod_modelo == formProducto.value.modelo_producto);
  const color = colores.value.find(c => c.cod_color_montura == formProducto.value.color_producto);
  const genero = formProducto.value.genero_producto;

  let descripcion = "";

  if (categoria && categoria.nombre_categoria_producto) {
    descripcion += categoria.nombre_categoria_producto;
  }
  if (proveedor && proveedor.nombre_proveedor) {
    descripcion += (descripcion ? " " : "") + proveedor.nombre_proveedor;
  }
  if (modelo && modelo.descripcion_modelo) {
    descripcion += (descripcion ? " " : "") + modelo.descripcion_modelo;
  }
  if (material && material.descripcion_material) {
    descripcion += (descripcion ? " - " : "") + material.descripcion_material;
  }
  if (color && color.nombre_color) {
    descripcion += (descripcion ? " " : "") + color.nombre_color;
  }
  if (genero) {
    descripcion += (descripcion ? " (" : "(") + genero + ")";
  }
  
  if (descripcion) {
    formProducto.value.descripcion_producto = descripcion;
  }
}

async function guardarProducto() {
  if (!formProducto.value.cod_categoria || !formProducto.value.proveedor_producto || !formProducto.value.material_producto || !formProducto.value.modelo_producto || !formProducto.value.color_producto) {
    alert("Debe seleccionar categoría, proveedor/marca, material, modelo y color.");
    return;
  }
  if (!formProducto.value.descripcion_producto.trim()) {
    alert("La descripción es requerida");
    return;
  }

  const productoData = {
    cod_categoria: parseInt(formProducto.value.cod_categoria),
    proveedor_producto: parseInt(formProducto.value.proveedor_producto),
    material_producto: parseInt(formProducto.value.material_producto),
    modelo_producto: parseInt(formProducto.value.modelo_producto),
    color_producto: parseInt(formProducto.value.color_producto),
    genero_producto: formProducto.value.genero_producto,
    descripcion_producto: formProducto.value.descripcion_producto.trim(),
    precio_compra_producto: parseFloat(formProducto.value.precio_compra_producto) || 0.00,
    precio_venta_producto: parseFloat(formProducto.value.precio_venta_producto) || 0.00,
    stock_minimo_producto: parseInt(formProducto.value.stock_minimo_producto) || 0,
    activo: formProducto.value.activo,
    ingresado_por: 1 // TODO: Reemplazar con el ID del usuario autenticado
  };

  try {
    const { error } = editId.value
      ? await supabase.from("productos").update(productoData).eq("cod_producto", editId.value)
      : await supabase.from("productos").insert(productoData);

    if (error) throw error;
    alert(`Producto ${editId.value ? 'actualizado' : 'registrado'} exitosamente`);

    cerrarModal();
    getProductos();
  } catch (error) {
    console.error("Error al guardar producto:", error);
    alert("Error al guardar el producto: " + error.message);
  }
}

async function editarProducto(producto) {
  editId.value = producto.cod_producto;
  formProducto.value = {
    cod_categoria: producto.cod_categoria,
    proveedor_producto: producto.proveedor_producto,
    material_producto: producto.material_producto,
    modelo_producto: producto.modelo_producto,
    color_producto: producto.color_producto,
    genero_producto: producto.genero_producto,
    descripcion_producto: producto.descripcion_producto,
    precio_compra_producto: producto.precio_compra_producto,
    precio_venta_producto: producto.precio_venta_producto,
    stock_minimo_producto: producto.stock_minimo_producto,
    activo: producto.activo
  };
  showModal.value = true;
  
  nextTick(() => {
    if (categoriaAutoComplete.value) {
      categoriaAutoComplete.value.focus();
    }
  });
}

async function cambiarEstado(id, nuevoEstado) {
  try {
    const { error } = await supabase
      .from("productos")
      .update({ activo: nuevoEstado })
      .eq("cod_producto", id);
    if (error) throw error;
    getProductos();
    alert(`Producto ${nuevoEstado ? 'activado' : 'desactivado'} exitosamente`);
  } catch (error) {
    console.error("Error al cambiar estado:", error);
    alert("Error al cambiar el estado del producto");
  }
}

function limpiarFormulario() {
  editId.value = null;
  formProducto.value = {
    cod_categoria: "",
    proveedor_producto: "",
    material_producto: "",
    modelo_producto: "",
    color_producto: "",
    genero_producto: "UNISEX",
    descripcion_producto: "",
    precio_compra_producto: 0,
    precio_venta_producto: 0,
    stock_minimo_producto: 0,
    activo: true
  };
}

// --- MANEJO DEL MODAL ---
function abrirModalCrear() {
  limpiarFormulario();
  showModal.value = true;
  nextTick(() => {
    if (categoriaAutoComplete.value) {
      categoriaAutoComplete.value.focus();
    }
  });
}

function cerrarModal() {
  showModal.value = false;
  limpiarFormulario();
}

// --- SUSCRIPCIÓN A CAMBIOS ---
function subscribeToProductos() {
  const channel = supabase
    .channel("productos")
    .on(
      "postgres_changes",
      { event: "*", schema: "public", table: "productos" },
      () => getProductos()
    )
    .subscribe();
  return () => supabase.removeChannel(channel);
}

// --- CICLO DE VIDA ---
onMounted(async () => {
  await Promise.all([
    getProductos(),
    getCategorias(),
    getProveedores(),
    getMateriales(),
    getModelos(),
    getColores()
  ]);
  const unsubscribe = subscribeToProductos();
  onUnmounted(unsubscribe);
});
</script>

<style scoped>
.btn-nuevo-producto {
  background: #007bff;
  color: white;
}
.btn-nuevo-producto:hover {
  background: #0056b3;
}
h3 {
  margin: 0 0 20px 0;
  color: #333;
  font-size: 24px;
  font-weight: 600;
  padding-bottom: 15px;
  border-bottom: 1px solid #e0e0e0;
}
.botones-arriba {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}
button {
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}
table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 4px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}
th {
  background: #343a40;
  color: white;
  padding: 12px 8px;
  text-align: left;
  font-size: 13px;
  font-weight: 500;
}
td {
  padding: 10px 8px;
  border-bottom: 1px solid #dee2e6;
  font-size: 13px;
}
tr:hover {
  background: #f8f9fa;
}
.color-info {
  display: flex;
  align-items: center;
  gap: 8px;
}
.color-sample {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: 1px solid #ddd;
  flex-shrink: 0;
}
.activo-si { color: #28a745; font-weight: 500; }
.activo-no { color: #dc3545; font-weight: 500; }
td button {
  padding: 4px 8px;
  margin: 0 2px;
  border-radius: 3px;
  font-size: 11px;
}
.btn-desactivar { background: #dc3545; color: white; }
.btn-desactivar:hover { background: #c82333; }
.btn-activar { background: #28a745; color: white; }
.btn-activar:hover { background: #218838; }
td button:not(.btn-desactivar):not(.btn-activar) { background: #ffc107; color: #212529; }
td button:not(.btn-desactivar):not(.btn-activar):hover { background: #e0a800; }

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}
.form-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}
.form-group-full {
  grid-column: 1 / -1;
}
.form-group label {
  font-weight: 500;
  color: #333;
  font-size: 14px;
}
.form-group input,
.form-group select {
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  width: 100%;
  box-sizing: border-box;
}
.form-group input:focus,
.form-group select:focus {
  border-color: #007bff;
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
  outline: none;
}
.help-text {
  color: #6c757d;
  font-size: 12px;
  margin-top: 2px;
}

.btn-guardar {
  background: #007bff;
  color: white;
}
.btn-guardar:hover {
  background: #0056b3;
}
.btn-cancelar {
  background: #6c757d;
  color: white;
}
.btn-cancelar:hover {
  background: #545b62;
}

@media (max-width: 768px) {
  .botones-arriba {
    flex-direction: column;
  }
  table {
    font-size: 11px;
  }
  th, td {
    padding: 8px 6px;
  }
  .form-grid {
    grid-template-columns: 1fr;
    padding: 10px 0;
  }
}
</style>