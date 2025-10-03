<template>
  <div class="panel-container">
    <header v-if="cliente" class="panel-header">
      <div>
        <h2>{{ cliente.nombre_cliente }} {{ cliente.apellido_paterno_cliente }}</h2>
        <p class="cliente-info">
          <span>Teléfono: {{ cliente.telefono_cliente || 'N/A' }}</span>
        </p>
      </div>
      <button @click="volver" class="btn btn-secondary">Volver a la lista</button>
    </header>
    <div v-else class="loading">Cargando datos del cliente...</div>
    <div class="elegant-divider"></div>

    <div class="seccion-prescripciones">
      <div class="seccion-header">
        <h2>Historial de Prescripciones</h2>
        <div class="header-actions-group">
          <button @click="abrirModalFormularioParaCrear" class="btn btn-primary"> + Nueva Prescripción </button>
        </div>
      </div>

      <div v-if="cargandoPrescripciones" class="loading">Cargando prescripciones...</div>
      <div v-else-if="prescripcionesCliente.length > 0" class="prescripcion-grid">
        <div v-for="prescripcion in prescripcionesCliente" :key="prescripcion.cod_prescripcion"
          class="prescripcion-card clickable" @click="abrirModalDetalles(prescripcion)"
          title="Clic para ver detalles completos">
          <div class="card-header">
            <h4>Receta: {{ prescripcion.cod_receta || 'S/C' }}</h4>
            <span class="card-date">{{ formatearFecha(prescripcion.fecha_prescripcion) }}</span>
          </div>
          <div class="card-body">
            <p class="card-info-item">
              <strong>Nro. Sobre:</strong>
              <span>{{ prescripcion.num_sobre }}</span>
            </p>
            <p class="card-info-item">
              <strong>Pedidos:</strong>
              <span>{{ [prescripcion.cod_pedido1, prescripcion.cod_pedido2].filter(p => p).join(', ') || '-' }}</span>
            </p>
            <p v-if="prescripcion.notas_adicionales && prescripcion.notas_adicionales !== '-'" class="card-obs">
              {{ prescripcion.notas_adicionales }}
            </p>
          </div>
          <div class="card-actions" @click.stop>
            <button @click="abrirModalFormularioParaEditar(prescripcion)" class="btn-action btn-edit" title="Editar">✏️ Editar</button>
            <button @click="eliminarPrescripcion(prescripcion.cod_prescripcion)" class="btn-action btn-delete" title="Eliminar">🗑️ Eliminar</button>
          </div>
        </div>
      </div>
      <div v-else class="sin-resultados"><p>Este cliente aún no tiene prescripciones registradas.</p></div>
    </div>
    
    <BaseModal v-model="mostrarModalFormulario" :title="tituloModalFormulario" size="xl">
      <form @submit.prevent="guardarPrescripcion" class="form-container">
        <div class="form-grid-4-col">
          <div class="form-group"><input :value="clienteNombreCompleto" readonly class="form-input campo-readonly" /></div>
          <div class="form-group"><input ref="recetaInputRef" v-model="formData.cod_receta" placeholder="Cód. Receta Ej. 1234-A" class="form-input" /></div>
          <div class="form-group"><input v-model="formData.fecha_prescripcion" type="date" class="form-input" /></div>
          <div class="form-group">
            <AutoComplete v-model="formData.doctor_prescriptor" :options="doctoresOptions" placeholder="Doctor Prescriptor" />
          </div>
        </div>

        <div class="medidas-grid-container">
          <div class="medida-columna">
            <div class="medida-header">Lente 1</div>
            <div class="tipo-dip-grupo">
              <div class="form-group"><AutoComplete v-model="formData.distancia_lente1" :options="tipoLenteDistanciaOptions" placeholder="DISTANCIA" /></div>
              <div class="form-group"><input v-model="formData.l1_dip" class="form-input" placeholder="DIP" /></div>
            </div>
            <div class="ojos-fila">
              <div class="ojo-grupo">
                <label class="ojo-label">OD</label>
                <input v-model="formData.l1_esf_od" placeholder="ESF" class="form-input" />
                <input v-model="formData.l1_cil_od" placeholder="CIL" class="form-input" />
                <input v-model="formData.l1_eje_od" placeholder="EJE" class="form-input" />
              </div>
              <div class="ojo-grupo">
                <label class="ojo-label">OI</label>
                <input v-model="formData.l1_esf_oi" placeholder="ESF" class="form-input" />
                <input v-model="formData.l1_cil_oi" placeholder="CIL" class="form-input" />
                <input v-model="formData.l1_eje_oi" placeholder="EJE" class="form-input" />
              </div>
            </div>
          </div>
          <div class="medida-columna">
            <div class="medida-header">Lente 2</div>
            <div class="tipo-dip-grupo">
              <div class="form-group"><AutoComplete v-model="formData.distancia_lente2" :options="tipoLenteDistanciaOptions" placeholder="DISTANCIA" /></div>
              <div class="form-group"><input v-model="formData.l2_dip" class="form-input" placeholder="DIP" /></div>
            </div>
            <div class="ojos-fila">
              <div class="ojo-grupo">
                <label class="ojo-label">OD</label>
                <input v-model="formData.l2_esf_od" placeholder="ESF" class="form-input" />
                <input v-model="formData.l2_cil_od" placeholder="CIL" class="form-input" />
                <input v-model="formData.l2_eje_od" placeholder="EJE" class="form-input" />
              </div>
              <div class="ojo-grupo">
                <label class="ojo-label">OI</label>
                <input v-model="formData.l2_esf_oi" placeholder="ESF" class="form-input" />
                <input v-model="formData.l2_cil_oi" placeholder="CIL" class="form-input" />
                <input v-model="formData.l2_eje_oi" placeholder="EJE" class="form-input" />
              </div>
            </div>
          </div>
        </div>

        <div class="cristales-grid-container">
            <label class="cristal-row-label">Cristal 1:</label>
            <div class="form-group"><input v-model.number="formData.l1_cantidad_cristal" type="number" min="0" class="form-input" /></div>
            <div class="form-group"><AutoComplete v-model="formData.l1_material_cristal" :options="materialesOptions" placeholder="Material" /></div>
            <div class="form-group"><AutoComplete v-model="formData.l1_tipo_lente" :options="tiposLenteOptions" placeholder="Tipo"/></div>
            <div class="form-group"><MultiSelect v-model="formData.l1_tratamientos" :options="tratamientosOptions" placeholder="Tratamientos" /></div>
            <div class="form-group"><AutoComplete v-model="formData.l1_color_cristal" :options="coloresOptions" placeholder="Color"/></div>
            <div class="form-group"><input v-model="formData.l1_extra_cristal" class="form-input" placeholder="Nota Adicional"/></div>
            
            <label class="cristal-row-label">Cristal 2:</label>
            <div class="form-group"><input v-model.number="formData.l2_cantidad_cristal" type="number" min="0" class="form-input" /></div>
            <div class="form-group"><AutoComplete v-model="formData.l2_material_cristal" :options="materialesOptions" placeholder="Material"/></div>
            <div class="form-group"><AutoComplete v-model="formData.l2_tipo_lente" :options="tiposLenteOptions" placeholder="Tipo" /></div>
            <div class="form-group"><MultiSelect v-model="formData.l2_tratamientos" :options="tratamientosOptions" placeholder="Tratamientos"/></div>
            <div class="form-group"><AutoComplete v-model="formData.l2_color_cristal" :options="coloresOptions" placeholder="Color"/></div>
            <div class="form-group"><input v-model="formData.l2_extra_cristal" class="form-input" placeholder="Nota Adicional"/></div>
        </div>

        <div class="form-grid-5-col">
          <div class="form-group"><AutoComplete v-model="formData.cod_proveedor" :options="proveedoresOptions" placeholder="Proveedor" /></div>
          <div class="form-group"><AutoComplete v-model="formData.cod_armador" :options="armadoresOptions" placeholder="Armador" /></div>
          <div class="form-group"><input v-model="formData.fecha_entrega" type="date" class="form-input" placeholder="Fecha entrega"/></div>
          <div class="form-group"><AutoComplete v-model="formData.cod_armazon" :options="armazonesOptions" placeholder="Armazón"/></div>
          <div class="form-group"><input v-model="formData.num_sobre" type="text" class="form-input" placeholder="Núm. Sobre"/></div>
          <div class="form-group"><input v-model="formData.cod_pedido1" class="form-input" placeholder="Núm. Pedido 1" /></div>
          <div class="form-group"><input v-model="formData.cod_pedido2" class="form-input" placeholder="Núm. Pedido 2"/></div>
        </div>

        <div class="form-group"><textarea v-model="formData.notas_adicionales" rows="2" class="form-input" placeholder="Observaciones o notas adicionales"></textarea></div>
      </form>
      <template #footer>
        <button @click="mostrarModalFormulario = false" class="btn-cancelar">Cancelar</button>
        <button @click="guardarPrescripcion" class="btn-guardar">{{ editId ? 'Actualizar' : 'Guardar' }}</button>
      </template>
    </BaseModal>
    
    </div>
