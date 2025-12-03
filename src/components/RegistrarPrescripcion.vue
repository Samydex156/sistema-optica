<template>
  <v-container>
    <div v-if="cargando" class="d-flex justify-center align-center" style="height: 60vh;">
      <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
      <div class="ml-4 text-h6">Cargando datos...</div>
    </div>

    <v-form @submit.prevent="guardarPrescripcion" v-else>
      <v-card>
        <v-card-title class="text-h5 border-b">
          {{ pageTitle }}
        </v-card-title>

        <v-card-text class="py-4">
          <v-row dense>
            <v-col cols="12" md="3">
              <v-text-field label="Cliente" :model-value="clienteNombreCompleto" readonly variant="outlined"
                density="compact"></v-text-field>
            </v-col>
            <v-col cols="12" sm="6" md="3">
              <v-text-field ref="recetaInputRef" v-model="recetaNumerica" :error-messages="mensajeErrorReceta"
                :loading="verificandoReceta" label="Cód. Receta" placeholder="Ej. 1234" :suffix="sufijoReceta"
                @input="formateaRecetaInput" variant="outlined" density="compact" counter="4"></v-text-field>
            </v-col>
            <v-col cols="12" sm="6" md="2">
              <v-text-field v-model="formData.fecha_prescripcion" label="Fecha Prescripción" type="date"
                variant="outlined" density="compact"></v-text-field>
            </v-col>
            <v-col cols="12" md="4">
              <v-autocomplete v-model="formData.doctor_prescriptor" :items="doctoresOptions" item-title="label"
                item-value="value" label="Doctor Prescriptor" variant="outlined" density="compact">
                <template #append-inner>
                  <v-btn icon="mdi-plus-box" variant="text" size="small"
                    @click.stop="abrirModal({ tableName: 'doctores', fieldName: 'nombre_doctor', idField: 'cod_doctor', fieldToUpdate: 'doctor_prescriptor', placeholder: 'Nombre del Doctor', title: 'Añadir Nuevo Doctor' })"></v-btn>
                </template>
              </v-autocomplete>
            </v-col>
          </v-row>

          <v-row>
            <v-col cols="12" md="6">
              <v-card variant="outlined">
                <v-card-title class="text-subtitle-1 font-weight-bold pt-2 pb-1">Lente 1</v-card-title>
                <v-divider></v-divider>
                <v-card-text>
                  <v-row>
                    <v-col cols="4">
                      <v-autocomplete label="DISTANCIA" v-model="formData.distancia_lente1"
                        :items="tipoLenteDistanciaOptions" item-title="label" item-value="value" variant="outlined"
                        density="compact" class="mb-2"></v-autocomplete>
                      <v-text-field label="DIP" v-model="formData.l1_dip" variant="outlined"
                        density="compact"></v-text-field>
                    </v-col>
                    <v-col cols="8">
                      <div class="d-flex align-center">
                        <span class="font-weight-bold mr-3">OD</span>
                        <v-text-field label="ESF" v-model="formData.l1_esf_od" variant="outlined" density="compact"
                          class="mr-2"></v-text-field>
                        <v-text-field label="CIL" v-model="formData.l1_cil_od" variant="outlined" density="compact"
                          class="mr-2"></v-text-field>
                        <v-text-field label="EJE" v-model="formData.l1_eje_od" variant="outlined"
                          density="compact"></v-text-field>
                      </div>
                      <div class="d-flex align-center mt-2">
                        <span class="font-weight-bold mr-4">OI</span>
                        <v-text-field label="ESF" v-model="formData.l1_esf_oi" variant="outlined" density="compact"
                          class="mr-2"></v-text-field>
                        <v-text-field label="CIL" v-model="formData.l1_cil_oi" variant="outlined" density="compact"
                          class="mr-2"></v-text-field>
                        <v-text-field label="EJE" v-model="formData.l1_eje_oi" variant="outlined"
                          density="compact"></v-text-field>
                      </div>
                    </v-col>
                  </v-row>
                </v-card-text>
              </v-card>
            </v-col>

            <v-col cols="12" md="6">
              <v-card variant="outlined">
                <v-card-title class="text-subtitle-1 font-weight-bold pt-2 pb-1">Lente 2</v-card-title>
                <v-divider></v-divider>
                <v-card-text>
                  <v-row>
                    <v-col cols="4">
                      <v-autocomplete label="DISTANCIA" v-model="formData.distancia_lente2"
                        :items="tipoLenteDistanciaOptions" item-title="label" item-value="value" variant="outlined"
                        density="compact" class="mb-2"></v-autocomplete>
                      <v-text-field label="DIP" v-model="formData.l2_dip" variant="outlined"
                        density="compact"></v-text-field>
                    </v-col>
                    <v-col cols="8">
                      <div class="d-flex align-center">
                        <span class="font-weight-bold mr-3">OD</span>
                        <v-text-field label="ESF" v-model="formData.l2_esf_od" variant="outlined" density="compact"
                          class="mr-2"></v-text-field>
                        <v-text-field label="CIL" v-model="formData.l2_cil_od" variant="outlined" density="compact"
                          class="mr-2"></v-text-field>
                        <v-text-field label="EJE" v-model="formData.l2_eje_od" variant="outlined"
                          density="compact"></v-text-field>
                      </div>
                      <div class="d-flex align-center mt-2">
                        <span class="font-weight-bold mr-4">OI</span>
                        <v-text-field label="ESF" v-model="formData.l2_esf_oi" variant="outlined" density="compact"
                          class="mr-2"></v-text-field>
                        <v-text-field label="CIL" v-model="formData.l2_cil_oi" variant="outlined" density="compact"
                          class="mr-2"></v-text-field>
                        <v-text-field label="EJE" v-model="formData.l2_eje_oi" variant="outlined"
                          density="compact"></v-text-field>
                      </div>
                    </v-col>
                  </v-row>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>

          <v-divider class="my-4"></v-divider>
          <v-row dense align="center">
            <v-col cols="12" sm="auto"><strong class="text-subtitle-1">Cristal 1:</strong></v-col>
            <v-col cols="3" sm="1"><v-text-field type="number" min="0" v-model.number="formData.l1_cantidad_cristal"
                variant="outlined" density="compact"></v-text-field></v-col>
            <v-col cols="9" sm="2"><v-autocomplete label="Material" v-model="formData.l1_material_cristal"
                :items="materialesOptions" item-title="label" item-value="value" variant="outlined"
                density="compact"></v-autocomplete></v-col>
            <v-col cols="12" sm="4">
              <v-autocomplete v-model="formData.l1_tratamientos" :items="tratamientosOptions" item-title="label"
                item-value="value" label="Tratamientos" multiple chips closable-chips variant="outlined"
                density="compact">
                <template #append-inner>
                  <v-btn icon="mdi-plus-box" variant="text" size="small"
                    @click.stop="abrirModal({ tableName: 'tratamientos', fieldName: 'nombre_tratamiento', placeholder: 'Nombre del Tratamiento', title: 'Añadir Nuevo Tratamiento' })"></v-btn>
                </template>
              </v-autocomplete>
            </v-col>
            <v-col cols="6" sm="2"><v-autocomplete label="Color" v-model="formData.l1_color_cristal"
                :items="coloresOptions" item-title="label" item-value="value" variant="outlined"
                density="compact"></v-autocomplete></v-col>
            <v-col cols="6" sm="2"><v-text-field label="Extras" v-model="formData.l1_extra_cristal" variant="outlined"
                density="compact"></v-text-field></v-col>
          </v-row>
          <v-row dense align="center">
            <v-col cols="12" sm="auto"><strong class="text-subtitle-1">Cristal 2:</strong></v-col>
            <v-col cols="3" sm="1"><v-text-field type="number" min="0" v-model.number="formData.l2_cantidad_cristal"
                variant="outlined" density="compact"></v-text-field></v-col>
            <v-col cols="9" sm="2"><v-autocomplete label="Material" v-model="formData.l2_material_cristal"
                :items="materialesOptions" item-title="label" item-value="value" variant="outlined"
                density="compact"></v-autocomplete></v-col>
            <v-col cols="12" sm="4">
              <v-autocomplete v-model="formData.l2_tratamientos" :items="tratamientosOptions" item-title="label"
                item-value="value" label="Tratamientos" multiple chips closable-chips variant="outlined"
                density="compact"></v-autocomplete>
            </v-col>
            <v-col cols="6" sm="2"><v-autocomplete label="Color" v-model="formData.l2_color_cristal"
                :items="coloresOptions" item-title="label" item-value="value" variant="outlined"
                density="compact"></v-autocomplete></v-col>
            <v-col cols="6" sm="2"><v-text-field label="Extras" v-model="formData.l2_extra_cristal" variant="outlined"
                density="compact"></v-text-field></v-col>
          </v-row>

          <v-divider class="my-4"></v-divider>
          <v-row dense>
            <v-col cols="12" md="4">
              <v-autocomplete v-model="formData.cod_proveedor" :items="proveedoresOptions" item-title="label"
                item-value="value" label="Proveedor" variant="outlined" density="compact">
                <template #append-inner>
                  <v-btn icon="mdi-plus-box" variant="text" size="small"
                    @click.stop="abrirModal({ tableName: 'proveedores', fieldName: 'nombre_proveedor', idField: 'cod_proveedor', fieldToUpdate: 'cod_proveedor', placeholder: 'Nombre del Proveedor', title: 'Añadir Nuevo Proveedor' })"></v-btn>
                </template>
              </v-autocomplete>
            </v-col>
            <v-col cols="12" md="4">
              <v-autocomplete v-model="formData.cod_armador" :items="armadoresOptions" item-title="label"
                item-value="value" label="Armador" variant="outlined" density="compact"></v-autocomplete>
            </v-col>
            <v-col cols="12" md="4">
              <v-autocomplete v-model="formData.cod_armazon" :items="armazonesOptions" item-title="label"
                item-value="value" label="Armazón" variant="outlined" density="compact">
                <template #append-inner>
                  <v-btn icon="mdi-plus-box" variant="text" size="small"
                    @click.stop="abrirModal({ tableName: 'armazon_lente', fieldName: 'nombre_armazon', idField: 'cod_armazon', fieldToUpdate: 'cod_armazon', placeholder: 'Nombre del Armazón', title: 'Añadir Nuevo Armazón' })"></v-btn>
                </template>
              </v-autocomplete>
            </v-col>
          </v-row>
          <v-row dense>
            <v-col cols="6" md="3"><v-text-field v-model="formData.num_sobre" label="Núm. Sobre" variant="outlined"
                density="compact"></v-text-field></v-col>
            <v-col cols="6" md="3"><v-text-field v-model="formData.fecha_entrega" label="Fecha Entrega" type="date"
                variant="outlined" density="compact"></v-text-field></v-col>
            <v-col cols="6" md="3"><v-text-field v-model="formData.cod_pedido1" label="Núm. Pedido 1" variant="outlined"
                density="compact"></v-text-field></v-col>
            <v-col cols="6" md="3"><v-text-field v-model="formData.cod_pedido2" label="Núm. Pedido 2" variant="outlined"
                density="compact"></v-text-field></v-col>
          </v-row>

          <v-row dense>
            <v-col cols="12">
              <v-textarea v-model="formData.notas_adicionales" label="Observaciones o notas adicionales" rows="2"
                variant="outlined" density="compact"></v-textarea>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="pa-4 border-t">
          <v-spacer></v-spacer>
          <v-btn @click="cancelar" variant="text">Cancelar</v-btn>
          <v-btn type="submit" color="primary" variant="flat" :loading="guardando" :disabled="cargando || guardando">
            {{ isEditing ? 'Actualizar Prescripción' : 'Guardar Prescripción' }}
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-form>

    <v-dialog v-model="showNuevoItemModal" max-width="500px">
      <v-card>
        <v-card-title>{{ nuevoItemData.title }}</v-card-title>
        <v-card-text>
          <v-text-field ref="nuevoItemInputRef" v-model="nuevoItemData.value" :label="nuevoItemData.placeholder"
            variant="outlined" @keyup.enter="guardarNuevoItem"></v-text-field>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn @click="showNuevoItemModal = false" variant="text">Cancelar</v-btn>
          <v-btn @click="guardarNuevoItem" color="primary" variant="flat" :loading="isSavingNewItem">
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
  </v-container>
