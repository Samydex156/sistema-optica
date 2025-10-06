<template>
  <div class="form-page-container">
    <header class="form-page-header">
      <h2>{{ pageTitle }}</h2>
    </header>

    <form @submit.prevent="guardarPrescripcion" class="form-container" v-if="!cargando">
      <div class="form-grid-4-col">
        <div><strong>Cliente:</strong></div>
        <div class="form-group"><input :value="clienteNombreCompleto" readonly class="form-input campo-readonly" /></div>
        
        <div class="form-group campo-receta-grupo">
          <input 
            ref="recetaInputRef" 
            v-model="recetaNumerica" 
            placeholder="Cód. Receta Ej. 1234" 
            class="form-input" 
            @input="formateaRecetaInput"
          />
          <span class="receta-sufijo">{{ sufijoReceta }}</span>
        </div>
        
        <div class="form-group"><input v-model="formData.fecha_prescripcion" type="date" class="form-input" /></div>
        
        <div class="form-group-with-button">
          <AutoComplete v-model="formData.doctor_prescriptor" :options="doctoresOptions" placeholder="Doctor Prescriptor" />
          <button type="button" @click="abrirModal({
              tableName: 'doctores',
              fieldName: 'nombre_doctor',
              idField: 'cod_doctor',
              fieldToUpdate: 'doctor_prescriptor',
              placeholder: 'Nombre del Doctor',
              title: 'Añadir Nuevo Doctor'
            })" class="btn-add">+</button>
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
          <div class="form-group-with-button">
            <TratamientoSelector v-model="formData.l1_tratamientos" :options="tratamientosOptions" placeholder="Tratamientos" />
             <button type="button" @click="abrirModal({
                tableName: 'tratamientos',
                fieldName: 'nombre_tratamiento',
                placeholder: 'Nombre del Tratamiento',
                title: 'Añadir Nuevo Tratamiento'
              })" class="btn-add">+</button>
          </div>
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
        <div class="form-group-with-button">
          <AutoComplete v-model="formData.cod_proveedor" :options="proveedoresOptions" placeholder="Proveedor" />
          <button type="button" @click="abrirModal({
              tableName: 'proveedores',
              fieldName: 'nombre_proveedor',
              idField: 'cod_proveedor',
              fieldToUpdate: 'cod_proveedor',
              placeholder: 'Nombre del Proveedor',
              title: 'Añadir Nuevo Proveedor'
            })" class="btn-add">+</button>
        </div>
        <div class="form-group"><AutoComplete v-model="formData.cod_armador" :options="armadoresOptions" placeholder="Armador" /></div>
        
        <div class="form-group-with-button">
          <AutoComplete v-model="formData.cod_armazon" :options="armazonesOptions" placeholder="Armazón"/>
          <button type="button" @click="abrirModal({
              tableName: 'armazon_lente',
              fieldName: 'nombre_armazon',
              idField: 'cod_armazon',
              fieldToUpdate: 'cod_armazon',
              placeholder: 'Nombre del Armazón',
              title: 'Añadir Nuevo Armazón'
            })" class="btn-add">+</button>
        </div>
        <div class="form-group"><input v-model="formData.num_sobre" type="text" class="form-input" placeholder="Núm. Sobre"/></div>
        <div class="form-group"><input v-model="formData.fecha_entrega" type="date" class="form-input" placeholder="Fecha entrega"/></div>
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

    <BaseModal v-model="showNuevoItemModal" :title="nuevoItemData.title" size="sm">
        <div class="form-group">
            <label :for="`input-${nuevoItemData.fieldName}`" class="form-label">{{ nuevoItemData.placeholder }}</label>
            <input 
                :id="`input-${nuevoItemData.fieldName}`"
                v-model="nuevoItemData.value" 
                :placeholder="nuevoItemData.placeholder" 
                class="form-input" 
                @keyup.enter="guardarNuevoItem" 
                ref="nuevoItemInputRef"
            />
        </div>
        <template #footer>
            <button @click="showNuevoItemModal = false" class="btn-cancelar">Cancelar</button>
            <button @click="guardarNuevoItem" class="btn-guardar" :disabled="isSavingNewItem">
                {{ isSavingNewItem ? 'Guardando...' : 'Guardar' }}
            </button>
        </template>
    </BaseModal>
    </div>
