<template>
  <div class="form-page-container">
    <header class="form-page-header">
      <h2>{{ pageTitle }}</h2>
    </header>

    <form @submit.prevent="guardarPrescripcion" class="form-container" v-if="!cargando">
      <div class="form-grid-4-col">
        <div><strong>Cliente:</strong></div>
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
            <div class="medidas-layout">
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
          </div>
          <div class="medida-columna">
            <div class="medida-header">Lente 2</div>
             <div class="medidas-layout">
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
        </div>

        <div class="cristales-grid-container">
            <label class="cristal-row-label">Cristal 1:</label>
            <div class="form-group"><input v-model.number="formData.l1_cantidad_cristal" type="number" min="0" class="form-input" /></div>
            <div class="form-group"><AutoComplete v-model="formData.l1_material_cristal" :options="materialesOptions" placeholder="Material" /></div>
            <div class="form-group"><TratamientoSelector v-model="formData.l1_tratamientos" :options="tratamientosOptions" placeholder="Tratamientos" /></div>
            <div class="form-group"><AutoComplete v-model="formData.l1_color_cristal" :options="coloresOptions" placeholder="Color"/></div>
            <div class="form-group"><input v-model="formData.l1_extra_cristal" class="form-input" placeholder="Extras"/></div>
            
            <label class="cristal-row-label">Cristal 2:</label>
            <div class="form-group"><input v-model.number="formData.l2_cantidad_cristal" type="number" min="0" class="form-input" /></div>
            <div class="form-group"><AutoComplete v-model="formData.l2_material_cristal" :options="materialesOptions" placeholder="Material"/></div>
            <div class="form-group"><TratamientoSelector v-model="formData.l2_tratamientos" :options="tratamientosOptions" placeholder="Tratamientos"/></div>
            <div class="form-group"><AutoComplete v-model="formData.l2_color_cristal" :options="coloresOptions" placeholder="Color"/></div>
            <div class="form-group"><input v-model="formData.l2_extra_cristal" class="form-input" placeholder="Extras"/></div>
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

      <div class="form-group">
        <textarea v-model="formData.notas_adicionales" rows="2" class="form-input" placeholder="Observaciones o notas adicionales"></textarea>
      </div>

      <div class="form-footer">
        <button type="button" @click="cancelar" class="btn-cancelar">Cancelar</button>
        <button type="submit" class="btn-guardar">{{ isEditing ? 'Actualizar Prescripción' : 'Guardar Prescripción' }}</button>
      </div>
    </form>
     <div v-else class="loading">Cargando datos...</div>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive, computed, nextTick } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from '../lib/supabaseClient';
import AutoComplete from './Autocomplete.vue';
import TratamientoSelector from './TratamientoSelector.vue';

const props = defineProps({
  clienteId: { type: String, required: true },
  prescripcionId: { type: String, default: null }
});

const router = useRouter();
const isEditing = computed(() => !!props.prescripcionId);

// --- ESTADO ---
const cargando = ref(true);
const cliente = ref(null);
const recetaInputRef = ref(null);

// --- DATOS PARA SELECTS/AUTOCOMPLETES ---
const doctores = ref([]);
const materiales = ref([]);
const colores = ref([]);
const tratamientos = ref([]);
const proveedores = ref([]);
const armadores = ref([]);
const armazones = ref([]);

const getInitialFormData = () => ({
  cod_prescripcion: null,
  cod_cliente: parseInt(props.clienteId),
  cod_receta: '',
  fecha_prescripcion: new Date().toISOString().split('T')[0],
  doctor_prescriptor: null,
  distancia_lente1: 'LEJOS', l1_dip: '', l1_esf_od: '', l1_cil_od: '', l1_eje_od: '', l1_esf_oi: '', l1_cil_oi: '', l1_eje_oi: '',
  distancia_lente2: '', l2_dip: '', l2_esf_od: '', l2_cil_od: '', l2_eje_od: '', l2_esf_oi: '', l2_cil_oi: '', l2_eje_oi: '',
  l1_cantidad_cristal: 2, l1_material_cristal: null, l1_color_cristal: null, l1_extra_cristal: '', l1_tratamientos: [],
  l2_cantidad_cristal: 2, l2_material_cristal: null, l2_color_cristal: null, l2_extra_cristal: '', l2_tratamientos: [],
  cod_proveedor: null, cod_armador: null, cod_armazon: null,
  fecha_entrega: new Date().toISOString().split('T')[0],
  num_sobre: '', cod_pedido1: '', cod_pedido2: '', 
  notas_adicionales: '',
});

const formData = reactive(getInitialFormData());