</template>

<script setup>
import { ref, onMounted, reactive, computed, nextTick } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { supabase } from '../lib/supabaseClient';
import BaseModal from './BaseModal.vue';
import AutoComplete from './Autocomplete.vue';
import MultiSelect from './MultiSelect.vue';

const route = useRoute();
const router = useRouter();
const clienteId = ref(route.params.id);

// --- ESTADO PRINCIPAL ---
const cliente = ref(null);
const prescripcionesCliente = ref([]);
const cargandoPrescripciones = ref(false);
const editId = ref(null);

// --- ESTADO DE LA UI ---
const mostrarModalFormulario = ref(false);
const recetaInputRef = ref(null);

// --- DATOS PARA SELECTS/AUTOCOMPLETES ---
const doctores = ref([]);
const materiales = ref([]);
const colores = ref([]);
const tiposLente = ref([]);
const tratamientos = ref([]);
const proveedores = ref([]);
const armadores = ref([]);
const armazones = ref([]);

// --- MODELO DE DATOS DEL FORMULARIO ---
const getInitialFormData = () => ({
  cod_prescripcion: null,
  cod_cliente: parseInt(clienteId.value),
  cod_receta: '',
  fecha_prescripcion: new Date().toISOString().split('T')[0],
  doctor_prescriptor: null,

  distancia_lente1: 'LEJOS',
  l1_dip: '', l1_esf_od: '', l1_cil_od: '', l1_eje_od: '',
  l1_esf_oi: '', l1_cil_oi: '', l1_eje_oi: '',

  distancia_lente2: 'CERCA',
  l2_dip: '', l2_esf_od: '', l2_cil_od: '', l2_eje_od: '',
  l2_esf_oi: '', l2_cil_oi: '', l2_eje_oi: '',

  l1_cantidad_cristal: 2, l1_material_cristal: null, l1_tipo_lente: null,
  l1_color_cristal: null, l1_extra_cristal: '', l1_tratamientos: [],

  l2_cantidad_cristal: 0, l2_material_cristal: null, l2_tipo_lente: null,
  l2_color_cristal: null, l2_extra_cristal: '', l2_tratamientos: [],

  cod_proveedor: null, cod_armador: null, cod_armazon: null,
  fecha_entrega: new Date().toISOString().split('T')[0],
  
  // CORRECCIÓN: Inicializar como STRING ya que los campos ahora son VARCHAR en la DB
  num_sobre: '', 
  cod_pedido1: '', 
  cod_pedido2: '', 
  
  notas_adicionales: '',
});

