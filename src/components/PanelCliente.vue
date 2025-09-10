<template>
  <div class="panel-container">
    <header v-if="cliente" class="panel-header">
      <div>
        <h1>Panel de {{ cliente.nombre_cliente }} {{ cliente.apellido_paterno_cliente }}</h1>
        <p class="cliente-info">
          <span>ID Cliente: {{ clienteId }}</span> |
          <span>Teléfono: {{ cliente.telefono_cliente || 'N/A' }}</span>
        </p>
      </div>
      <button @click="volver" class="btn btn-secondary">Volver a la lista</button>
    </header>
    <div v-else class="loading">Cargando datos del cliente...</div>

    <hr>

    <div class="seccion-prescripciones">
      <div class="seccion-header">
        <h2>Prescripciones del Cliente</h2>
        <button @click="abrirModalFormularioParaCrear" class="btn btn-primary">
          + Nueva Prescripción
        </button>
      </div>

      <div v-if="cargandoPrescripciones" class="loading">Cargando prescripciones...</div>

      <table v-else-if="prescripcionesCliente.length > 0">
        <thead>
          <tr>
            <th>Código Receta</th>
            <th>Doctor</th>
            <th>Fecha</th>
            <th>Observaciones</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="prescripcion in prescripcionesCliente" :key="prescripcion.cod_prescripcion">
            <td>{{ prescripcion.cod_receta }}</td>
            <td>{{ prescripcion.doctor_nombre }}</td>
            <td>{{ formatearFecha(prescripcion.fecha_prescripcion) }}</td>
            <td>{{ prescripcion.observacion_prescripcion?.substring(0, 40) }}...</td>
            <td class="acciones-tabla">
              <button @click="abrirModalDetalles(prescripcion)">Ver</button>
              <button @click="abrirModalFormularioParaEditar(prescripcion)">Editar</button>
              <button @click="eliminarPrescripcion(prescripcion.cod_prescripcion)" class="btn-desactivar">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-else class="sin-resultados">
        <p>Este cliente aún no tiene prescripciones registradas.</p>
      </div>
    </div>

    <BaseModal v-model="mostrarModalFormulario" :title="tituloModalFormulario" size="lg">
      <form @submit.prevent="guardarPrescripcion" class="form-container">
        <h4 class="form-section-header">Información General</h4>
        <div class="form-grid">
            <div class="form-group">
                <label>Cliente:</label>
                <input :value="clienteNombreCompleto" readonly class="form-input campo-readonly"/>
            </div>
            <div class="form-group">
                <label>Código de Receta:</label>
                <input v-model="formData.cod_receta" placeholder="Código de receta (ej. R-123)" class="form-input"/>
            </div>
            <div class="form-group">
                <label>Doctor Prescriptor:</label>
                <AutoComplete v-model="formData.doctor_prescriptor" :options="doctoresOptions" placeholder="Seleccionar doctor"/>
            </div>
            <div class="form-group">
                <label>Fecha de Prescripción:</label>
                <input v-model="formData.fecha_prescripcion" type="date" class="form-input"/>
            </div>
        </div>

        <div class="form-section-header-container">
            <h4 class="form-section-header">Medidas de Lentes</h4>
            <button type="button" @click="agregarMedida" class="btn-add-medida">+ Agregar Medida</button>
        </div>

        <div v-for="(medida, index) in medidas" :key="index" class="medida-container">
            <div class="distancia-tipo">
              <div class="form-group">
                <label>TIPO / DISTANCIA</label>
                <AutoComplete v-model="medida.tipo_lente" :options="tipoLenteOptions" placeholder="Seleccionar tipo"/>
              </div>
              <div class="form-group"><label>DIP Binocular (mm)</label><input v-model="medida.dip_lentes_binocular" type="number" step="0.01" class="form-input"/></div>
              <div class="form-group"><label>DIP OD Mono (mm)</label><input v-model="medida.dip_lentes_od_monocular" type="number" step="0.01" class="form-input"/></div>
              <div class="form-group"><label>DIP OI Mono (mm)</label><input v-model="medida.dip_lentes_oi_monocular" type="number" step="0.01" class="form-input"/></div>
              <button type="button" @click="eliminarMedida(index)" v-if="medidas.length > 1" class="btn-desactivar btn-eliminar-medida">Eliminar</button>
            </div>

            <div class="form-column-ojos">
                <div class="ojo-section">
                  <h5 class="ojo-header">Ojo Derecho (OD)</h5>
                  <div class="medidas-grid">
                    <div class="form-row-strict">
                      <div class="form-group"><label>ESF</label><input v-model="medida.esf_od" placeholder="ESF" class="form-input"/></div>
                      <div class="form-group"><label>CIL</label><input v-model="medida.cil_od" placeholder="CIL" class="form-input"/></div>
                      <div class="form-group"><label>EJE</label><input v-model="medida.eje_od" type="number" min="0" max="180" placeholder="EJE" class="form-input"/></div>
                      <div class="form-group"><label>ADIC</label><input v-model="medida.adic_od" placeholder="ADIC" class="form-input"/></div>
                      <div class="form-group"><label>PRISMA</label><input v-model="medida.prisma_od" placeholder="PRISMA" @input="onPrismaChange(medida, 'od')" class="form-input"/></div>
                      <div class="form-group"><label>BASE</label><AutoComplete v-model="medida.base_od" :options="baseOptions" placeholder="Base" :disabled="!medida.prisma_od || medida.prisma_od === '0.00'"/></div>
                      <div class="form-group"><label>ALTURA</label><input v-model="medida.altura_od" placeholder="ALTURA" class="form-input"/></div>
                    </div>
                  </div>
                </div>
                <div class="ojo-section">
                  <h5 class="ojo-header">Ojo Izquierdo (OI)</h5>
                  <div class="medidas-grid">
                     <div class="form-row-strict">
                      <div class="form-group"><label>ESF</label><input v-model="medida.esf_oi" placeholder="ESF" class="form-input"/></div>
                      <div class="form-group"><label>CIL</label><input v-model="medida.cil_oi" placeholder="CIL" class="form-input"/></div>
                      <div class="form-group"><label>EJE</label><input v-model="medida.eje_oi" type="number" min="0" max="180" placeholder="EJE" class="form-input"/></div>
                      <div class="form-group"><label>ADIC</label><input v-model="medida.adic_oi" placeholder="ADIC" class="form-input"/></div>
                      <div class="form-group"><label>PRISMA</label><input v-model="medida.prisma_oi" placeholder="PRISMA" @input="onPrismaChange(medida, 'oi')" class="form-input"/></div>
                      <div class="form-group"><label>BASE</label><AutoComplete v-model="medida.base_oi" :options="baseOptions" placeholder="Base" :disabled="!medida.prisma_oi || medida.prisma_oi === '0.00'"/></div>
                      <div class="form-group"><label>ALTURA</label><input v-model="medida.altura_oi" placeholder="ALTURA" class="form-input"/></div>
                    </div>
                  </div>
                </div>
            </div>
        </div>

        <h4 class="form-section-header">Observaciones Adicionales</h4>
        <div class="form-group">
            <textarea v-model="formData.observacion_prescripcion" placeholder="Observaciones generales..." rows="3" class="form-input"></textarea>
        </div>
      </form>
      <template #footer>
        <button @click="guardarPrescripcion" class="btn-guardar">{{ editId ? 'Actualizar' : 'Guardar' }}</button>
        <button @click="mostrarModalFormulario = false" class="btn-cancelar">Cancelar</button>
      </template>
    </BaseModal>
    <BaseModal v-model="mostrarModalDetalles" title="Detalles de Prescripción" size="lg">
       <div v-if="prescripcionSeleccionada" class="detalles-content">
        <div class="info-grid">
            <div><label>Código:</label><span>{{ prescripcionSeleccionada.cod_receta }}</span></div>
            <div><label>Cliente:</label><span>{{ clienteNombreCompleto }}</span></div>
            <div><label>Doctor:</label><span>{{ prescripcionSeleccionada.doctor_nombre }}</span></div>
            <div><label>Fecha:</label><span>{{ formatearFecha(prescripcionSeleccionada.fecha_prescripcion) }}</span></div>
        </div>
        <div v-if="prescripcionSeleccionada.observacion_prescripcion && prescripcionSeleccionada.observacion_prescripcion !== '-'" class="observaciones-detalle">
            <label>Observaciones:</label>
            <p>{{ prescripcionSeleccionada.observacion_prescripcion }}</p>
        </div>

        <div class="medidas-section-detalle">
            <h4>Medidas de Lentes</h4>
            <div v-if="cargandoMedidas" class="loading">Cargando medidas...</div>
            <div v-else-if="medidasModal.length > 0">
              <div v-for="medida in medidasModal" :key="medida.cod_medida_lente" class="medida-detalle-item">
                  <div class="medida-header-detalle"><span>{{ medida.tipo_lente }}</span></div>
                  <div class="medidas-ojos-detalle">
                      <div class="ojo-detalle">
                          <h6>Ojo Derecho (OD)</h6>
                          <p><span>ESF:</span> {{ medida.esf_od }} | <span>CIL:</span> {{ medida.cil_od }} | <span>EJE:</span> {{ medida.eje_od }}</p>
                          <p><span>ADIC:</span> {{ medida.adic_od }} | <span>ALT:</span> {{ medida.altura_od }}</p>
                          <p v-if="medida.prisma_od && medida.prisma_od !== '0.00'"><span>PRISMA:</span> {{ medida.prisma_od }} <span>BASE:</span> {{ medida.base_od }}</p>
                      </div>
                      <div class="ojo-detalle">
                          <h6>Ojo Izquierdo (OI)</h6>
                          <p><span>ESF:</span> {{ medida.esf_oi }} | <span>CIL:</span> {{ medida.cil_oi }} | <span>EJE:</span> {{ medida.eje_oi }}</p>
                          <p><span>ADIC:</span> {{ medida.adic_oi }} | <span>ALT:</span> {{ medida.altura_oi }}</p>
                          <p v-if="medida.prisma_oi && medida.prisma_oi !== '0.00'"><span>PRISMA:</span> {{ medida.prisma_oi }} <span>BASE:</span> {{ medida.base_oi }}</p>
                      </div>
                  </div>
                  <div class="dip-detalle">
                      <h6>DIP (mm):</h6>
                      <p><span>Binocular:</span> {{ medida.dip_lentes_binocular || 'N/A' }} | <span>OD Mono:</span> {{ medida.dip_lentes_od_monocular || 'N/A' }} | <span>OI Mono:</span> {{ medida.dip_lentes_oi_monocular || 'N/A' }}</p>
                  </div>
              </div>
            </div>
            <div v-else class="sin-resultados"><p>No hay medidas registradas para esta prescripción.</p></div>
        </div>
      </div>
       <template #footer>
          <button @click="mostrarModalDetalles = false" class="btn-cancelar">Cerrar</button>
        </template>
    </BaseModal>
    </div>
