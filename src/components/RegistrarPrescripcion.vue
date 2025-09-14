<template>
  <div>
    <h3>Gestión de Prescripciones</h3>

    <div class="botones-arriba">
      <button @click="abrirModalFormularioParaCrear" class="btn-nueva-montura">
        + Nueva Prescripción
      </button>
      <input v-model="filtros.busqueda" placeholder="Buscar por receta, cliente, teléfono..." class="filtro-input" />
      <select v-model="filtros.doctor" class="filtro-select">
        <option value="">Todos los doctores</option>
        <option v-for="doctor in doctores" :key="doctor.cod_doctor" :value="doctor.cod_doctor">
          {{ doctor.nombre_doctor }}
        </option>
      </select>
      <input v-model="filtros.fechaDesde" type="date" class="filtro-input" />
      <input v-model="filtros.fechaHasta" type="date" class="filtro-input" />
      <button @click="limpiarFiltros" class="btn-cancelar">Limpiar</button>
    </div>

    <div v-if="cargando" class="loading">Cargando prescripciones...</div>

    <table v-else-if="prescripcionesFiltradas.length > 0">
      <thead>
        <tr>
          <th>Nro. Receta</th>
          <th>Cliente</th>
          <th>Teléfono</th>
          <th>Doctor</th>
          <th>Fecha</th>
          <th>Tipos de Lente</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="prescripcion in prescripcionesFiltradas" :key="prescripcion.cod_prescripcion">
          <td>{{ prescripcion.cod_receta }}</td>
          <td>{{ prescripcion.cliente_nombre }}</td>
          <td>{{ prescripcion.cliente_telefono || 'N/A' }}</td>
          <td>{{ prescripcion.doctor_nombre }}</td>
          <td>{{ formatearFecha(prescripcion.fecha_prescripcion) }}</td>
          <td>
            <span v-for="(tipo, index) in prescripcion.tipos_lente" :key="index" class="badge-lente">
              {{ tipo }}
            </span>
          </td>
          <td class="acciones-tabla">
            <button @click="abrirModalDetalles(prescripcion)">Ver</button>
            <button @click="abrirModalFormularioParaEditar(prescripcion)">Editar</button>
            <button @click="eliminarPrescripcion(prescripcion.cod_prescripcion)"
              class="btn-desactivar">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-else class="sin-resultados">
      <p>No se encontraron prescripciones que coincidan con los filtros.</p>
    </div>

    <BaseModal v-model="mostrarModalFormulario" :title="tituloModalFormulario" size="lg">
      <form @submit.prevent="guardarPrescripcion" class="form-container">
        <h4 class="form-section-header">Información General</h4>
        <div class="form-grid">
          <div class="form-group">
            <label>Cliente:</label>
            <AutoComplete v-model="formData.cliente" :options="clientesOptions" placeholder="Seleccionar cliente"
              ref="clienteRef" />
          </div>
          <div class="form-group">
            <label>Código de Receta:</label>
            <input v-model="formData.cod_receta" placeholder="Código de receta (ej. R-123)" />
          </div>
          <div class="form-group">
            <label>Doctor Prescriptor:</label>
            <AutoComplete v-model="formData.doctor_prescriptor" :options="doctoresOptions"
              placeholder="Seleccionar doctor" />
          </div>
          <div class="form-group">
            <label>Fecha de Prescripción:</label>
            <input v-model="formData.fecha_prescripcion" type="date" />
          </div>
        </div>
        <h4 class="form-section-header">Medidas de Lentes</h4>
        
        <div v-for="(medida, index) in medidas" :key="index" class="medida-container">
          <div class="distancia-tipo">
            <div class="form-group">
              <label>TIPO / DISTANCIA</label>
              <AutoComplete v-model="medida.tipo_lente" :options="tipoLenteOptions"
              placeholder="Seleccionar tipo de lente" />
            </div>
            <div class="form-group"><label>DIP Binocular (mm)</label><input v-model="medida.dip_lentes_binocular" type="number"
              step="0.01" /></div>
              <div class="form-group"><label>DIP OD Mono (mm)</label><input v-model="medida.dip_lentes_od_monocular"
                type="number" step="0.01" /></div>
                <div class="form-group"><label>DIP OI Mono (mm)</label><input v-model="medida.dip_lentes_oi_monocular"
                type="number" step="0.01" /></div>
            <button type="button" @click="eliminarMedida(index)" v-if="medidas.length > 1"
              class="btn-desactivar btn-eliminar-medida">Eliminar</button>
          </div>
          
          <div class="form-column-ojos">
            <div class="ojo-section">
              <h5 class="ojo-header">Ojo Derecho (OD)</h5>
              <div class="medidas-grid">
                <div class="form-row-strict">
                  <div class="form-group"><label>ESF</label><input v-model="medida.esf_od" placeholder="ESF" /></div>
                  <div class="form-group"><label>CIL</label><input v-model="medida.cil_od" placeholder="CIL" /></div>
                  <div class="form-group"><label>EJE</label><input v-model="medida.eje_od" type="number" min="0"
                    max="180" placeholder="EJE" /></div>
                    <div class="form-group"><label>ADIC</label><input v-model="medida.adic_od" placeholder="ADIC" /></div>
                  <div class="form-group"><label>PRISMA</label><input v-model="medida.prisma_od" placeholder="PRISMA"
                    @input="onPrismaChange(medida, 'od')" /></div>
                    <div class="form-group"><label>BASE</label>
                      <AutoComplete v-model="medida.base_od" :options="baseOptions" placeholder="Base"
                      :disabled="!medida.prisma_od || medida.prisma_od === '0.00'" />
                  </div>
                  <div class="form-group"><label>ALTURA</label><input v-model="medida.altura_od" placeholder="ALTURA" />
                  </div>
                </div>
              </div>
            </div>
            <div class="ojo-section">
              <h5 class="ojo-header">Ojo Izquierdo (OI)</h5>
              <div class="medidas-grid">
                <div class="form-row-strict">
                  <div class="form-group"><label>ESF</label><input v-model="medida.esf_oi" placeholder="ESF" /></div>
                  <div class="form-group"><label>CIL</label><input v-model="medida.cil_oi" placeholder="CIL" /></div>
                  <div class="form-group"><label>EJE</label><input v-model="medida.eje_oi" type="number" min="0"
                    max="180" placeholder="EJE" /></div>
                    <div class="form-group"><label>ADIC</label><input v-model="medida.adic_oi" placeholder="ADIC" /></div>
                    <div class="form-group"><label>PRISMA</label><input v-model="medida.prisma_oi" placeholder="PRISMA"
                      @input="onPrismaChange(medida, 'oi')" /></div>
                      <div class="form-group"><label>BASE</label>
                        <AutoComplete v-model="medida.base_oi" :options="baseOptions" placeholder="Base"
                      :disabled="!medida.prisma_oi || medida.prisma_oi === '0.00'" />
                    </div>
                    <div class="form-group"><label>ALTURA</label><input v-model="medida.altura_oi" placeholder="ALTURA" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="form-section-header-container">
            <button type="button" @click="agregarMedida" class="btn-add-medida">+ Agregar Medida</button>
          </div>
          
          <h4 class="form-section-header">Notas Adicionales</h4>
          <div class="form-group">
            <textarea v-model="formData.observacion_prescripcion" placeholder="Observaciones generales..."
            rows="3"></textarea>
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
          <div><label>Nro. Receta:</label><span>{{ prescripcionSeleccionada.cod_receta }}</span></div>
          <div><label>Cliente:</label><span>{{ prescripcionSeleccionada.cliente_nombre }}</span></div>
          <div><label>Doctor:</label><span>{{ prescripcionSeleccionada.doctor_nombre }}</span></div>
          <div><label>Fecha:</label><span>{{ formatearFecha(prescripcionSeleccionada.fecha_prescripcion) }}</span></div>
        </div>
        <div
          v-if="prescripcionSeleccionada.observacion_prescripcion && prescripcionSeleccionada.observacion_prescripcion !== '-'"
          class="observaciones-detalle">
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
                  <p><span>ESF:</span> {{ medida.esf_od }} | <span>CIL:</span> {{ medida.cil_od }} | <span>EJE:</span>
                    {{
                      medida.eje_od }}</p>
                  <p><span>ADIC:</span> {{ medida.adic_od }} | <span>ALT:</span> {{ medida.altura_od }}</p>
                  <p v-if="medida.prisma_od && medida.prisma_od !== '0.00'"><span>PRISMA:</span> {{ medida.prisma_od }}
                    <span>BASE:</span> {{ medida.base_od }}
                  </p>
                </div>
                <div class="ojo-detalle">
                  <h6>Ojo Izquierdo (OI)</h6>
                  <p><span>ESF:</span> {{ medida.esf_oi }} | <span>CIL:</span> {{ medida.cil_oi }} | <span>EJE:</span>
                    {{
                      medida.eje_oi }}</p>
                  <p><span>ADIC:</span> {{ medida.adic_oi }} | <span>ALT:</span> {{ medida.altura_oi }}</p>
                  <p v-if="medida.prisma_oi && medida.prisma_oi !== '0.00'"><span>PRISMA:</span> {{ medida.prisma_oi }}
                    <span>BASE:</span> {{ medida.base_oi }}
                  </p>
                </div>
              </div>
              <div class="dip-detalle">
                <h6>DIP (mm):</h6>
                <p><span>Binocular:</span> {{ medida.dip_lentes_binocular || 'N/A' }} | <span>OD Mono:</span> {{
                  medida.dip_lentes_od_monocular || 'N/A' }} | <span>OI Mono:</span> {{ medida.dip_lentes_oi_monocular
                    ||
                    'N/A' }}</p>
              </div>
            </div>
          </div>
          <div v-else class="sin-resultados">
            <p>No hay medidas registradas para esta prescripción.</p>
          </div>
        </div>
      </div>
      <template #footer>
        <button @click="mostrarModalDetalles = false" class="btn-cancelar">Cerrar</button>
      </template>
    </BaseModal>

  </div>