</template>

<script setup>
import { ref, onMounted, reactive, computed, nextTick, watch } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from '../lib/supabaseClient';

const props = defineProps({
  clienteId: { type: String, required: true },
  prescripcionId: { type: String, default: null }
});

const router = useRouter();
const isEditing = computed(() => !!props.prescripcionId);

const cargando = ref(true);
const guardando = ref(false);
const cliente = ref(null);
const recetaInputRef = ref(null);
const recetaNumerica = ref('');

const mensajeErrorReceta = ref('');
const verificandoReceta = ref(false);
let debounceTimerReceta = null;

const snackbar = ref(false);
const snackbarText = ref("");
const snackbarColor = ref("success");

function mostrarMensaje(mensaje, color = "success") {
  snackbarText.value = mensaje;
  snackbarColor.value = color;
  snackbar.value = true;
}

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

watch(showNuevoItemModal, (newValue) => {
  if (newValue) {
    nextTick(() => {
      nuevoItemInputRef.value?.focus();
    });
  }
});

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
  fecha_prescripcion: new Date().toISOString().split('T')[0],
  doctor_prescriptor: null,
  distancia_lente1: 'LEJOS', l1_dip: '', l1_esf_od: '', l1_cil_od: '', l1_eje_od: '', l1_esf_oi: '', l1_cil_oi: '', l1_eje_oi: '',
  distancia_lente2: 'CERCA', l2_dip: '', l2_esf_od: '', l2_cil_od: '', l2_eje_od: '', l2_esf_oi: '', l2_cil_oi: '', l2_eje_oi: '',
  l1_cantidad_cristal: 2, l1_material_cristal: null, l1_color_cristal: null, l1_extra_cristal: '', l1_tratamientos: [],
  l2_cantidad_cristal: 2, l2_material_cristal: null, l2_color_cristal: null, l2_extra_cristal: '', l2_tratamientos: [],
  cod_proveedor: null, cod_armador: null, cod_armazon: null,
  fecha_entrega: new Date().toISOString().split('T')[0],
  num_sobre: '', cod_pedido1: '', cod_pedido2: '',
  notas_adicionales: '',
});