</template>

<script setup>
import { ref, onMounted, reactive, computed, nextTick, watch } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from '../lib/supabaseClient';
import AutoComplete from './Autocomplete.vue';
import TratamientoSelector from './TratamientoSelector.vue';
// INICIO: Importación del modal
import BaseModal from './BaseModal.vue'; 
// FIN: Importación del modal

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
// NUEVA REFERENCIA: Contiene solo la parte numérica ingresada por el usuario
const recetaNumerica = ref(''); 

// --- INICIO: ESTADO Y REFERENCIAS PARA EL MODAL ---
const showNuevoItemModal = ref(false);
const isSavingNewItem = ref(false);
const nuevoItemInputRef = ref(null);
const nuevoItemData = ref({
  tableName: '',
  fieldName: '',
  idField: '',
  value: '',
  placeholder: '',
  title: '',
  fieldToUpdate: '',
});

// Watch para enfocar el input cuando el modal se abre
watch(showNuevoItemModal, (newValue) => {
  if (newValue) {
    nextTick(() => {
      nuevoItemInputRef.value?.focus();
    });
  }
});
// --- FIN: ESTADO Y REFERENCIAS PARA EL MODAL ---

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
  // Eliminamos cod_receta de aquí, se maneja por computed
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
const clienteNombreCompleto = computed(() => cliente.value ? `${cliente.value.nombre_cliente} ${cliente.value.apellido_paterno_cliente || ''}`.trim() : '');

// NUEVA PROPIEDAD COMPUTADA: Sufijo de la receta
const sufijoReceta = computed(() => {
  const apellidoPaterno = cliente.value?.apellido_paterno_cliente;
  if (apellidoPaterno) {
    const primeraLetra = apellidoPaterno.trim().charAt(0).toUpperCase();
    if (primeraLetra && /^[A-Z]$/.test(primeraLetra)) {
      return `-${primeraLetra}`;
    }
  }
  return ''; // Si no hay apellido o no empieza con letra, no hay sufijo
});

// NUEVA PROPIEDAD COMPUTADA: Código de Receta Completo
const codigoRecetaCompleto = computed(() => {
    // Solo si hay parte numérica y es válida, se añade el sufijo
    if (recetaNumerica.value && /^\d{1,4}$/.test(recetaNumerica.value.trim())) {
        return `${recetaNumerica.value.trim()}${sufijoReceta.value}`;
    }
    return recetaNumerica.value.trim(); // Devuelve solo el número si no aplica el sufijo
});

const doctoresOptions = computed(() => doctores.value.map(d => ({ value: d.cod_doctor, label: d.nombre_doctor })));
const materialesOptions = computed(() => materiales.value.map(m => ({ value: m.cod_material_cristal, label: m.nombre_material })));
const coloresOptions = computed(() => colores.value.map(c => ({ value: c.cod_color_cristal, label: c.nombre_color })));
const tratamientosOptions = computed(() => tratamientos.value.map(t => ({ value: t.cod_tratamiento, label: t.nombre_tratamiento })));
const proveedoresOptions = computed(() => proveedores.value.map(p => ({ value: p.cod_proveedor, label: p.nombre_proveedor })));
const armadoresOptions = computed(() => armadores.value.map(a => ({ value: a.cod_armador, label: a.nombre_armador })));
const armazonesOptions = computed(() => armazones.value.map(a => ({ value: a.cod_armazon, label: a.nombre_armazon })));
const tipoLenteDistanciaOptions = ref([{ value: 'LEJOS', label: 'LEJOS' }, { value: 'CERCA', label: 'CERCA' }, { value: 'PROGRESIVO', label: 'PROGRESIVO' }, { value: 'BIFOCAL', label: 'BIFOCAL' }, { value: 'INTERMEDIO', label: 'INTERMEDIO' }]);