// --- PROPIEDADES COMPUTADAS ---
const pageTitle = computed(() => isEditing.value ? 'Editar Prescripción' : 'Registrar Nueva Prescripción');
const clienteNombreCompleto = computed(() => cliente.value ? `${cliente.value.nombre_cliente} ${cliente.value.apellido_paterno_cliente}`.trim() : '');

const doctoresOptions = computed(() => doctores.value.map(d => ({ value: d.cod_doctor, label: d.nombre_doctor })));
const materialesOptions = computed(() => materiales.value.map(m => ({ value: m.cod_material_cristal, label: m.nombre_material })));
const coloresOptions = computed(() => colores.value.map(c => ({ value: c.cod_color_cristal, label: c.nombre_color })));
const tratamientosOptions = computed(() => tratamientos.value.map(t => ({ value: t.cod_tratamiento, label: t.nombre_tratamiento })));
const proveedoresOptions = computed(() => proveedores.value.map(p => ({ value: p.cod_proveedor, label: p.nombre_proveedor })));
const armadoresOptions = computed(() => armadores.value.map(a => ({ value: a.cod_armador, label: a.nombre_armador })));
const armazonesOptions = computed(() => armazones.value.map(a => ({ value: a.cod_armazon, label: a.nombre_armazon })));
const tipoLenteDistanciaOptions = ref([{ value: 'LEJOS', label: 'LEJOS' }, { value: 'CERCA', label: 'CERCA' }, { value: 'PROGRESIVO', label: 'PROGRESIVO' }, { value: 'BIFOCAL', label: 'BIFOCAL' }, { value: 'INTERMEDIO', label: 'INTERMEDIO' }]);

onMounted(async () => {
  await inicializarFormulario();
  nextTick(() => recetaInputRef.value?.focus());
});

async function inicializarFormulario() {
  cargando.value = true;
  try {
    const promises = [
      supabase.from('clientes').select('*').eq('cod_cliente', props.clienteId).single(),
      supabase.from('doctores').select('*'),
      supabase.from('material_cristal').select('*'),
      supabase.from('color_cristal').select('*'),
      supabase.from('tratamientos').select('*'),
      supabase.from('proveedores').select('*'),
      supabase.from('armador_lente').select('*'),
      supabase.from('armazon_lente').select('*')
    ];

    if (isEditing.value) {
      promises.push(supabase.from('prescripcion_clienten').select('*').eq('cod_prescripcion', props.prescripcionId).single());
      promises.push(supabase.from('prescripcion_tratamiento').select('cod_tratamiento, numero_lente').eq('cod_prescripcion', props.prescripcionId));
    }
    
    const [clienteRes, ...formSelectsAndData] = await Promise.all(promises);

    cliente.value = clienteRes.data;
    [doctores.value, materiales.value, colores.value, tratamientos.value, proveedores.value, armadores.value, armazones.value] = formSelectsAndData.slice(0, 7).map(res => res.data || []);
    
    if (isEditing.value) {
      const prescripcionRes = formSelectsAndData[7];
      const tratamientosRes = formSelectsAndData[8];
      const l1_tratamientos = tratamientosRes.data?.filter(t => t.numero_lente === 1).map(t => t.cod_tratamiento) || [];
      const l2_tratamientos = tratamientosRes.data?.filter(t => t.numero_lente === 2).map(t => t.cod_tratamiento) || [];
      Object.assign(formData, { ...prescripcionRes.data, l1_tratamientos, l2_tratamientos });
    }

  } catch (error) {
    console.error("Error al inicializar el formulario:", error);
    alert("Error al cargar los datos: " + error.message);
  } finally {
    cargando.value = false;
  }
}