</template>

<script setup>
import { ref, onMounted, reactive, computed, nextTick } from 'vue';
import { supabase } from '../lib/supabaseClient.js';
import BaseModal from './BaseModal.vue';
import AutoComplete from './Autocomplete.vue';

// --- ESTADO GENERAL ---
const prescripciones = ref([]);
const doctores = ref([]);
const clientes = ref([]);
const cargando = ref(false);
const editId = ref(null);
const clienteRef = ref(null);

// --- ESTADO PARA FILTROS ---
const filtros = reactive({
  busqueda: '',
  doctor: '',
  fechaDesde: '',
  fechaHasta: ''
});

// --- ESTADO PARA MODALES ---
const mostrarModalFormulario = ref(false);
const mostrarModalDetalles = ref(false);
const prescripcionSeleccionada = ref(null);
const medidasModal = ref([]);
const cargandoMedidas = ref(false);

// --- ESTADO PARA FORMULARIO ---
const formData = reactive({
  cod_receta: '',
  cliente: '', // Se usará el ID del cliente
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

// --- PROPIEDADES COMPUTADAS ---
const tituloModalFormulario = computed(() => editId.value ? 'Editar Prescripción' : 'Registrar Nueva Prescripción');

const prescripcionesFiltradas = computed(() => {
  return prescripciones.value.filter(p => {
    const busqueda = filtros.busqueda.toLowerCase();
    const matchBusqueda = !busqueda ||
      p.cod_receta.toLowerCase().includes(busqueda) ||
      (p.cliente_nombre && p.cliente_nombre.toLowerCase().includes(busqueda)) ||
      (p.cliente_telefono && p.cliente_telefono.toLowerCase().includes(busqueda)) ||
      (p.doctor_nombre && p.doctor_nombre.toLowerCase().includes(busqueda));

    const matchDoctor = !filtros.doctor || p.doctor_prescriptor === parseInt(filtros.doctor);

    const fechaPrescripcion = new Date(p.fecha_prescripcion + 'T00:00:00');
    const matchFechaDesde = !filtros.fechaDesde || fechaPrescripcion >= new Date(filtros.fechaDesde + 'T00:00:00');
    const matchFechaHasta = !filtros.fechaHasta || fechaPrescripcion <= new Date(filtros.fechaHasta + 'T00:00:00');

    return matchBusqueda && matchDoctor && matchFechaDesde && matchFechaHasta;
  });
});

const clientesOptions = computed(() => clientes.value.map(c => ({ value: c.cod_cliente, label: `${c.nombre_cliente} ${c.apellido_paterno_cliente}` })));
const doctoresOptions = computed(() => doctores.value.map(d => ({ value: d.cod_doctor, label: d.nombre_doctor })));
const tipoLenteOptions = ref([{ value: 'LEJOS', label: 'LEJOS' }, { value: 'CERCA', label: 'CERCA' }, { value: 'PROGRESIVO', label: 'PROGRESIVO' }, { value: 'INTERMEDIO', label: 'INTERMEDIO' }]);
const baseOptions = ref([{ value: 'NASAL', label: 'NASAL' }, { value: 'TEMPORAL', label: 'TEMPORAL' }, { value: 'SUPERIOR', label: 'SUPERIOR' }, { value: 'INFERIOR', label: 'INFERIOR' }]);

// --- CARGA DE DATOS ---
async function cargarPrescripciones() {
  cargando.value = true;
  try {
    // 1. Obtener prescripciones con datos de cliente y doctor
    const { data: presData, error: presError } = await supabase
      .from('prescripcion_cliente')
      .select(`
        *,
        clientes:cliente (nombre_cliente, apellido_paterno_cliente, telefono_cliente),
        doctores:doctor_prescriptor (nombre_doctor)
      `)
      .order('fecha_prescripcion', { ascending: false });

    if (presError) throw presError;

    // 2. Obtener todas las medidas de lentes
    const { data: medidasData, error: medidasError } = await supabase
      .from('medida_lente')
      .select('prescripcion, tipo_lente');

    if (medidasError) throw medidasError;

    // 3. Mapear las medidas a cada prescripción
    const medidasPorPrescripcion = medidasData.reduce((acc, medida) => {
      if (!acc[medida.prescripcion]) {
        acc[medida.prescripcion] = new Set();
      }
      acc[medida.prescripcion].add(medida.tipo_lente);
      return acc;
    }, {});

    // 4. Combinar todos los datos
    prescripciones.value = presData.map(p => ({
      ...p,
      cliente_nombre: p.clientes ? `${p.clientes.nombre_cliente} ${p.clientes.apellido_paterno_cliente}`.trim() : 'N/A',
      cliente_telefono: p.clientes ? p.clientes.telefono_cliente : 'N/A',
      doctor_nombre: p.doctores ? p.doctores.nombre_doctor : 'N/A',
      tipos_lente: medidasPorPrescripcion[p.cod_prescripcion] ? Array.from(medidasPorPrescripcion[p.cod_prescripcion]) : []
    }));

  } catch (error) {
    alert('Error al cargar prescripciones: ' + error.message);
  } finally {
    cargando.value = false;
  }
}

async function cargarDatosMaestros() {
  const { data: doctoresData } = await supabase.from('doctores').select('cod_doctor, nombre_doctor').order('nombre_doctor');
  doctores.value = doctoresData || [];

  const { data: clientesData } = await supabase.from('clientes').select('cod_cliente, nombre_cliente, apellido_paterno_cliente').order('nombre_cliente');
  clientes.value = clientesData || [];
}

async function cargarMedidasParaModal(codPrescripcion) {
  cargandoMedidas.value = true;
  medidasModal.value = [];
  try {
    const { data, error } = await supabase.from('medida_lente').select('*').eq('prescripcion', codPrescripcion).order('cod_medida_lente');
    if (error) throw error;
    medidasModal.value = data || [];
  } catch (error) {
    alert('Error al cargar las medidas: ' + error.message);
  } finally {
    cargandoMedidas.value = false;
  }
}

// --- GESTIÓN DE MODALES ---
const abrirModalFormularioParaCrear = () => {
  limpiarFormulario();
  mostrarModalFormulario.value = true;
  nextTick(() => clienteRef.value?.focus());
};

const abrirModalFormularioParaEditar = async (prescripcion) => {
  await cargarDatosEdicion(prescripcion);
  mostrarModalFormulario.value = true;
};

const abrirModalDetalles = async (prescripcion) => {
  prescripcionSeleccionada.value = prescripcion;
  await cargarMedidasParaModal(prescripcion.cod_prescripcion);
  mostrarModalDetalles.value = true;
};

// --- LÓGICA DEL FORMULARIO ---
function limpiarFormulario() {
  editId.value = null;
  Object.assign(formData, {
    cod_receta: '', cliente: '', doctor_prescriptor: '',
    fecha_prescripcion: new Date().toISOString().split('T')[0], observacion_prescripcion: ''
  });
  medidas.value = [getMedidaInicial()];
}

function limpiarFiltros() {
  Object.assign(filtros, { busqueda: '', doctor: '', fechaDesde: '', fechaHasta: '' });
}

function agregarMedida() {
  medidas.value.push(getMedidaInicial());
}

function eliminarMedida(index) {
  if (medidas.value.length > 1) {
    medidas.value.splice(index, 1);
  }
}

function onPrismaChange(medida, ojo) {
  const prismaKey = `prisma_${ojo}`;
  const baseKey = `base_${ojo}`;
  if (!medida[prismaKey] || medida[prismaKey].trim() === '' || medida[prismaKey] === '0.00') {
    medida[prismaKey] = '0.00';
    medida[baseKey] = null;
  }
}

// --- ACCIONES CRUD ---
async function guardarPrescripcion() {
  if (!formData.cliente) {
    alert('Debe seleccionar un cliente.');
    return;
  }
  if (medidas.value.some(m => !m.tipo_lente)) {
    alert('Todas las medidas deben tener un tipo de lente seleccionado.');
    return;
  }

  try {
    const prescripcionData = {
      cod_receta: formData.cod_receta || null,
      cliente: parseInt(formData.cliente),
      doctor_prescriptor: formData.doctor_prescriptor ? parseInt(formData.doctor_prescriptor) : null,
      fecha_prescripcion: formData.fecha_prescripcion,
      observacion_prescripcion: formData.observacion_prescripcion || '-'
    };

    if (editId.value) { // --- ACTUALIZAR ---
      const { error: errPres } = await supabase.from('prescripcion_cliente').update(prescripcionData).eq('cod_prescripcion', editId.value);
      if (errPres) throw errPres;

      await supabase.from('medida_lente').delete().eq('prescripcion', editId.value);

      const medidasData = medidas.value.map(m => ({ prescripcion: editId.value, ...prepararDatosMedida(m) }));
      const { error: errMed } = await supabase.from('medida_lente').insert(medidasData);
      if (errMed) throw errMed;
      alert('Prescripción actualizada exitosamente.');

    } else { // --- CREAR ---
      const { data: nuevaPres, error: errPres } = await supabase.from('prescripcion_cliente').insert(prescripcionData).select().single();
      if (errPres) throw errPres;

      const medidasData = medidas.value.map(m => ({ prescripcion: nuevaPres.cod_prescripcion, ...prepararDatosMedida(m) }));
      const { error: errMed } = await supabase.from('medida_lente').insert(medidasData);
      if (errMed) throw errMed;
      alert('Prescripción guardada exitosamente.');
    }

    mostrarModalFormulario.value = false;
    await cargarPrescripciones();

  } catch (error) {
    alert('Error al guardar la prescripción: ' + error.message);
  }
}

async function cargarDatosEdicion(prescripcion) {
  limpiarFormulario();
  editId.value = prescripcion.cod_prescripcion;

  Object.assign(formData, {
    cod_receta: prescripcion.cod_receta,
    cliente: prescripcion.cliente,
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
  if (!confirm('¿Está seguro de que desea eliminar esta prescripción? Esta acción es irreversible.')) return;

  try {
    await supabase.from('medida_lente').delete().eq('prescripcion', id);
    await supabase.from('prescripcion_cliente').delete().eq('cod_prescripcion', id);
    alert('Prescripción eliminada exitosamente.');
    await cargarPrescripciones();
  } catch (error) {
    alert('Error al eliminar la prescripción: ' + error.message);
  }
}

// --- FUNCIONES AUXILIARES ---
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

const formatearFecha = (fecha) => {
  if (!fecha) return 'N/A';
  const date = new Date(fecha + 'T00:00:00Z');
  return date.toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'UTC' });
};


// --- CICLO DE VIDA ---
onMounted(() => {
  cargarDatosMaestros();
  cargarPrescripciones();
});
</script>

<style scoped>
/* ESTILOS GENERALES */
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
  align-items: center;
  flex-wrap: wrap;
}

.btn-nueva-montura {
  background: #007bff;
  color: white;
}

.btn-nueva-montura:hover {
  background: #0056b3;
}

button {
  border: none;
  padding: 10px 15px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s;
}

.filtro-input,
.filtro-select {
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
}

.filtro-input {
  flex: 1 1 180px;
}

/* ESTILOS DE LA TABLA */
table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 4px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
}