// --- INICIO: FUNCIONES DE CARGA DE DATOS REFACTORIZADAS ---
async function cargarDatosSelect() {
    const cargas = {
        doctores: supabase.from('doctores').select('*'),
        materiales: supabase.from('material_cristal').select('*'),
        colores: supabase.from('color_cristal').select('*'),
        tratamientos: supabase.from('tratamientos').select('*'),
        proveedores: supabase.from('proveedores').select('*'),
        armadores: supabase.from('armador_lente').select('*'),
        armazones: supabase.from('armazon_lente').select('*'),
    };
    const resultados = await Promise.all(Object.values(cargas));
    const [docRes, matRes, colRes, tratRes, provRes, armadRes, armazRes] = resultados;
    
    doctores.value = docRes.data || [];
    materiales.value = matRes.data || [];
    colores.value = colRes.data || [];
    tratamientos.value = tratRes.data || [];
    proveedores.value = provRes.data || [];
    armadores.value = armadRes.data || [];
    armazones.value = armazRes.data || [];
}
// --- FIN: FUNCIONES DE CARGA DE DATOS ---

onMounted(async () => {
  await inicializarFormulario();
  nextTick(() => recetaInputRef.value?.focus());
});

async function inicializarFormulario() {
  cargando.value = true;
  try {
    const { data: clienteData } = await supabase.from('clientes').select('*').eq('cod_cliente', props.clienteId).single();
    cliente.value = clienteData;
    
    await cargarDatosSelect();

    if (isEditing.value) {
      const { data: prescripcionData } = await supabase.from('prescripcion_clienten').select('*').eq('cod_prescripcion', props.prescripcionId).single();
      const { data: tratamientosData } = await supabase.from('prescripcion_tratamiento').select('cod_tratamiento, numero_lente').eq('cod_prescripcion', props.prescripcionId);
      const l1_tratamientos = tratamientosData?.filter(t => t.numero_lente === 1).map(t => t.cod_tratamiento) || [];
      const l2_tratamientos = tratamientosData?.filter(t => t.numero_lente === 2).map(t => t.cod_tratamiento) || [];
      
      // CAMBIO CLAVE: Extraemos la parte numérica del cod_receta existente para llenar recetaNumerica
      let codRecetaExistente = prescripcionData.cod_receta || '';
      // Asume que el código es NUMEROS-LETRA
      const match = codRecetaExistente.match(/^(\d+)/);
      recetaNumerica.value = match ? match[1] : '';

      Object.assign(formData, { ...prescripcionData, l1_tratamientos, l2_tratamientos });
      // Se mantiene formData.cod_receta en el objeto reactivo, pero se sobreescribe al guardar
      // para asegurar que el formulario muestra los datos de la DB al cargar.

    } else {
      // Prellenar campos comunes para nuevas prescripciones
      const proveedorDefault = proveedores.value.find(p => p.nombre_proveedor.toUpperCase() === 'OPTALVISION');
      if (proveedorDefault) formData.cod_proveedor = proveedorDefault.cod_proveedor;
      const armadorDefault = armadores.value.find(a => a.nombre_armador.toUpperCase() === 'JAIME');
      if (armadorDefault) formData.cod_armador = armadorDefault.cod_armador;
      const armazonDefault = armazones.value.find(a => a.nombre_armazon.toUpperCase() === 'PROPIO');
      if (armazonDefault) formData.cod_armazon = armazonDefault.cod_armazon;
    }
  } catch (error) {
    console.error("Error al inicializar el formulario:", error);
    alert("Error al cargar los datos: " + error.message);
  } finally {
    cargando.value = false;
  }
}