const formData = reactive(getInitialFormData());

const pageTitle = computed(() => isEditing.value ? 'Editar Prescripción' : 'Registrar Prescripción');
const clienteNombreCompleto = computed(() => cliente.value ? `${cliente.value.nombre_cliente} ${cliente.value.apellido_paterno_cliente || ''}`.trim() : '');

// --- INICIO DE LA MODIFICACIÓN ---
const sufijoReceta = computed(() => {
  const apellidoPaterno = cliente.value?.apellido_paterno_cliente;
  if (apellidoPaterno) {
    const apellidoLimpio = apellidoPaterno.trim().toUpperCase();

    if (apellidoLimpio.startsWith('CH')) {
      return '-CH';
    }

    if (apellidoLimpio.startsWith('LL')) {
      return '-LL';
    }

    // Lógica original para una sola letra
    const primeraLetra = apellidoLimpio.charAt(0);
    if (primeraLetra && /^[A-Z]$/.test(primeraLetra)) {
      return `-${primeraLetra}`;
    }
  }
  return '';
});
// --- FIN DE LA MODIFICACIÓN ---

const codigoRecetaCompleto = computed(() => {
  if (recetaNumerica.value && /^\d{1,4}$/.test(recetaNumerica.value.trim())) {
    return `${recetaNumerica.value.trim()}${sufijoReceta.value}`;
  }
  return recetaNumerica.value.trim();
});