const formData = reactive(getInitialFormData());

// --- PROPIEDADES COMPUTADAS Y OPCIONES (se mantienen igual) ---
const tituloModalFormulario = computed(() => editId.value ? 'Editar Prescripción' : 'Registrar Nueva Prescripción');
const clienteNombreCompleto = computed(() => cliente.value ? `${cliente.value.nombre_cliente} ${cliente.value.apellido_paterno_cliente}`.trim() : '');

const doctoresOptions = computed(() => doctores.value.map(d => ({ value: d.cod_doctor, label: d.nombre_doctor })));
const materialesOptions = computed(() => materiales.value.map(m => ({ value: m.cod_material_cristal, label: m.nombre_material })));
const coloresOptions = computed(() => colores.value.map(c => ({ value: c.cod_color_cristal, label: c.nombre_color })));
const tiposLenteOptions = computed(() => tiposLente.value.map(t => ({ value: t.id_tipo_lente, label: t.nombre_tipo_lente })));
const tratamientosOptions = computed(() => tratamientos.value.map(t => ({ value: t.cod_tratamiento, label: t.nombre_tratamiento })));
const proveedoresOptions = computed(() => proveedores.value.map(p => ({ value: p.cod_proveedor, label: p.nombre_proveedor })));
const armadoresOptions = computed(() => armadores.value.map(a => ({ value: a.cod_armador, label: a.nombre_armador })));
const armazonesOptions = computed(() => armazones.value.map(a => ({ value: a.cod_armazon, label: a.nombre_armazon })));
const tipoLenteDistanciaOptions = ref([{ value: 'LEJOS', label: 'LEJOS' }, { value: 'CERCA', label: 'CERCA' }, { value: 'PROGRESIVO', label: 'PROGRESIVO' }, { value: 'BIFOCAL', label: 'BIFOCAL' }, { value: 'INTERMEDIO', label: 'INTERMEDIO' }]);