</template>

<script setup>
import { ref, onMounted, reactive, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { supabase } from '../lib/supabaseClient';
import BaseModal from './BaseModal.vue';
import AutoComplete from './AutoComplete.vue';

const route = useRoute();
const router = useRouter();

const clienteId = ref(route.params.id);
const cliente = ref(null);
const cargandoPrescripciones = ref(false);
const prescripcionesCliente = ref([]);
const doctores = ref([]);

const mostrarModalFormulario = ref(false);
const editId = ref(null);

const mostrarModalDetalles = ref(false);
const prescripcionSeleccionada = ref(null);
const medidasModal = ref([]);
const cargandoMedidas = ref(false);

const formData = reactive({
  cod_receta: '',
  doctor_prescriptor: '',
  fecha_prescripcion: new Date().toISOString().split('T')[0],
  observacion_prescripcion: ''
});

const medidas = ref([]);

const getMedidaInicial = () => ({
  tipo_lente: '', esf_od: '', cil_od: '', eje_od: 0, prisma_od: '0.00', base_od: null, altura_od: '', adic_od: '',
  esf_oi: '', cil_oi: '', eje_oi: 0, prisma_oi: '0.00', base_oi: null, altura_oi: '', adic_oi: '',
  dip_lentes_binocular: null, dip_lentes_od_monocular: null, dip_lentes_oi_monocular: null
});

const tituloModalFormulario = computed(() => editId.value ? 'Editar Prescripción' : 'Registrar Nueva Prescripción');
const clienteNombreCompleto = computed(() => cliente.value ? `${cliente.value.nombre_cliente} ${cliente.value.apellido_paterno_cliente}`.trim() : '');
const doctoresOptions = computed(() => doctores.value.map(d => ({ value: d.cod_doctor, label: d.nombre_doctor })));
const tipoLenteOptions = ref([ { value: 'LEJOS', label: 'LEJOS' }, { value: 'CERCA', label: 'CERCA' }, { value: 'PROGRESIVO', label: 'PROGRESIVO' }, { value: 'INTERMEDIO', label: 'INTERMEDIO' } ]);
const baseOptions = ref([ { value: 'NASAL', label: 'NASAL' }, { value: 'TEMPORAL', label: 'TEMPORAL' }, { value: 'SUPERIOR', label: 'SUPERIOR' }, { value: 'INFERIOR', label: 'INFERIOR' } ]);

async function getCliente() {
  const { data, error } = await supabase.from('clientes').select('*').eq('cod_cliente', clienteId.value).single();
  if (error) console.error("Error al obtener el cliente:", error);
  else cliente.value = data;
}

async function cargarPrescripcionesCliente() {
  cargandoPrescripciones.value = true;
  try {
    const { data, error } = await supabase.from('prescripcion_cliente')
      .select(`*, doctores:doctor_prescriptor(nombre_doctor)`)
      .eq('cliente', clienteId.value)
      .order('fecha_prescripcion', { ascending: false });
    if (error) throw error;
    prescripcionesCliente.value = data.map(p => ({
      ...p,
      doctor_nombre: p.doctores ? p.doctores.nombre_doctor : 'N/A'
    }));
  } catch (error) {
    alert('Error al cargar prescripciones: ' + error.message);
  } finally {
    cargandoPrescripciones.value = false;
  }
}

async function cargarDoctores() {
  const { data } = await supabase.from('doctores').select('cod_doctor, nombre_doctor').order('nombre_doctor');
  doctores.value = data || [];
}

async function cargarMedidasParaModal(codPrescripcion) {
    cargandoMedidas.value = true;
    medidasModal.value = [];
    try {
        const { data, error } = await supabase.from('medida_lente').select('*').eq('prescripcion', codPrescripcion).order('cod_medida_lente');
        if (error) throw error;
        medidasModal.value = data || [];
    } catch (error) {
        alert('Error al cargar las medidas de la prescripción: ' + error.message);
    } finally {
        cargandoMedidas.value = false;
    }
}

function abrirModalFormularioParaCrear() {
  limpiarFormulario();
  mostrarModalFormulario.value = true;
};

async function abrirModalFormularioParaEditar(prescripcion) {
  await cargarDatosEdicion(prescripcion);
  mostrarModalFormulario.value = true;
};

async function abrirModalDetalles(prescripcion) {
    prescripcionSeleccionada.value = prescripcion;
    await cargarMedidasParaModal(prescripcion.cod_prescripcion);
    mostrarModalDetalles.value = true;
};

function limpiarFormulario() {
  editId.value = null;
  Object.assign(formData, {
    cod_receta: '', doctor_prescriptor: '',
    fecha_prescripcion: new Date().toISOString().split('T')[0], observacion_prescripcion: ''
  });
  medidas.value = [getMedidaInicial()];
}

function agregarMedida() {
  medidas.value.push(getMedidaInicial());
}

function eliminarMedida(index) {
  if (medidas.value.length > 1) medidas.value.splice(index, 1);
}

function onPrismaChange(medida, ojo) {
  const prismaKey = `prisma_${ojo}`;
  const baseKey = `base_${ojo}`;
  if (!medida[prismaKey] || medida[prismaKey].trim() === '' || medida[prismaKey] === '0.00') {
    medida[prismaKey] = '0.00';
    medida[baseKey] = null;
  }
}

async function guardarPrescripcion() {
  if (medidas.value.some(m => !m.tipo_lente)) {
    alert('Todas las medidas deben tener un tipo seleccionado.');
    return;
  }
   if (!formData.doctor_prescriptor) {
    alert('Debe seleccionar un doctor.');
    return;
  }

  try {
    const prescripcionData = {
      cod_receta: formData.cod_receta || '-',
      cliente: parseInt(clienteId.value),
      doctor_prescriptor: parseInt(formData.doctor_prescriptor),
      fecha_prescripcion: formData.fecha_prescripcion,
      observacion_prescripcion: formData.observacion_prescripcion || '-'
    };

    if (editId.value) { // ACTUALIZAR
      const { error: errPres } = await supabase.from('prescripcion_cliente').update(prescripcionData).eq('cod_prescripcion', editId.value);
      if (errPres) throw errPres;
      
      await supabase.from('medida_lente').delete().eq('prescripcion', editId.value);
      
      const medidasData = medidas.value.map(m => ({ prescripcion: editId.value, ...prepararDatosMedida(m) }));
      const { error: errMed } = await supabase.from('medida_lente').insert(medidasData);
      if (errMed) throw errMed;
      alert('Prescripción actualizada.');

    } else { // CREAR
      const { data: nuevaPres, error: errPres } = await supabase.from('prescripcion_cliente').insert(prescripcionData).select().single();
      if (errPres) throw errPres;

      const medidasData = medidas.value.map(m => ({ prescripcion: nuevaPres.cod_prescripcion, ...prepararDatosMedida(m) }));
      const { error: errMed } = await supabase.from('medida_lente').insert(medidasData);
      if (errMed) throw errMed;
      alert('Prescripción guardada.');
    }
    mostrarModalFormulario.value = false;
    await cargarPrescripcionesCliente();
  } catch (error) {
    alert('Error al guardar: ' + error.message);
  }
}

async function cargarDatosEdicion(prescripcion) {
    limpiarFormulario();
    editId.value = prescripcion.cod_prescripcion;
    
    Object.assign(formData, {
        cod_receta: prescripcion.cod_receta,
        doctor_prescriptor: prescripcion.doctor_prescriptor,
        fecha_prescripcion: prescripcion.fecha_prescripcion,
        observacion_prescripcion: prescripcion.observacion_prescripcion
    });

    const { data: medidasData } = await supabase.from('medida_lente').select('*').eq('prescripcion', prescripcion.cod_prescripcion).order('cod_medida_lente');
    if (medidasData && medidasData.length > 0) {
        medidas.value = medidasData;
    } else {
        medidas.value = [getMedidaInicial()];
    }
}

async function eliminarPrescripcion(id) {
  if (!confirm('¿Está seguro de eliminar esta prescripción?')) return;
  try {
    await supabase.from('medida_lente').delete().eq('prescripcion', id);
    await supabase.from('prescripcion_cliente').delete().eq('cod_prescripcion', id);
    alert('Prescripción eliminada.');
    await cargarPrescripcionesCliente();
  } catch (error) {
    alert('Error al eliminar: ' + error.message);
  }
}

const prepararDatosMedida = (medida) => ({
    tipo_lente: medida.tipo_lente,
    esf_od: medida.esf_od || '-', cil_od: medida.cil_od || '-', eje_od: parseInt(medida.eje_od) || 0,
    prisma_od: medida.prisma_od || '0.00', base_od: medida.base_od || null, altura_od: medida.altura_od || '0.00', adic_od: medida.adic_od || '0.00',
    esf_oi: medida.esf_oi || '-', cil_oi: medida.cil_oi || '-', eje_oi: parseInt(medida.eje_oi) || 0,
    prisma_oi: medida.prisma_oi || '0.00', base_oi: medida.base_oi || null, altura_oi: medida.altura_oi || '0.00', adic_oi: medida.adic_oi || '0.00',
    dip_lentes_binocular: medida.dip_lentes_binocular ? parseFloat(medida.dip_lentes_binocular) : null,
    dip_lentes_od_monocular: medida.dip_lentes_od_monocular ? parseFloat(medida.dip_lentes_od_monocular) : null,
    dip_lentes_oi_monocular: medida.dip_lentes_oi_monocular ? parseFloat(medida.dip_lentes_oi_monocular) : null
});

const formatearFecha = (fecha) => new Date(fecha + 'T00:00:00Z').toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'UTC' });