th {
  background: #343a40;
  color: white;
  padding: 12px 8px;
  text-align: left;
  font-size: 13px;
  font-weight: 600;
  white-space: nowrap;
}

td {
  padding: 10px 8px;
  border-bottom: 1px solid #dee2e6;
  font-size: 13px;
  vertical-align: middle;
}

tr:hover {
  background: #f8f9fa;
}

.acciones-tabla {
  display: flex;
  gap: 5px;
  flex-wrap: nowrap;
}

td button {
  padding: 4px 8px;
  margin: 0;
  border-radius: 3px;
  font-size: 11px;
  white-space: nowrap;
}

.btn-desactivar {
  background: #dc3545;
  color: white;
}

.btn-desactivar:hover {
  background: #c82333;
}

td button:not(.btn-desactivar) {
  background: #ffc107;
  color: #212529;
}

td button:not(.btn-desactivar):hover {
  background: #e0a800;
}

.badge-lente {
  display: inline-block;
  padding: 3px 8px;
  font-size: 11px;
  font-weight: 600;
  background-color: #e9ecef;
  color: #495057;
  border-radius: 10px;
  margin-right: 4px;
  margin-bottom: 4px;
}

.loading,
.sin-resultados {
  text-align: center;
  padding: 2rem;
  color: #6c757d;
  font-size: 1.1rem;
}