onMounted(async () => {
  await inicializarPanel();
});

async function inicializarPanel() {
  cargandoPrescripciones.value = true;
  try {
    const [clienteRes, prescripcionesRes, ...formSelectsRes] = await Promise.all([
      supabase.from('clientes').select('*').eq('cod_cliente', clienteId.value).single(),
      // Usar la tabla corregida 'prescripcion_clienten'
      supabase.from('prescripcion_clienten').select(`*`).eq('cod_cliente', clienteId.value).order('fecha_prescripcion', { ascending: false }),
      supabase.from('doctores').select('*'),
      supabase.from('material_cristal').select('*'),
      supabase.from('color_cristal').select('*'),
      supabase.from('tipo_lente').select('*'),
      supabase.from('tratamientos').select('*'),
      supabase.from('proveedores').select('*'),
      supabase.from('armador_lente').select('*'),
      supabase.from('armazon_lente').select('*')
    ]);

    cliente.value = clienteRes.data;
    prescripcionesCliente.value = prescripcionesRes.data || [];
    
    [doctores.value, materiales.value, colores.value, tiposLente.value, tratamientos.value, proveedores.value, armadores.value, armazones.value] = formSelectsRes.map(res => res.data || []);

  } catch (error) {
    console.error("Error detallado al inicializar:", error);
    alert("Error al inicializar el panel: " + error.message);
  } finally {
    cargandoPrescripciones.value = false;
  }
}

async function recargarPrescripciones() {
    cargandoPrescripciones.value = true;
    try {
        // Usar la tabla corregida 'prescripcion_clienten'
        const { data, error } = await supabase.from('prescripcion_clienten').select(`*`).eq('cod_cliente', clienteId.value).order('fecha_prescripcion', { ascending: false });
        if (error) throw error;
        prescripcionesCliente.value = data || [];
    } catch (error) {
        alert('Error al recargar prescripciones: ' + error.message);
    } finally {
        cargandoPrescripciones.value = false;
    }
}