function volver() {
  router.push({ name: 'GestionClientes' });
}

onMounted(() => {
  getCliente();
  cargarPrescripcionesCliente();
  cargarDoctores();
});
</script>

<style scoped>
/* Estilos generales del panel */
.panel-container { padding: 24px; }
.panel-header { display: flex; justify-content: space-between; align-items: flex-start; }
.cliente-info { color: #6c757d; font-size: 14px; }
.seccion-prescripciones { margin-top: 2rem; }
.seccion-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; }
.seccion-header h2 { margin: 0; }

/* Reutilizando estilos de otros componentes */
.btn-primary { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
.btn-primary:hover { background: #0056b3; }
.btn-secondary { background: #6c757d; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
.btn-secondary:hover { background: #5a6268; }
table { width: 100%; border-collapse: collapse; background: white; border-radius: 4px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
th { background: #343a40; color: white; padding: 12px 8px; text-align: left; font-size: 13px; }
td { padding: 10px 8px; border-bottom: 1px solid #dee2e6; font-size: 13px; }
tr:hover { background: #f8f9fa; }
.acciones-tabla { display: flex; gap: 5px; }
td button { padding: 4px 8px; margin: 0 2px; border-radius: 3px; font-size: 11px; border:none; cursor: pointer;}
.btn-desactivar { background: #dc3545; color: white; }
td button:not(.btn-desactivar) { background: #ffc107; color: #212529; }
.loading, .sin-resultados { text-align: center; padding: 2rem; color: #6c757d; font-size: 1.1rem; }


/* --- INICIO: ESTILOS DE FORMULARIO REFACTORIZADOS --- */
.form-container {
    padding: 10px;
}
.campo-readonly { background-color: #e9ecef; cursor: not-allowed; }
.form-section-header { font-size: 16px; font-weight: 600; margin: 20px 0 15px 0; padding-bottom: 8px; border-bottom: 1px solid #e0e0e0; }
.form-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
}
.form-group { display: flex; flex-direction: column; gap: 5px; }
.form-group label { font-weight: 500; font-size: 13px; white-space: nowrap; }
.form-input, .form-group textarea { padding: 8px 12px; border: 1px solid #ced4da; border-radius: 4px; width: 100%; box-sizing: border-box; font-size: 14px; }
.form-section-header-container { display: flex; justify-content: space-between; align-items: center; }
.btn-add-medida { padding: 4px 10px; font-size: 12px; background-color: #28a745; color: white; border:none; cursor: pointer; border-radius: 4px; }
.medida-container { border: 1px solid #e9ecef; border-radius: 6px; padding: 15px; margin-top: 1rem; background-color: #fcfcfc; }
.distancia-tipo {
    display: flex;
    align-items: flex-end;
    margin-bottom: 1rem;
    gap: 1rem;
}
.btn-eliminar-medida {
    padding: 6px 10px;
    font-size: 11px;
    height: fit-content;
    margin-bottom: 2px;
}
.form-column-ojos {
    display: flex;
    flex-direction: column;
    gap: 15px;
}
.ojo-section { padding: 10px; border: 1px solid #e8e8e8; border-radius: 8px; background-color: white; }
.ojo-header { font-size: 14px; font-weight: bold; margin: 0 0 10px 0; text-align: center; }
.medidas-grid { display: flex; flex-direction: column; gap: 15px; }
.form-row-strict {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 10px;
    align-items: end;
}
.btn-guardar { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
.btn-cancelar { background: #6c757d; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
/* --- FIN: ESTILOS DE FORMULARIO REFACTORIZADOS --- */


/* Estilos para el Modal de Detalles */
.detalles-content .info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1rem;
  background-color: #f8f9fa;
  padding: 1rem;
  border-radius: 6px;
  border: 1px solid #e9ecef;
}
.detalles-content .info-grid label {
    font-weight: 600;
    color: #495057;
    display: block;
    margin-bottom: 4px;
}
.observaciones-detalle {
    margin-top: 1.5rem;
    padding: 1rem;
    border-left: 4px solid #007bff;
    background-color: #f8f9fa;
}
.medidas-section-detalle { margin-top: 1.5rem; }
.medida-detalle-item { border: 1px solid #e9ecef; border-radius: 8px; margin-bottom: 1rem; overflow: hidden; }
.medida-header-detalle { padding: 0.5rem 1rem; background-color: #343a40; color: white; font-weight: bold; }
.medidas-ojos-detalle { display: flex; gap: 1rem; padding: 1rem; flex-wrap: wrap; }
.ojo-detalle { flex: 1; min-width: 250px; }
.ojo-detalle h6 { margin-top: 0; border-bottom: 1px solid #eee; padding-bottom: 5px; }
.ojo-detalle p, .dip-detalle p { margin: 0.4rem 0; font-size: 0.9rem; }
.ojo-detalle span, .dip-detalle span { font-weight: 600; color: #555; }
.dip-detalle { padding: 0.5rem 1rem; background-color: #f8f9fa; border-top: 1px solid #e9ecef; }


/* Media Queries para responsividad */
@media (max-width: 1200px) {
    .form-row-strict {
        grid-template-columns: repeat(4, 1fr);
    }
}
@media (max-width: 992px) {
  .form-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
@media (max-width: 768px) {
  .form-grid,
  .form-row-strict {
    grid-template-columns: 1fr;
  }
}
</style>