/* ESTILOS PARA EL FORMULARIO EN EL MODAL */
.form-container {
  padding: 10px;
}

.form-section-header {
  font-size: 16px;
  font-weight: 600;
  color: #343a40;
  margin: 20px 0 15px 0;
  padding-bottom: 8px;
  border-bottom: 1px solid #e0e0e0;
}

.form-section-header:first-child {
  margin-top: 0;
}

/* INICIO: CAMBIO DE CSS PARA FORMULARIO */
.form-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr); /* Fila estricta de 4 columnas */
  gap: 15px;
}
/* FIN: CAMBIO DE CSS PARA FORMULARIO */

.form-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.distancia-tipo {
  display: flex;
  align-items: flex-end;
  margin-bottom: 1rem;
  gap: 1rem;
}

.form-group label {
  font-weight: 500;
  color: #333;
  font-size: 13px; /* Un poco más pequeño para caber mejor */
  white-space: nowrap;
}

.form-group input,
.form-group textarea {
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  width: 100%;
  box-sizing: border-box;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.form-section-header-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.btn-add-medida {
  margin-top: 2rem;
  padding: 10px 10px;
  font-size: 12px;
  background-color: #28a745;
  color: white;
}

.medida-container {
  border: 1px solid #e9ecef;
  border-radius: 6px;
  padding: 15px;
  margin-top: 1rem;
  background-color: #fcfcfc;
}

.btn-eliminar-medida {
  padding: 6px 10px;
  font-size: 11px;
  height: fit-content;
  margin-bottom: 2px; /* Alineación con los inputs */
}

.form-column-ojos {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.ojo-section {
  padding: 10px;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  background-color: white;
}

.ojo-header {
  font-size: 14px;
  font-weight: bold;
  margin: 0 0 10px 0;
  text-align: center;
}

.medidas-grid {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

/* INICIO: NUEVO ESTILO PARA FILA DE MEDIDAS ESTRICTA */
.form-row-strict {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 10px;
  align-items: end;
}
/* FIN: NUEVO ESTILO */

.btn-guardar {
  background: #007bff;
  color: white;
}

.btn-cancelar {
  background: #6c757d;
  color: white;
}

/* ESTILOS PARA MODAL DE DETALLES */
.detalles-content .info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1rem;
  background-color: #f8f9fa;
  padding: 1rem;
  border-radius: 6px;
}

.detalles-content .info-grid label {
  font-weight: 600;
  color: #495057;
  display: block;
  margin-bottom: 4px;
}

.observaciones-detalle {
  margin-top: 1rem;
  padding: 1rem;
  border-left: 4px solid #007bff;
  background-color: #f8f9fa;
}

.medidas-section-detalle {
  margin-top: 1rem;
}

.medida-detalle-item {
  border: 1px solid #e9ecef;
  border-radius: 8px;
  margin-bottom: 1rem;
}

.medida-header-detalle {
  padding: 0.5rem 1rem;
  background-color: #343a40;
  color: white;
  font-weight: bold;
  border-radius: 6px 6px 0 0;
}

.medidas-ojos-detalle {
  display: flex;
  gap: 1rem;
  padding: 1rem;
  flex-wrap: wrap;
}

.ojo-detalle {
  flex: 1;
  min-width: 250px;
}

.ojo-detalle h6 {
  margin-top: 0;
  border-bottom: 1px solid #eee;
  padding-bottom: 5px;
}

.ojo-detalle p,
.dip-detalle p {
  margin: 0.25rem 0;
  font-size: 0.9rem;
}

.ojo-detalle span,
.dip-detalle span {
  font-weight: 600;
  color: #555;
}

.dip-detalle {
  padding: 0.5rem 1rem;
  background-color: #f8f9fa;
  border-top: 1px solid #e9ecef;
  border-radius: 0 0 6px 6px;
}

/* RESPONSIVIDAD */
@media (max-width: 1200px) {
    /* En pantallas un poco más pequeñas, permitimos que las medidas de los ojos se dividan */
    .form-row-strict {
        grid-template-columns: repeat(4, 1fr);
    }
}

@media (max-width: 992px) {
  .form-column-ojos {
    grid-template-columns: 1fr;
  }
  .form-grid {
    grid-template-columns: repeat(2, 1fr); /* 2 columnas en tablets */
  }
}

@media (max-width: 768px) {
  .botones-arriba {
    flex-direction: column;
    align-items: stretch;
  }

  .form-grid,
  .form-row-strict {
    grid-template-columns: 1fr; /* 1 columna en móviles */
  }
}
</style>