watch(codigoRecetaCompleto, (nuevoValor) => {
  if (debounceTimerReceta) clearTimeout(debounceTimerReceta);
  mensajeErrorReceta.value = '';

  if (!nuevoValor) return;

  debounceTimerReceta = setTimeout(async () => {
    verificandoReceta.value = true;
    try {
      const { data, error } = await supabase
        .from('prescripcion_clienten')
        .select('cod_prescripcion')
        .eq('cod_receta', nuevoValor)
        .maybeSingle();

      if (error) throw error;

      if (data) {
        if (isEditing.value && String(data.cod_prescripcion) === String(props.prescripcionId)) {
          return;
        }
        mensajeErrorReceta.value = `El código ${nuevoValor} ya existe.`;
      }
    } catch (error) {
      console.error("Error al verificar receta:", error);
    } finally {
      verificandoReceta.value = false;
    }
  }, 500);
});

const doctoresOptions = computed(() => doctores.value.map(d => ({ value: d.cod_doctor, label: d.nombre_doctor })));
const materialesOptions = computed(() => materiales.value.map(m => ({ value: m.cod_material_cristal, label: m.nombre_material })));
const coloresOptions = computed(() => colores.value.map(c => ({ value: c.cod_color_cristal, label: c.nombre_color })));
const tratamientosOptions = computed(() => tratamientos.value.map(t => ({ value: t.cod_tratamiento, label: t.nombre_tratamiento })));
const proveedoresOptions = computed(() => proveedores.value.map(p => ({ value: p.cod_proveedor, label: p.nombre_proveedor })));
const armadoresOptions = computed(() => armadores.value.map(a => ({ value: a.cod_armador, label: a.nombre_armador })));
const armazonesOptions = computed(() => armazones.value.map(a => ({ value: a.cod_armazon, label: a.nombre_armazon })));
const tipoLenteDistanciaOptions = ref([{ value: 'LEJOS', label: 'LEJOS' }, { value: 'CERCA', label: 'CERCA' }, { value: 'PROGRESIVO', label: 'PROGRESIVO' }, { value: 'BIFOCAL', label: 'BIFOCAL' }, { value: 'INTERMEDIO', label: 'INTERMEDIO' }]);

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

      let codRecetaExistente = prescripcionData.cod_receta || '';
      const match = codRecetaExistente.match(/^(\d+)/);
      recetaNumerica.value = match ? match[1] : '';

      Object.assign(formData, { ...prescripcionData, l1_tratamientos, l2_tratamientos });

    } else {
      const proveedorDefault = proveedores.value.find(p => p.nombre_proveedor.toUpperCase() === 'OPTALVISION');
      if (proveedorDefault) formData.cod_proveedor = proveedorDefault.cod_proveedor;
      const armadorDefault = armadores.value.find(a => a.nombre_armador.toUpperCase() === 'JAIME');
      if (armadorDefault) formData.cod_armador = armadorDefault.cod_armador;
      const armazonDefault = armazones.value.find(a => a.nombre_armazon.toUpperCase() === 'PROPIO');
      if (armazonDefault) formData.cod_armazon = armazonDefault.cod_armazon;
    }
  } catch (error) {
    console.error("Error al inicializar el formulario:", error);
    mostrarMensaje("Error al cargar los datos: " + error.message, "error");
  } finally {
    cargando.value = false;
  }
}

