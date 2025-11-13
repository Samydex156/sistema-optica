<template>
  <v-container fluid>

    <v-card variant="flat" border>
      <v-toolbar color="grey-lighten-4">
        <v-card-title class="text-h6 font-weight-regular">
          <v-icon icon="mdi-package-variant-closed" start></v-icon>
          Registro de Productos
        </v-card-title>

        <v-spacer></v-spacer>

        <v-btn 
          color="primary" 
          @click="abrirModalCrear" 
          prepend-icon="mdi-plus"
          class="mr-2"
        >
          Nuevo Producto
        </v-btn>
        <v-btn 
          variant="outlined" 
          @click="getProductos" 
          prepend-icon="mdi-refresh"
        >
          Actualizar
        </v-btn>
      </v-toolbar>

      <v-table fixed-header hover density="compact">
        <thead>
          <tr>
            <th class="text-left">#</th>
            <th class="text-left">Descripción</th>
            <th class="text-left">Color</th>
            <th class="text-left">Precio Venta</th>
            <th class="text-left">Activo</th>
            <th class="text-center">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(producto, index) in productos" :key="producto.cod_producto">
            <td>{{ index + 1 }}</td>
            <td>{{ producto.descripcion_producto }}</td>
            <td>
              <v-chip
                :color="producto.color_hex || '#ccc'"
                size="small"
                label
                :text-color="producto.color_hex ? 'white' : 'black'"
                variant="flat"
                style="min-width: 100px;"
              >
                {{ producto.color_nombre }}
              </v-chip>
            </td>
            <td>Bs. {{ producto.precio_venta_producto }}</td>
            <td>
              <v-chip
                :color="producto.activo ? 'green' : 'red'"
                size="small"
                variant="flat"
                label
              >
                {{ producto.activo ? 'Sí (Activo)' : 'No (Inactivo)' }}
              </v-chip>
            </td>
            <td class="text-center">
              <v-tooltip text="Editar Producto">
                <template v-slot:activator="{ props }">
                  <v-btn 
                    v-bind="props"
                    icon="mdi-pencil" 
                    variant="text" 
                    color="yellow-darken-2" 
                    size="small" 
                    @click="editarProducto(producto)"
                  ></v-btn>
                </template>
              </v-tooltip>
              
              <v-tooltip :text="producto.activo ? 'Desactivar' : 'Activar'">
                <template v-slot:activator="{ props }">
                  <v-btn
                    v-bind="props"
                    :icon="producto.activo ? 'mdi-toggle-switch-off' : 'mdi-toggle-switch'"
                    variant="text"
                    :color="producto.activo ? 'red-lighten-1' : 'green-lighten-1'"
                    size="small"
                    @click="cambiarEstado(producto.cod_producto, !producto.activo)"
                  ></v-btn>
                </template>
              </v-tooltip>
            </td>
          </tr>
        </tbody>
      </v-table>
    </v-card>

    <v-dialog v-model="showModal" max-width="1000px" persistent>
      <v-card>
        <v-card-title class="text-h5 pa-4 bg-grey-lighten-3">
          {{ editId ? 'Editar Producto' : 'Registrar Producto' }}
        </v-card-title>

        <v-card-text class="pt-4">
          <v-container>
            <v-row>
              <v-col cols="12" md="4">
                <v-autocomplete
                  ref="categoriaAutoComplete"
                  v-model="formProducto.cod_categoria"
                  :items="categoriaOptions"
                  item-title="label"
                  item-value="value"
                  label="Categoría"
                  variant="outlined"
                  density="compact"
                  @update:modelValue="actualizarDescripcion"
                ></v-autocomplete>
              </v-col>

              <v-col cols="12" md="4">
                <v-autocomplete
                  v-model="formProducto.proveedor_producto"
                  :items="proveedorOptions"
                  item-title="label"
                  item-value="value"
                  label="Proveedor / Marca"
                  variant="outlined"
                  density="compact"
                  @update:modelValue="actualizarDescripcion"
                ></v-autocomplete>
              </v-col>

              <v-col cols="12" md="4">
                <v-autocomplete
                  v-model="formProducto.material_producto"
                  :items="materialOptions"
                  item-title="label"
                  item-value="value"
                  label="Material"
                  variant="outlined"
                  density="compact"
                  @update:modelValue="actualizarDescripcion"
                ></v-autocomplete>
              </v-col>

              <v-col cols="12" md="4">
                <v-autocomplete
                  v-model="formProducto.modelo_producto"
                  :items="modeloOptions"
                  item-title="label"
                  item-value="value"
                  label="Modelo"
                  variant="outlined"
                  density="compact"
                  @update:modelValue="actualizarDescripcion"
                ></v-autocomplete>
              </v-col>

              <v-col cols="12" md="4">
                <v-autocomplete
                  v-model="formProducto.color_producto"
                  :items="colorOptions"
                  item-title="label"
                  item-value="value"
                  label="Color"
                  variant="outlined"
                  density="compact"
                  @update:modelValue="actualizarDescripcion"
                ></v-autocomplete>
              </v-col>

              <v-col cols="12" md="4">
                <v-select
                  v-model="formProducto.genero_producto"
                  :items="['UNISEX', 'MASCULINO', 'FEMENINO']"
                  label="Género"
                  variant="outlined"
                  density="compact"
                  @update:modelValue="actualizarDescripcion"
                ></v-select>
              </v-col>
              
              <v-col cols="12">
                <v-text-field
                  v-model="formProducto.descripcion_producto"
                  label="Descripción (Generada automáticamente)"
                  variant="outlined"
                  density="compact"
                  hint="La descripción se genera automáticamente, pero puedes editarla"
                  persistent-hint
                ></v-text-field>
              </v-col>

              <v-col cols="12" md="3">
                <v-text-field
                  v-model="formProducto.precio_compra_producto"
                  label="Precio Compra"
                  type="number"
                  step="0.01"
                  prefix="Bs."
                  variant="outlined"
                  density="compact"
                ></v-text-field>
              </v-col>

              <v-col cols="12" md="3">
                <v-text-field
                  v-model="formProducto.precio_venta_producto"
                  label="Precio Venta"
                  type="number"
                  step="0.01"
                  prefix="Bs."
                  variant="outlined"
                  density="compact"
                ></v-text-field>
              </v-col>

              <v-col cols="12" md="3">
                <v-text-field
                  v-model="formProducto.stock_minimo_producto"
                  label="Stock Mínimo"
                  type="number"
                  variant="outlined"
                  density="compact"
                ></v-text-field>
              </v-col>
              
              <v-col cols="12" md="3">
                 <v-select
                  v-model="formProducto.activo"
                  :items="[{title: 'Activo', value: true}, {title: 'Inactivo', value: false}]"
                  label="Estado"
                  variant="outlined"
                  density="compact"
                ></v-select>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>

        <v-card-actions class="pa-4 bg-grey-lighten-3">
          <v-spacer></v-spacer>
          <v-btn color="grey-darken-1" variant="text" @click="cerrarModal">Cancelar</v-btn>
          <v-btn color="blue-darken-1" variant="flat" @click="guardarProducto">Guardar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

  </v-container>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, computed } from "vue";