/**
 * Función para asegurar que solo se ingresen dígitos en recetaNumerica
 * y limitar la longitud (ej. a 4 dígitos).
 */
function formateaRecetaInput(event) {
    let valor = event.target.value.replace(/\D/g, ''); // Elimina todo lo que no sea dígito
    recetaNumerica.value = valor.substring(0, 4); // Limita a 4 dígitos
}

// --- INICIO: FUNCIONES DEL MODAL ---
function abrirModal(config) {
  nuevoItemData.value = { ...config, value: '' }; // Resetea el valor al abrir
  showNuevoItemModal.value = true;
}

async function guardarNuevoItem() {
  const { value, tableName, fieldName, idField, fieldToUpdate, placeholder } = nuevoItemData.value;
  if (!value || !value.trim()) {
    alert(`El campo "${placeholder}" no puede estar vacío.`);
    return;
  }
  isSavingNewItem.value = true;
  try {
    const dataToInsert = { [fieldName]: value.trim() };
    if(tableName === 'proveedores') {
      // Supabase puede requerir campos no nulos, agregamos valores por defecto
      dataToInsert.telefono_proveedor = '-';
    }

    const { data: nuevoRegistro, error } = await supabase
      .from(tableName)
      .insert(dataToInsert)
      .select()
      .single();

    if (error) throw error;
    
    alert(`'${value}' ha sido añadido con éxito.`);
    await cargarDatosSelect(); // Recarga todos los selects para mantener consistencia

    // Si es un campo para auto-seleccionar, lo actualizamos
    if (fieldToUpdate && idField) {
      formData[fieldToUpdate] = nuevoRegistro[idField];
    }
    
    showNuevoItemModal.value = false;

  } catch (error) {
    console.error("Error al guardar nuevo ítem:", error);
    alert(`Error al guardar: ${error.message}`);
  } finally {
    isSavingNewItem.value = false;
  }
}
// --- FIN: FUNCIONES DEL MODAL ---