function formateaRecetaInput(event) {
  let valor = event.target.value.replace(/\D/g, '');
  recetaNumerica.value = valor.substring(0, 4);
}

function abrirModal(config) {
  nuevoItemData.value = { ...config, value: '' };
  showNuevoItemModal.value = true;
}

async function guardarNuevoItem() {
  const { value, tableName, fieldName, idField, fieldToUpdate, placeholder } = nuevoItemData.value;
  if (!value || !value.trim()) {
    mostrarMensaje(`El campo "${placeholder}" no puede estar vacío.`, "warning");
    return;
  }
  isSavingNewItem.value = true;
  try {
    const dataToInsert = { [fieldName]: value.trim().toUpperCase() };

    if (tableName === 'proveedores') {
      dataToInsert.telefono_proveedor = '-';
    }

    const { data: nuevoRegistro, error } = await supabase
      .from(tableName)
      .insert(dataToInsert)
      .select()
      .single();

    if (error) throw error;

    mostrarMensaje(`'${value}' ha sido añadido con éxito.`, "success");
    await cargarDatosSelect();

    if (fieldToUpdate && idField) {
      formData[fieldToUpdate] = nuevoRegistro[idField];
    }

    showNuevoItemModal.value = false;

  } catch (error) {
    console.error("Error al guardar nuevo ítem:", error);
    mostrarMensaje(`Error al guardar: ${error.message}`, "error");
  } finally {
    isSavingNewItem.value = false;
  }
}