async function guardarPrescripcion() {
  if (!formData.cod_receta || !formData.cod_receta.trim()) {
    alert('El campo "Cód. Receta" es obligatorio.');
    recetaInputRef.value?.focus();
    return;
  }

  try {
    const { l1_tratamientos, l2_tratamientos, ...prescripcionBaseData } = formData;
    let prescripcionData = { ...prescripcionBaseData };

    if (!isEditing.value) {
      delete prescripcionData.cod_prescripcion;
    }

    if (!prescripcionData.doctor_prescriptor) {
      const doctorOtros = doctores.value.find(d => d.nombre_doctor.toUpperCase() === 'OTROS');
      if (doctorOtros) {
        prescripcionData.doctor_prescriptor = doctorOtros.cod_doctor;
      } else {
        alert('El doctor por defecto "OTROS" no fue encontrado. Por favor, seleccione un doctor.');
        return;
      }
    }
    
    const { data: prescripcionGuardada, error } = await supabase
      .from('prescripcion_clienten')
      .upsert(prescripcionData) 
      .select()
      .single();

    if (error) throw error;
    
    const nuevaPrescripcionId = prescripcionGuardada.cod_prescripcion;

    await supabase.from('prescripcion_tratamiento').delete().eq('cod_prescripcion', nuevaPrescripcionId);

    const tratamientosParaInsertar = [
      ...(l1_tratamientos || []).map(tratId => ({ cod_prescripcion: nuevaPrescripcionId, cod_tratamiento: tratId, numero_lente: 1 })),
      ...(l2_tratamientos || []).map(tratId => ({ cod_prescripcion: nuevaPrescripcionId, cod_tratamiento: tratId, numero_lente: 2 }))
    ];

    if (tratamientosParaInsertar.length > 0) {
      const { error: errorTratamientos } = await supabase.from('prescripcion_tratamiento').insert(tratamientosParaInsertar);
      if (errorTratamientos) throw errorTratamientos;
    }

    alert(isEditing.value ? 'Prescripción actualizada con éxito.' : 'Prescripción guardada con éxito.');
    router.push({ name: 'PanelCliente', params: { id: props.clienteId } });
  } catch (error) {
    console.error("Error al guardar:", error); 
    alert('Error al guardar la prescripción: ' + error.message);
  }
}

function cancelar() {
  if(confirm('¿Está seguro de que desea cancelar? Perderá los cambios no guardados.')) {
    router.back();
  }
}
</script>

<style scoped>
/* Estilos del contenedor */
.form-page-container { padding: 2px 30px; max-width: 1200px; margin: auto; border: solid 1px #d1d1d1; border-radius: 10px;box-shadow: 3px 3px 10px #d4d4d4; padding: 15px 20px;}
.form-page-header { margin-bottom: 10px; padding-bottom: 1px; border-bottom: 1px solid #dee2e6; }
.form-page-header h2 { margin-top: 0; }
.form-page-header p { color: #6c757d; }
.loading { text-align: center; padding: 2rem; color: #6c757d; font-size: 1.1rem; }

/* Estilos de botones de pie de página del formulario */
.btn-guardar, .btn-cancelar { color: white; border: none; padding: 0.5rem 5rem; border-radius: 4px; cursor: pointer; font-size: 14px; }
.btn-guardar { background: #007bff; } .btn-guardar:hover { background: #0056b3; }
.btn-cancelar { background: #6c757d; } .btn-cancelar:hover { background: #5a6268; }
.form-footer { display: flex; justify-content: flex-end; gap: 1rem; margin-top: .1rem; padding-top: .5rem; border-top: 1px solid #dee2e6; }

/* Estilos del formulario */
.form-container, .details-view-container { display: flex; flex-direction: column; gap: 1rem; }
.form-group { display: flex; flex-direction: column; gap: 4px; }
.form-input, .form-group textarea { padding: 5px 12px; border: 1px solid #ced4da; border-radius: 4px; width: 100%; box-sizing: border-box; font-size: 14px; }
.form-input:focus-within, .form-group textarea:focus-within { border-color: #80bdff; box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25); }
.campo-readonly { background-color: #e9ecef; cursor: not-allowed; }

.form-grid-4-col { display: grid; grid-template-columns: 70px 1fr 1fr .7fr 1.1fr; gap: .5rem; }
.form-grid-5-col { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr; gap: .5rem; }
.medidas-grid-container { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; background-color: #f8f9fa; padding: .5rem; border-radius: 8px; border: 1px solid #e9ecef; }
.medida-columna { display: flex; flex-direction: column; gap: 1rem; }
.medida-header { font-weight: 600; color: #495057; padding-bottom: 0.1rem; margin-bottom: 0.1rem; border-bottom: 1px solid #dee2e6; }

/* --- NUEVO LAYOUT PARA MEDIDAS --- */
.medidas-layout {
  display: grid;
  grid-template-columns: 140px 1fr; /* Columna izquierda para DIP/Distancia, el resto para los ojos */
  gap: 1rem;
  align-items: flex-start;
}

.tipo-dip-grupo {
  display: flex;
  flex-direction: column; /* Apila los campos verticalmente */
  gap: 0.5rem;
}
/* ---------------------------------- */

.ojos-fila { display: flex; flex-direction: column; gap: 0.5rem; }
.ojo-grupo { display: grid; grid-template-columns: 30px 1fr 1fr 1fr; gap: 0.5rem; align-items: center; }
.ojo-label { font-weight: bold; font-size: 1rem; text-align: center; }
.cristales-grid-container { display: grid; grid-template-columns: 60px 70px .5fr 2fr .6fr 1fr; gap: 0.5rem .5rem; align-items: center; }
.cristal-row-label { font-size: 0.9rem; font-weight: 600; text-align: left; }
</style>