async function guardarPrescripcion() {
  try {
    // Separa las propiedades de tratamiento que no van a la tabla principal
    const { l1_tratamientos, l2_tratamientos, ...prescripcionBaseData } = formData;
    
    let prescripcionData = { ...prescripcionBaseData };

    // Si NO hay editId, elimina 'cod_prescripcion' para autogeneración (ya corregido antes)
    if (!editId.value) {
        delete prescripcionData.cod_prescripcion;
    }

    // Se mantiene la verificación del doctor prescriptor si es NOT NULL en la DB
    if (!prescripcionData.doctor_prescriptor) {
        alert('El campo "Doctor Prescriptor" es obligatorio.');
        return;
    }
    
    const { data: prescripcionGuardada, error } = await supabase
      .from('prescripcion_clienten')
      .upsert(prescripcionData) 
      .select()
      .single();

    if (error) throw error;
    if (!prescripcionGuardada) throw new Error("No se recibió respuesta de la base de datos tras guardar.");

    const nuevaPrescripcionId = prescripcionGuardada.cod_prescripcion;

    // Manejo de tratamientos (se mantiene igual)
    await supabase.from('prescripcion_tratamiento').delete().eq('cod_prescripcion', nuevaPrescripcionId);

    const tratamientosParaInsertar = [];
    (l1_tratamientos || []).forEach(tratId => {
      tratamientosParaInsertar.push({ cod_prescripcion: nuevaPrescripcionId, cod_tratamiento: tratId, numero_lente: 1 });
    });
    (l2_tratamientos || []).forEach(tratId => {
      tratamientosParaInsertar.push({ cod_prescripcion: nuevaPrescripcionId, cod_tratamiento: tratId, numero_lente: 2 });
    });

    if (tratamientosParaInsertar.length > 0) {
      const { error: errorTratamientos } = await supabase.from('prescripcion_tratamiento').insert(tratamientosParaInsertar);
      if (errorTratamientos) throw errorTratamientos;
    }

    alert(editId.value ? 'Prescripción actualizada con éxito.' : 'Prescripción guardada con éxito.');
    mostrarModalFormulario.value = false;
    await recargarPrescripciones();
  } catch (error) {
    console.error("Error detallado al guardar:", error); 
    alert('Error al guardar la prescripción: ' + error.message);
  }
}

async function eliminarPrescripcion(id) {
  if (!confirm('¿Está seguro de eliminar esta prescripción? Esta acción no se puede deshacer.')) return;
  try {
    // Usar la tabla corregida 'prescripcion_clienten'
    const { error } = await supabase.from('prescripcion_clienten').delete().eq('cod_prescripcion', id);
    if (error) throw error;
    alert('Prescripción eliminada.');
    await recargarPrescripciones();
  } catch (error) {
    alert('Error al eliminar: ' + error.message);
  }
}

function abrirModalFormularioParaCrear() {
  editId.value = null;
  Object.assign(formData, getInitialFormData());
  mostrarModalFormulario.value = true;
  nextTick(() => recetaInputRef.value?.focus());
}

async function abrirModalFormularioParaEditar(prescripcion) {
  editId.value = prescripcion.cod_prescripcion;
  
  const { data: tratamientosData, error } = await supabase
    .from('prescripcion_tratamiento')
    .select('cod_tratamiento, numero_lente')
    .eq('cod_prescripcion', prescripcion.cod_prescripcion);

  if (error) {
    alert("Error al cargar los tratamientos: " + error.message);
    return;
  }

  const l1_tratamientos = tratamientosData?.filter(t => t.numero_lente === 1).map(t => t.cod_tratamiento) || [];
  const l2_tratamientos = tratamientosData?.filter(t => t.numero_lente === 2).map(t => t.cod_tratamiento) || [];

  Object.assign(formData, { ...prescripcion, l1_tratamientos, l2_tratamientos });

  mostrarModalFormulario.value = true;
  nextTick(() => recetaInputRef.value?.focus());
}

const formatearFecha = (fecha) => fecha ? new Date(fecha + 'T00:00:00Z').toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'UTC' }) : '';
function volver() { router.push({ name: 'GestionClientes' }); }

</script>