import { supabase } from "../lib/supabaseClient.js";
// Ya no importamos BaseModal ni AutoComplete

// --- ESTADO GENERAL ---
const productos = ref([]);
const categorias = ref([]);
const proveedores = ref([]);
const materiales = ref([]);
const modelos = ref([]);
const colores = ref([]);
const showModal = ref(false); // Controla el v-dialog
const editId = ref(null);

// Ref para el v-autocomplete
const categoriaAutoComplete = ref(null);

// --- FORMULARIO DEL PRODUCTO ---
// (Sin cambios, la lógica de estado es la misma)
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
// (Sin cambios, v-autocomplete las consume igual)
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
// (Sin cambios, la lógica de Supabase es la misma)
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
// (Sin cambios, la lógica de negocio es la misma)
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
    // v-autocomplete también expone el método focus()
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
/* ¡CASI NO SE NECESITA CSS!
  Vuetify maneja el 99% del estilo. 
  Solo ajustamos el título del v-card-title para que
  no tenga tanto margen inferior por defecto.
*/
.v-card-title {
  margin-bottom: 0 !important;
}

/* Aseguramos que la tabla sea responsive en móviles,
  aunque v-table no es tan "responsive" como v-data-table.
  Para una mejor experiencia móvil, se usaría v-data-table.
*/
@media (max-width: 768px) {
  .v-table {
    display: block;
    overflow-x: auto;
    white-space: nowrap;
  }
}
</style>