async function guardarPrescripcion() {
  const recetaFinal = codigoRecetaCompleto.value;
  if (!recetaFinal || !recetaNumerica.value.trim()) {
    alert('El campo "Cód. Receta" es obligatorio y debe tener la parte numérica.');
    recetaInputRef.value?.focus();
    return;
  }

  try {
    const { l1_tratamientos, l2_tratamientos, ...prescripcionBaseData } = formData;
    
    // CAMBIO CLAVE: Incluir el código de receta COMPLETO antes de guardar
    let prescripcionData = { ...prescripcionBaseData, cod_receta: recetaFinal };

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
  if(confirm('Los cambios no se guardarán. Clic en Aceptar para volver atrás.')) {
    router.back();
  }
}
</script>

<style scoped>
/* ... Mantener estilos previos ... */

/* Estilos específicos para el nuevo campo de receta */
.campo-receta-grupo {
  position: relative;
  display: flex; /* Asegura que el input y el sufijo estén en línea */
  align-items: center;
  /* El input ya tiene height: 30px; */
}

.receta-sufijo {
  position: absolute;
  /* Posicionamiento a la derecha del input */
  right: 12px; 
  top: 50%;
  transform: translateY(-50%);
  
  /* Estilos para que parezca parte del input pero sea un valor fijo */
  padding: 0 5px;
  background-color: #f1f1f1; 
  color: #6c757d; /* Color de texto más tenue */
  border-radius: 4px;
  font-size: 14px;
  font-weight: bold;
  pointer-events: none; /* Ignora clics, permite interacción con el input debajo */
  z-index: 2; /* Sobre el input */
}

/* Ajuste al input para que el sufijo no lo tape */
.campo-receta-grupo .form-input {
    padding-right: 50px; /* Suficiente espacio para el sufijo (-A) */
}

/* Estilos del contenedor */
.form-page-container { padding: 2px 30px; max-width: 1200px; margin: auto; border: solid 1px #d1d1d1; border-radius: 10px;box-shadow: 3px 3px 10px #d4d4d4; padding: 15px 20px;}
.form-page-header { margin-bottom: 10px; padding-bottom: 1px; border-bottom: 1px solid #dee2e6; }
.form-page-header h2 { margin-top: 0; }
.loading { text-align: center; padding: 2rem; color: #6c757d; font-size: 1.1rem; }

/* Estilos de botones de pie de página del formulario */
.btn-guardar, .btn-cancelar { color: white; border: none; padding: 0.5rem 5rem; border-radius: 4px; cursor: pointer; font-size: 14px; }
.btn-guardar { background: #007bff; } .btn-guardar:hover { background: #0056b3; }
.btn-guardar:disabled { background: #0056b3; cursor: not-allowed;}
.btn-cancelar { background: #6c757d; } .btn-cancelar:hover { background: #5a6268; }
.form-footer { display: flex; justify-content: flex-end; gap: 1rem; margin-top: .1rem; padding-top: .5rem; border-top: 1px solid #dee2e6; }
.modal-footer .btn-guardar, .modal-footer .btn-cancelar { padding: 0.5rem 1.5rem; } /* Padding más pequeño para botones de modal */

/* Estilos del formulario */
.form-container { display: flex; flex-direction: column; gap: 1rem; }
.form-group { display: flex; flex-direction: column; gap: 4px; }
.form-label { font-weight: 500; font-size: 0.9rem; color: #495057; }
.form-input, .form-group textarea { padding: 5px 12px; border: 1px solid #ced4da; border-radius: 4px; width: 100%; box-sizing: border-box; font-size: 14px; height: 30px; }
.form-input:focus-within, .form-group textarea:focus-within { border-color: #80bdff; box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25); }
.campo-readonly { background-color: #e9ecef; cursor: not-allowed; }

/* INICIO: Estilos para el grupo de campo + botón */
.form-group-with-button {
  display: flex;
  align-items: center;
  gap: 8px;
}
.form-group-with-button > :first-child {
  flex-grow: 1; /* Hace que el Autocomplete o Selector ocupe el espacio disponible */
}
.btn-add {
  flex-shrink: 0;
  padding: 0 10px;
  height: 30px;
  font-size: 1.2rem;
  font-weight: bold;
  background-color: #28a745;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}
.btn-add:hover {
  background-color: #218838;
}
/* FIN: Estilos para el grupo de campo + botón */

.form-grid-4-col { display: grid; grid-template-columns: 70px 1fr 1fr .7fr 1.1fr; gap: .5rem; align-items: center; }
.form-grid-5-col { display: grid; grid-template-columns: repeat(7, 1fr); gap: .5rem; }
.medidas-grid-container { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; background-color: #f8f9fa; padding: .5rem; border-radius: 8px; border: 1px solid #e9ecef; }
.medida-columna { display: flex; flex-direction: column; gap: 1rem; }
.medida-header { font-weight: 600; color: #495057; padding-bottom: 0.1rem; margin-bottom: 0.1rem; border-bottom: 1px solid #dee2e6; }

.medidas-layout { display: grid; grid-template-columns: 140px 1fr; gap: 1rem; align-items: flex-start; }
.tipo-dip-grupo { display: flex; flex-direction: column; gap: 0.5rem; }
.ojos-fila { display: flex; flex-direction: column; gap: 0.5rem; }
.ojo-grupo { display: grid; grid-template-columns: 30px 1fr 1fr 1fr; gap: 0.5rem; align-items: center; }
.ojo-label { font-weight: bold; font-size: 1rem; text-align: center; }
.cristales-grid-container { display: grid; grid-template-columns: 60px 70px .5fr 2fr .6fr 1fr; gap: 0.5rem .5rem; align-items: center; }
.cristal-row-label { font-size: 0.9rem; font-weight: 600; text-align: left; }
</style>