<style scoped>
/* (Los estilos del componente anterior son compatibles y se pueden mantener aquí) */
/* ESTILOS GENERALES Y DE PANEL */
.panel-container { padding: 24px; }
.panel-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem; }
.cliente-info { color: #6c757d; font-size: 14px; }
.loading, .sin-resultados { text-align: center; padding: 2rem; color: #6c757d; font-size: 1.1rem; }
.elegant-divider { width: 100%; height: 1px; background-color: #dee2e6; margin: 24px 0; }
.seccion-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 1rem; }
.header-actions-group { display: flex; gap: 10px; }
.sub-header { margin-top: 2rem; margin-bottom: 1rem; color: #495057; font-weight: 500; }

/* ESTILOS DE BOTONES */
.btn-primary, .btn-secondary, .btn-success, .btn-guardar, .btn-cancelar { color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-size: 14px; }
.btn-primary { background: #007bff; } .btn-primary:hover { background: #0056b3; }
.btn-secondary { background: #6c757d; } .btn-secondary:hover { background: #5a6268; }
.btn-success { background: #28a745; } .btn-success:hover { background: #218838; }
.btn-guardar { background: #007bff; }
.btn-cancelar { background: #6c757d; }

/* ESTILOS DE TARJETAS */
.prescripcion-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem; }
.prescripcion-card { background-color: #fff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.08); border: 1px solid #e9ecef; display: flex; flex-direction: column; }
.clickable { cursor: pointer; transition: transform 0.2s ease, box-shadow 0.2s ease; }
.clickable:hover { transform: translateY(-4px); box-shadow: 0 6px 12px rgba(0,0,0,0.1); }
.card-header { display: flex; justify-content: space-between; align-items: center; padding: 0.75rem 1rem; background-color: #f8f9fa; border-bottom: 1px solid #e9ecef; }
.card-header h4 { margin: 0; font-size: 1rem; }
.card-date { font-size: 0.8rem; color: #6c757d; background-color: #e9ecef; padding: 3px 8px; border-radius: 12px; }
.card-body { padding: 1rem; flex-grow: 1; }
.card-info-item { margin: 0 0 0.5rem 0; font-size: 0.9rem; }
.card-obs { font-size: 0.85rem; color: #6c757d; margin-top: 1rem; overflow: hidden; text-overflow: ellipsis }
.card-actions { display: flex; justify-content: flex-end; gap: 0.5rem; padding: 0.5rem 1rem; border-top: 1px solid #e9ecef; }
.btn-action { padding: 5px 12px; font-size: 0.8rem; border-radius: 5px; cursor: pointer; background: none; border: none; }
.btn-action.btn-edit { color: #007bff; } .btn-action.btn-edit:hover { background-color: #e7f3ff; }
.btn-action.btn-delete { color: #dc3545; } .btn-action.btn-delete:hover { background-color: #f8d7da; }

/* ESTILOS DE FORMULARIOS */
.form-container, .details-view-container { display: flex; flex-direction: column; gap: 1rem; }
.form-group { display: flex; flex-direction: column; gap: 4px; }
.form-input, .form-group textarea { padding: 8px 12px; border: 1px solid #ced4da; border-radius: 4px; width: 100%; box-sizing: border-box; font-size: 14px; }
.form-input:focus-within, .form-group textarea:focus-within { border-color: #80bdff; box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25); }
.campo-readonly { background-color: #e9ecef; cursor: not-allowed; }

/* ESTRUCTURA DE GRID PARA FORMULARIO */
.form-grid-4-col { display: grid; grid-template-columns: 350px 1fr .7fr 1.1fr; gap: .5rem; }
.form-grid-5-col { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr; gap: .5rem; }
.medidas-grid-container { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; background-color: #f8f9fa; padding: .5rem; border-radius: 8px; border: 1px solid #e9ecef; }
.medida-columna { display: flex; flex-direction: column; gap: 1rem; }
.medida-header { font-weight: 600; color: #495057; padding-bottom: 0.5rem; margin-bottom: 0.5rem; border-bottom: 1px solid #dee2e6; }
.tipo-dip-grupo { display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; }
.ojos-fila { display: flex; flex-direction: column; gap: 0.5rem; }
.ojo-grupo { display: grid; grid-template-columns: 30px 1fr 1fr 1fr; gap: 0.5rem; align-items: center; }
.ojo-label { font-weight: bold; font-size: 1rem; text-align: center; }
.cristales-grid-container { display: grid; grid-template-columns: 80px 80px 1fr 1fr 1.5fr 1fr 1fr; gap: 0.5rem .5rem; align-items: center; }
.cristal-row-label { font-size: 0.9rem; font-weight: 600; text-align: right; }
</style>