async function guardarPrescripcion() {
  const recetaFinal = codigoRecetaCompleto.value;
  if (!recetaFinal || !recetaNumerica.value.trim()) {
    mostrarMensaje('El campo "Cód. Receta" es obligatorio y debe tener la parte numérica.', "warning");
    recetaInputRef.value?.focus();
    return;
  }

  if (mensajeErrorReceta.value) {
    mostrarMensaje('Corrija el error en el código de receta antes de guardar.', "warning");
    recetaInputRef.value?.focus();
    return;
  }

  guardando.value = true;
  try {
    const { l1_tratamientos, l2_tratamientos, ...prescripcionBaseData } = formData;

    let prescripcionData = { ...prescripcionBaseData, cod_receta: recetaFinal };

    const fieldsToUppercase = [
      'l1_dip', 'l1_esf_od', 'l1_cil_od', 'l1_eje_od', 'l1_esf_oi', 'l1_cil_oi', 'l1_eje_oi',
      'l2_dip', 'l2_esf_od', 'l2_cil_od', 'l2_eje_od', 'l2_esf_oi', 'l2_cil_oi', 'l2_eje_oi',
      'l1_extra_cristal', 'l2_extra_cristal', 'num_sobre', 'cod_pedido1', 'cod_pedido2', 'notas_adicionales'
    ];

    for (const key of fieldsToUppercase) {
      if (prescripcionData[key] && typeof prescripcionData[key] === 'string') {
        prescripcionData[key] = prescripcionData[key].toUpperCase();
      }
    }

    if (!isEditing.value) {
      delete prescripcionData.cod_prescripcion;
    }

    if (!prescripcionData.doctor_prescriptor) {
      const doctorOtros = doctores.value.find(d => d.nombre_doctor.toUpperCase() === 'OTROS');
      if (doctorOtros) {
        prescripcionData.doctor_prescriptor = doctorOtros.cod_doctor;
      } else {
        mostrarMensaje('El doctor por defecto "OTROS" no fue encontrado. Por favor, seleccione un doctor.', "error");
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

    mostrarMensaje(isEditing.value ? 'Prescripción actualizada con éxito.' : 'Prescripción guardada con éxito.', "success");
    setTimeout(() => {
      router.push({ name: 'GestionClientes' });
    }, 1500);
  } catch (error) {
    console.error("Error al guardar:", error);
    mostrarMensaje('Error al guardar la prescripción: ' + error.message, "error");
  } finally {
    guardando.value = false;
  }
}

function cancelar() {
  if (confirm('Los cambios no se guardarán. Clic en Aceptar para volver atrás.')) {
    router.back();
  }
}
</script>

<style scoped>
.border-b {
  border-bottom: 1px solid rgba(0, 0, 0, 0.12);
}

.border-t {
  border-top: 1px solid rgba(0, 0, 0, 0.12);
}
</style>