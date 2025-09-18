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
              <button @click="eliminarPrescripcion(prescripcion.cod_prescripcion)"
                class="btn-desactivar">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-else class="sin-resultados">
        <p>Este cliente aún no tiene prescripciones registradas.</p>
      </div>
    </div>

    <BaseModal v-model="mostrarModalFormulario" :title="tituloModalFormulario" size="xl">
      <form @submit.prevent="guardarPrescripcion" class="form-container">
        <h4 class="form-section-header">Información General</h4>
        <div class="form-grid">
          <div class="form-group">
            <label>Cliente:</label>
            <input :value="clienteNombreCompleto" readonly class="form-input campo-readonly" />
          </div>
          <div class="form-group">
            <label>Código de Receta:</label>
            <input ref="recetaInputRef" v-model="formData.cod_receta" placeholder="Código de receta (ej. R-123)"
              class="form-input" />
          </div>
          <div class="form-group">
            <label>Doctor Prescriptor:</label>
            <div class="autocomplete-container">
              <AutoComplete v-model="formData.doctor_prescriptor" :options="doctoresOptions"
                placeholder="Seleccionar o escribir nuevo doctor" @search-input="handleDoctorSearch" />
              <button type="button" @click="abrirModalNuevoDoctor" class="btn-add-inline"
                title="Agregar nuevo doctor">+</button>
            </div>
          </div>
          <div class="form-group">
            <label>Fecha de Prescripción:</label>
            <input v-model="formData.fecha_prescripcion" type="date" class="form-input" />
          </div>
        </div>

        <div class="form-section-header-container">
          <h4 class="form-section-header">Medidas de Lentes</h4>
        </div>

        <div v-for="(medida, index) in medidas" :key="index" class="medida-container">
          <div class="distancia-tipo">
            <div class="form-group">
              <label>TIPO / DISTANCIA</label>
              <AutoComplete v-model="medida.tipo_lente" :options="tipoLenteDistanciaOptions"
                placeholder="Seleccionar tipo" />
            </div>
            <div class="form-group"><label>DIP Binocular (mm)</label><input v-model="medida.dip_lentes_binocular"
                type="number" step="0.01" class="form-input" /></div>
            <div class="form-group"><label>DIP OD Mono (mm)</label><input v-model="medida.dip_lentes_od_monocular"
                type="number" step="0.01" class="form-input" /></div>
            <div class="form-group"><label>DIP OI Mono (mm)</label><input v-model="medida.dip_lentes_oi_monocular"
                type="number" step="0.01" class="form-input" /></div>
            <button type="button" @click="eliminarMedida(index)" v-if="medidas.length > 1"
              class="btn-desactivar btn-eliminar-medida">Eliminar</button>
          </div>
          <div class="form-column-ojos">
            <div class="ojo-section">
              <h5 class="ojo-header">Ojo Derecho (OD)</h5>
              <div class="medidas-grid">
                <div class="form-row-strict">
                  <div class="form-group"><label>ESF</label><input v-model="medida.esf_od" placeholder="ESF"
                      class="form-input" /></div>
                  <div class="form-group"><label>CIL</label><input v-model="medida.cil_od" placeholder="CIL"
                      class="form-input" /></div>
                  <div class="form-group"><label>EJE</label><input v-model="medida.eje_od" type="number" min="0"
                      max="180" placeholder="EJE" class="form-input" /></div>
                  <div class="form-group"><label>ADIC</label><input v-model="medida.adic_od" placeholder="ADIC"
                      class="form-input" /></div>
                  <div class="form-group"><label>PRISMA</label><input v-model="medida.prisma_od" placeholder="PRISMA"
                      @input="onPrismaChange(medida, 'od')" class="form-input" /></div>
                  <div class="form-group"><label>BASE</label>
                    <AutoComplete v-model="medida.base_od" :options="baseOptions" placeholder="Base"
                      :disabled="!medida.prisma_od || medida.prisma_od === '0.00'" />
                  </div>
                  <div class="form-group"><label>ALTURA</label><input v-model="medida.altura_od" placeholder="ALTURA"
                      class="form-input" /></div>
                </div>
              </div>
            </div>
            <div class="ojo-section">
              <h5 class="ojo-header">Ojo Izquierdo (OI)</h5>
              <div class="medidas-grid">
                <div class="form-row-strict">
                  <div class="form-group"><label>ESF</label><input v-model="medida.esf_oi" placeholder="ESF"
                      class="form-input" /></div>
                  <div class="form-group"><label>CIL</label><input v-model="medida.cil_oi" placeholder="CIL"
                      class="form-input" /></div>
                  <div class="form-group"><label>EJE</label><input v-model="medida.eje_oi" type="number" min="0"
                      max="180" placeholder="EJE" class="form-input" /></div>
                  <div class="form-group"><label>ADIC</label><input v-model="medida.adic_oi" placeholder="ADIC"
                      class="form-input" /></div>
                  <div class="form-group"><label>PRISMA</label><input v-model="medida.prisma_oi" placeholder="PRISMA"
                      @input="onPrismaChange(medida, 'oi')" class="form-input" /></div>
                  <div class="form-group"><label>BASE</label>
                    <AutoComplete v-model="medida.base_oi" :options="baseOptions" placeholder="Base"
                      :disabled="!medida.prisma_oi || medida.prisma_oi === '0.00'" />
                  </div>
                  <div class="form-group"><label>ALTURA</label><input v-model="medida.altura_oi" placeholder="ALTURA"
                      class="form-input" /></div>
                </div>
              </div>
            </div>
          </div>

          <div class="cristal-section">
            <h5 class="cristal-header">Detalles del Cristal y Tratamientos</h5>
            <div class="cristal-grid">
              <div class="form-group">
                <label>Cantidad</label>
                <input v-model.number="medida.cantidad" type="number" min="1" class="form-input" />
              </div>
              <div class="form-group">
                <label>Material</label>
                <AutoComplete v-model="medida.cod_material_cristal" :options="materialesOptions"
                  placeholder="Seleccionar material" />
              </div>
              <div class="form-group">
                <label>Tipo de Cristal</label>
                <AutoComplete v-model="medida.cod_tipo_lente" :options="tiposLenteOptions"
                  placeholder="Seleccionar tipo" />
              </div>
              <div class="form-group form-group-span-2">
                <label>Tratamientos</label>
                <MultiSelect v-model="medida.tratamientos_seleccionados" :options="tratamientosOptions"
                  placeholder="Seleccionar tratamientos" />
              </div>
              <div class="form-group">
                <label>Color</label>
                <AutoComplete v-model="medida.cod_color_cristal" :options="coloresOptions"
                  placeholder="Seleccionar color" />
              </div>
              <div class="form-group">
                <label>Nro. de Sobre</label>
                <input v-model="medida.nro_sobre" placeholder="Ej. S-456" class="form-input" />
              </div>
            </div>
          </div>
        </div>

        <div class="form-section-header-container">
          <button type="button" @click="agregarMedida" class="btn-add-medida">+ Agregar Medida</button>
        </div>

        <h4 class="form-section-header">Notas Adicionales</h4>
        <div class="form-group">
          <textarea v-model="formData.observacion_prescripcion" placeholder="Observaciones generales..." rows="3"
            class="form-input"></textarea>
        </div>

        <h4 class="form-section-header">Información de Entrega y Armado</h4>
        <div class="form-grid">
          <div class="form-group">
            <label>Proveedor</label>
            <AutoComplete v-model="formData.proveedor_id" :options="proveedoresOptions"
              placeholder="Seleccionar proveedor" />
          </div>
          <div class="form-group">
            <label>Armador</label>
            <AutoComplete v-model="formData.armador_lente_id" :options="armadoresOptions"
              placeholder="Seleccionar armador" />
          </div>
          <div class="form-group">
            <label>Armazón</label>
            <AutoComplete v-model="formData.armazon_lente_id" :options="armazonesOptions"
              placeholder="Seleccionar armazón" />
          </div>
          <div class="form-group">
            <label>Fecha de Entrega</label>
            <input v-model="formData.fecha_entrega" type="date" class="form-input" />
          </div>
          <div class="form-group">
            <label>Código de Pedido</label>
            <input v-model="formData.codigo_pedido" placeholder="Ej. 15678" class="form-input" />
          </div>
        </div>
      </form>
      <template #footer>
        <button @click="guardarPrescripcion" class="btn-guardar">{{ editId ? 'Actualizar' : 'Guardar' }}</button>
        <button @click="mostrarModalFormulario = false" class="btn-cancelar">Cancelar</button>
      </template>
    </BaseModal>
    <!-- COMPONENTE MODAL - INICIO DEL MODAL -->
    <BaseModal v-model="mostrarModalDetalles" title="Detalles de Prescripción" size="lg">
      <div v-if="prescripcionSeleccionada" class="detalles-content">
        <div class="info-grid">
          <div><label>Código:</label><strong><span>{{ prescripcionSeleccionada.cod_receta }}</span></strong></div>
          <div><label>Cliente:</label><span>{{ clienteNombreCompleto }}</span></div>
          <div><label>Doctor / Medición:</label><span>{{ prescripcionSeleccionada.doctor_nombre }}</span></div>
          <div><label>Fecha de Medición:</label><span>{{ formatearFecha(prescripcionSeleccionada.fecha_prescripcion)
              }}</span></div>
        </div>

        <!--LINEA DIVISORA DE SECCIÓN-->
        <div class="elegant-divider"></div>


        <div
          v-if="prescripcionSeleccionada.proveedor_nombre || prescripcionSeleccionada.armador_nombre || prescripcionSeleccionada.armazon_nombre"
          class="entrega-detalle">
          <h4>Información de Entrega y Armado</h4>
          <div class="info-grid">
            <div v-if="prescripcionSeleccionada.proveedor_nombre"><label>Proveedor:</label><span>{{
              prescripcionSeleccionada.proveedor_nombre }}</span></div>
            <div v-if="prescripcionSeleccionada.armador_nombre"><label>Armador:</label><span>{{
              prescripcionSeleccionada.armador_nombre }}</span></div>
            <div v-if="prescripcionSeleccionada.armazon_nombre"><label>Armazón:</label><span>{{
              prescripcionSeleccionada.armazon_nombre }}</span></div>
            <div v-if="prescripcionSeleccionada.fecha_entrega"><label>Fecha Entrega:</label><span>{{
              formatearFecha(prescripcionSeleccionada.fecha_entrega) }}</span></div>
            <div v-if="prescripcionSeleccionada.codigo_pedido"><label>Número de Pedido:</label><span>{{
              prescripcionSeleccionada.codigo_pedido }}</span></div>
          </div>
        </div>
                <!--LINEA DIVISORA DE SECCIÓN-->
        <div class="elegant-divider"></div>
<!--SECCION MEDIDA Y DETALLES DE LOS CRISTALES-->
        <div class="medidas-section-detalle">
          <h4>Medidas y detalles de los Cristales</h4>
          <div v-if="cargandoMedidas" class="loading">Cargando detalles...</div>
          <div v-else-if="medidasModal.length > 0">
            <div v-for="medida in medidasModal" :key="medida.cod_medida_lente" class="medida-detalle-item">
              <div class="medida-header-detalle"><span>{{ medida.tipo_lente }}</span></div>
                            <div class="dip-detalle">
                <h6>Distancia Interpupilar:</h6>
                <p><span>DIP (mm):</span><strong>{{ medida.dip_lentes_binocular || '-' }} </strong> | <span>OD(mm):</span> {{
                  medida.dip_lentes_od_monocular || '-' }} | <span>OI(mm):</span> {{ medida.dip_lentes_oi_monocular
                  ||
                  '-' }}</p>
              </div>
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

              <div class="cristal-detalle" v-if="medida.cristal && medida.cristal.cod_cristal_medida">
                <h6>Detalles del Cristal:</h6>
                <p>
                  <span>Cantidad:</span> {{ medida.cristal.cantidad || 'N/A' }} |
                  <span>Tipo:</span> {{ medida.cristal.tipo_lente?.nombre_tipo_lente || 'N/A' }} |
                  <span>Material:</span> {{ medida.cristal.material_cristal?.nombre_material || 'N/A' }} |
                  <span>Color:</span> {{ medida.cristal.color_cristal?.nombre_color || 'N/A' }} |
                  <span>Sobre:</span> {{ medida.cristal.nro_sobre || 'N/A' }}
                </p>
                <div v-if="medida.tratamientos && medida.tratamientos.length > 0" class="tratamientos-detalle">
                  <strong>Tratamientos:</strong>
                  <span>{{medida.tratamientos.map(t => t.tratamientos.nombre_tratamiento).join(', ')}}</span>
                </div>
                <div v-if="medida.cristal.descripcion_cristal" class="descripcion-detalle">
                  <strong>Descripción:</strong>
                  <p>{{ medida.cristal.descripcion_cristal }}</p>
                </div>
              </div>
            </div>
          </div>
          <div v-else class="sin-resultados">
            <p>No hay medidas registradas para esta prescripción.</p>
          </div>
        </div>
        <!--SECCION NOTAS ADICIONALES-->
        <div
          v-if="prescripcionSeleccionada.observacion_prescripcion && prescripcionSeleccionada.observacion_prescripcion !== '-'"
          class="observaciones-detalle">

          <label class="form-section-header">Notas Adicionales:</label>
          <p>{{ prescripcionSeleccionada.observacion_prescripcion }}</p>
        </div>
      </div>
      <template #footer>
        <button @click="mostrarModalDetalles = false" class="btn-cancelar">Cerrar</button>
      </template>
    </BaseModal>

    <BaseModal v-model="mostrarModalNuevoDoctor" title="Registrar Nuevo Doctor">
      <form @submit.prevent="guardarNuevoDoctor" class="form-container">
        <div class="form-group">
          <label for="nombre_doctor_panel">Nombre Completo:</label>
          <input id="nombre_doctor_panel" v-model="nuevoDoctorData.nombre_doctor" required
            placeholder="Nombre del Doctor" class="form-input" />
        </div>
        <div class="form-group">
          <label for="telefono_doctor_panel">Teléfono:</label>
          <input id="telefono_doctor_panel" v-model="nuevoDoctorData.telefono_doctor" placeholder="Teléfono (opcional)"
            class="form-input" />
        </div>
        <div class="form-group">
          <label for="especialidad_doctor_panel">Especialidad:</label>
          <input id="especialidad_doctor_panel" v-model="nuevoDoctorData.especialidad_doctor"
            placeholder="Especialidad (opcional)" class="form-input" />
        </div>
      </form>
      <template #footer>
        <button @click="guardarNuevoDoctor" class="btn-guardar">Guardar Doctor</button>
        <button @click="mostrarModalNuevoDoctor = false" class="btn-cancelar">Cancelar</button>
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
const cliente = ref(null);
const cargandoPrescripciones = ref(false);
const prescripcionesCliente = ref([]);
const doctores = ref([]);

// --- ESTADOS PARA DATOS DE CRISTALES, TRATAMIENTOS Y NUEVOS DATOS ---
const materiales = ref([]);
const colores = ref([]);
const tiposLente = ref([]);
const tratamientos = ref([]);
const proveedores = ref([]);
const armadores = ref([]);
const armazones = ref([]);

const mostrarModalFormulario = ref(false);
const editId = ref(null);
const recetaInputRef = ref(null);

const mostrarModalDetalles = ref(false);
const prescripcionSeleccionada = ref(null);
const medidasModal = ref([]);
const cargandoMedidas = ref(false);

const formData = reactive({
  cod_receta: '',
  doctor_prescriptor: '',
  fecha_prescripcion: new Date().toISOString().split('T')[0],
  observacion_prescripcion: '',
  // Nuevos campos
  proveedor_id: null,
  armador_lente_id: null,
  armazon_lente_id: null,
  fecha_entrega: null,
  codigo_pedido: ''
});

const medidas = ref([]);

const mostrarModalNuevoDoctor = ref(false);
const nuevoDoctorData = reactive({
  nombre_doctor: '',
  telefono_doctor: '',
  especialidad_doctor: '',
});
const doctorSearchText = ref('');

const getMedidaInicial = () => ({
  tipo_lente: '', esf_od: '', cil_od: '', eje_od: 0, prisma_od: '0.00', base_od: null, altura_od: '', adic_od: '',
  esf_oi: '', cil_oi: '', eje_oi: 0, prisma_oi: '0.00', base_oi: null, altura_oi: '', adic_oi: '',
  dip_lentes_binocular: null, dip_lentes_od_monocular: null, dip_lentes_oi_monocular: null,
  cod_cristal_medida: null,
  cantidad: 2,
  cod_material_cristal: null,
  cod_color_cristal: null,
  cod_tipo_lente: null,
  nro_sobre: '',
  tratamientos_seleccionados: [],
});

const tituloModalFormulario = computed(() => editId.value ? 'Editar Prescripción' : 'Registrar Nueva Prescripción');
const clienteNombreCompleto = computed(() => cliente.value ? `${cliente.value.nombre_cliente} ${cliente.value.apellido_paterno_cliente}`.trim() : '');
const doctoresOptions = computed(() => doctores.value.map(d => ({ value: d.cod_doctor, label: d.nombre_doctor })));

// --- COMPUTED OPTIONS PARA NUEVOS CAMPOS ---
const materialesOptions = computed(() => materiales.value.map(m => ({ value: m.cod_material_cristal, label: m.nombre_material })));
const coloresOptions = computed(() => colores.value.map(c => ({ value: c.cod_color_cristal, label: c.nombre_color })));
const tiposLenteOptions = computed(() => tiposLente.value.map(t => ({ value: t.id_tipo_lente, label: t.nombre_tipo_lente })));
const tratamientosOptions = computed(() => tratamientos.value.map(t => ({ value: t.cod_tratamiento, label: t.nombre_tratamiento })));
const proveedoresOptions = computed(() => proveedores.value.map(p => ({ value: p.cod_proveedor, label: p.nombre_proveedor })));
const armadoresOptions = computed(() => armadores.value.map(a => ({ value: a.cod_armador, label: a.nombre_armador })));
const armazonesOptions = computed(() => armazones.value.map(a => ({ value: a.cod_armazon, label: a.nombre_armazon })));

const tipoLenteDistanciaOptions = ref([{ value: 'LEJOS', label: 'LEJOS' }, { value: 'CERCA', label: 'CERCA' }, { value: 'PROGRESIVO', label: 'PROGRESIVO' }, { value: 'INTERMEDIO', label: 'INTERMEDIO' }]);
const baseOptions = ref([{ value: 'NASAL', label: 'NASAL' }, { value: 'TEMPORAL', label: 'TEMPORAL' }, { value: 'SUPERIOR', label: 'SUPERIOR' }, { value: 'INFERIOR', label: 'INFERIOR' }]);

// --- FUNCIONES DE CARGA DE DATOS ---
async function getCliente() {
  const { data, error } = await supabase.from('clientes').select('*').eq('cod_cliente', clienteId.value).single();
  if (error) console.error("Error al obtener el cliente:", error);
  else cliente.value = data;
}

async function cargarPrescripcionesCliente() {
  cargandoPrescripciones.value = true;
  try {
    const { data, error } = await supabase.from('prescripcion_cliente')
      .select(`*, 
        doctores:doctor_prescriptor(nombre_doctor),
        proveedores:proveedor_id(nombre_proveedor),
        armador_lente:armador_lente_id(nombre_armador),
        armazon_lente:armazon_lente_id(nombre_armazon)
      `)
      .eq('cliente', clienteId.value)
      .order('fecha_prescripcion', { ascending: false });
    if (error) throw error;
    prescripcionesCliente.value = data.map(p => ({
      ...p,
      doctor_nombre: p.doctores ? p.doctores.nombre_doctor : 'N/A',
      proveedor_nombre: p.proveedores ? p.proveedores.nombre_proveedor : null,
      armador_nombre: p.armador_lente ? p.armador_lente.nombre_armador : null,
      armazon_nombre: p.armazon_lente ? p.armazon_lente.nombre_armazon : null,
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

// --- NUEVAS FUNCIONES DE CARGA ---
async function cargarDatosParaFormulario() {
  const [
    materialesRes,
    coloresRes,
    tiposLenteRes,
    tratamientosRes,
    proveedoresRes,
    armadoresRes,
    armazonesRes
  ] = await Promise.all([
    supabase.from('material_cristal').select('*').order('nombre_material'),
    supabase.from('color_cristal').select('*').order('nombre_color'),
    supabase.from('tipo_lente').select('*').order('nombre_tipo_lente'),
    supabase.from('tratamientos').select('*').order('nombre_tratamiento'),
    supabase.from('proveedores').select('cod_proveedor, nombre_proveedor').order('nombre_proveedor'),
    supabase.from('armador_lente').select('*').order('nombre_armador'),
    supabase.from('armazon_lente').select('*').order('nombre_armazon')
  ]);
  materiales.value = materialesRes.data || [];
  colores.value = coloresRes.data || [];
  tiposLente.value = tiposLenteRes.data || [];
  tratamientos.value = tratamientosRes.data || [];
  proveedores.value = proveedoresRes.data || [];
  armadores.value = armadoresRes.data || [];
  armazones.value = armazonesRes.data || [];
}

async function cargarMedidasParaModal(codPrescripcion) {
  cargandoMedidas.value = true;
  medidasModal.value = [];
  try {
    const { data, error } = await supabase
      .from('medida_lente')
      .select(`*, cristal:cristal_medida (*, material_cristal(nombre_material), color_cristal(nombre_color), tipo_lente(nombre_tipo_lente)), tratamientos:medida_lente_tratamiento(tratamientos(nombre_tratamiento))`)
      .eq('prescripcion', codPrescripcion)
      .order('cod_medida_lente');
    if (error) throw error;
    medidasModal.value = data.map(medida => ({ ...medida, cristal: medida.cristal[0] || null })) || [];
  } catch (error) {
    alert('Error al cargar las medidas: ' + error.message);
  } finally {
    cargandoMedidas.value = false;
  }
}

// --- MANEJO DE MODALES Y FORMULARIO ---
function abrirModalFormularioParaCrear() {
  limpiarFormulario();
  mostrarModalFormulario.value = true;
  nextTick(() => { recetaInputRef.value?.focus(); });
};

async function abrirModalFormularioParaEditar(prescripcion) {
  await cargarDatosEdicion(prescripcion);
  mostrarModalFormulario.value = true;
  nextTick(() => { recetaInputRef.value?.focus(); });
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
    fecha_prescripcion: new Date().toISOString().split('T')[0],
    observacion_prescripcion: '',
    proveedor_id: null, armador_lente_id: null, armazon_lente_id: null,
    fecha_entrega: null, codigo_pedido: ''
  });
  medidas.value = [getMedidaInicial()];
}

function agregarMedida() { medidas.value.push(getMedidaInicial()); }
function eliminarMedida(index) { if (medidas.value.length > 1) medidas.value.splice(index, 1); }

function onPrismaChange(medida, ojo) {
  const prismaKey = `prisma_${ojo}`;
  const baseKey = `base_${ojo}`;
  if (!medida[prismaKey] || medida[prismaKey].trim() === '' || medida[prismaKey] === '0.00') {
    medida[prismaKey] = '0.00';
    medida[baseKey] = null;
  }
}

async function verificarCodigoReceta(codigo) {
  if (!codigo || codigo.trim() === '' || codigo.trim() === '-') return { duplicado: false };
  let query = supabase.from('prescripcion_cliente').select(`cod_receta, clientes:cliente (nombre_cliente, apellido_paterno_cliente)`).eq('cod_receta', codigo.trim());
  if (editId.value) query = query.neq('cod_prescripcion', editId.value);
  const { data, error } = await query.limit(1).single();
  if (error && error.code !== 'PGRST116') throw new Error('No se pudo verificar el código de receta.');
  if (data) return { duplicado: true, cliente: `${data.clientes.nombre_cliente} ${data.clientes.apellido_paterno_cliente}`.trim() };
  return { duplicado: false };
}

// --- LÓGICA DE GUARDADO ---
async function guardarPrescripcion() {
  if (medidas.value.some(m => !m.tipo_lente)) { alert('Todas las medidas deben tener un tipo/distancia seleccionado.'); return; }
  if (!formData.doctor_prescriptor) { alert('Debe seleccionar un doctor.'); return; }

  try {
    const verificacion = await verificarCodigoReceta(formData.cod_receta);
    if (verificacion.duplicado) {
      alert(`El código de receta "${formData.cod_receta}" ya está en uso por el cliente: ${verificacion.cliente}.`);
      recetaInputRef.value?.focus(); return;
    }
  } catch (error) { alert(error.message); return; }

  try {
    const prescripcionData = {
      cod_receta: formData.cod_receta || '-',
      cliente: parseInt(clienteId.value),
      doctor_prescriptor: parseInt(formData.doctor_prescriptor),
      fecha_prescripcion: formData.fecha_prescripcion,
      observacion_prescripcion: formData.observacion_prescripcion || '-',
      // Nuevos campos
      proveedor_id: formData.proveedor_id || null,
      armador_lente_id: formData.armador_lente_id || null,
      armazon_lente_id: formData.armazon_lente_id || null,
      fecha_entrega: formData.fecha_entrega || null,
      codigo_pedido: formData.codigo_pedido || null,
    };

    let prescripcionId;
    if (editId.value) { // ACTUALIZAR
      const { data, error } = await supabase.from('prescripcion_cliente').update(prescripcionData).eq('cod_prescripcion', editId.value).select().single();
      if (error) throw error;
      prescripcionId = data.cod_prescripcion;
      const { data: medidasPrevias } = await supabase.from('medida_lente').select('cod_medida_lente').eq('prescripcion', prescripcionId);
      if (medidasPrevias && medidasPrevias.length > 0) {
        await supabase.from('medida_lente').delete().in('cod_medida_lente', medidasPrevias.map(m => m.cod_medida_lente));
      }
    } else { // CREAR
      const { data, error } = await supabase.from('prescripcion_cliente').insert(prescripcionData).select().single();
      if (error) throw error;
      prescripcionId = data.cod_prescripcion;
    }

    const medidasLenteData = medidas.value.map(m => prepararDatosMedida(m));
    const { data: nuevasMedidas, error: errMed } = await supabase.from('medida_lente').insert(medidasLenteData.map(m => ({ ...m, prescripcion: prescripcionId }))).select();
    if (errMed) throw errMed;

    const cristalesData = nuevasMedidas.map((nuevaMedida, index) => prepararDatosCristal(medidas.value[index], nuevaMedida.cod_medida_lente)).filter(c => c !== null);
    if (cristalesData.length > 0) {
      const { error: errCristal } = await supabase.from('cristal_medida').insert(cristalesData);
      if (errCristal) throw errCristal;
    }

    const tratamientosData = [];
    nuevasMedidas.forEach((nuevaMedida, index) => {
      medidas.value[index].tratamientos_seleccionados?.forEach(tratId => {
        tratamientosData.push({ cod_medida_lente: nuevaMedida.cod_medida_lente, cod_tratamiento: tratId });
      });
    });
    if (tratamientosData.length > 0) {
      const { error: errTrat } = await supabase.from('medida_lente_tratamiento').insert(tratamientosData);
      if (errTrat) throw errTrat;
    }

    alert(editId.value ? 'Prescripción actualizada con éxito.' : 'Prescripción guardada con éxito.');
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
    observacion_prescripcion: prescripcion.observacion_prescripcion,
    proveedor_id: prescripcion.proveedor_id,
    armador_lente_id: prescripcion.armador_lente_id,
    armazon_lente_id: prescripcion.armazon_lente_id,
    fecha_entrega: prescripcion.fecha_entrega,
    codigo_pedido: prescripcion.codigo_pedido,
  });

  const { data: medidasData, error } = await supabase.from('medida_lente').select(`*, cristal:cristal_medida(*), tratamientos:medida_lente_tratamiento(cod_tratamiento)`).eq('prescripcion', prescripcion.cod_prescripcion).order('cod_medida_lente');
  if (error) { alert("Error cargando datos para editar: " + error.message); medidas.value = [getMedidaInicial()]; return; }

  if (medidasData && medidasData.length > 0) {
    medidas.value = medidasData.map(m => {
      const cristalInfo = m.cristal && m.cristal[0] ? m.cristal[0] : {};
      return { ...m, ...cristalInfo, tratamientos_seleccionados: m.tratamientos ? m.tratamientos.map(t => t.cod_tratamiento) : [] };
    });
  } else {
    medidas.value = [getMedidaInicial()];
  }
}

async function eliminarPrescripcion(id) {
  if (!confirm('¿Está seguro de eliminar esta prescripción? Esto eliminará también todas sus medidas y detalles de cristal asociados.')) return;
  try {
    await supabase.from('prescripcion_cliente').delete().eq('cod_prescripcion', id);
    alert('Prescripción eliminada.');
    await cargarPrescripcionesCliente();
  } catch (error) {
    alert('Error al eliminar: ' + error.message);
  }
}

// --- MANEJO DE DOCTORES ---
function handleDoctorSearch(searchText) { doctorSearchText.value = searchText; }
function abrirModalNuevoDoctor() {
  Object.assign(nuevoDoctorData, { nombre_doctor: '', telefono_doctor: '', especialidad_doctor: '' });
  const esDoctorExistente = doctores.value.some(d => d.nombre_doctor.toLowerCase() === doctorSearchText.value.toLowerCase());
  if (doctorSearchText.value && !esDoctorExistente) nuevoDoctorData.nombre_doctor = doctorSearchText.value;
  mostrarModalNuevoDoctor.value = true;
}
async function guardarNuevoDoctor() {
  if (!nuevoDoctorData.nombre_doctor.trim()) { alert('El nombre del doctor no puede estar vacío.'); return; }
  try {
    const { data: nuevoDoctor, error } = await supabase.from('doctores').insert({ nombre_doctor: nuevoDoctorData.nombre_doctor.trim(), telefono_doctor: nuevoDoctorData.telefono_doctor.trim() || '-', especialidad_doctor: nuevoDoctorData.especialidad_doctor.trim() || '-' }).select().single();
    if (error) throw error;
    doctores.value.push(nuevoDoctor);
    doctores.value.sort((a, b) => a.nombre_doctor.localeCompare(b.nombre_doctor));
    formData.doctor_prescriptor = nuevoDoctor.cod_doctor;
    alert('Doctor guardado exitosamente.');
    mostrarModalNuevoDoctor.value = false;
  } catch (error) {
    alert('Error al guardar el doctor: ' + error.message);
  }
}

// --- FUNCIONES HELPERS ---
const prepararDatosMedida = (medida) => ({
  tipo_lente: medida.tipo_lente,
  esf_od: medida.esf_od || '-', cil_od: medida.cil_od || '-', eje_od: parseInt(medida.eje_od) || 0, prisma_od: medida.prisma_od || '0.00', base_od: medida.base_od || null, altura_od: medida.altura_od || '0.00', adic_od: medida.adic_od || '0.00',
  esf_oi: medida.esf_oi || '-', cil_oi: medida.cil_oi || '-', eje_oi: parseInt(medida.eje_oi) || 0, prisma_oi: medida.prisma_oi || '0.00', base_oi: medida.base_oi || null, altura_oi: medida.altura_oi || '0.00', adic_oi: medida.adic_oi || '0.00',
  dip_lentes_binocular: medida.dip_lentes_binocular ? parseFloat(medida.dip_lentes_binocular) : null,
  dip_lentes_od_monocular: medida.dip_lentes_od_monocular ? parseFloat(medida.dip_lentes_od_monocular) : null,
  dip_lentes_oi_monocular: medida.dip_lentes_oi_monocular ? parseFloat(medida.dip_lentes_oi_monocular) : null
});

const prepararDatosCristal = (medida, codMedidaLente) => {
  if (!medida.cod_material_cristal && !medida.cod_color_cristal && !medida.cod_tipo_lente && !medida.nro_sobre) return null;
  const descripciones = [];
  if (medida.cod_material_cristal) { const mat = materiales.value.find(m => m.cod_material_cristal === medida.cod_material_cristal); if (mat) descripciones.push(`Material: ${mat.nombre_material}`); }
  if (medida.cod_tipo_lente) { const tipo = tiposLente.value.find(t => t.id_tipo_lente === medida.cod_tipo_lente); if (tipo) descripciones.push(`Tipo: ${tipo.nombre_tipo_lente}`); }
  if (medida.cod_color_cristal) { const color = colores.value.find(c => c.cod_color_cristal === medida.cod_color_cristal); if (color) descripciones.push(`Color: ${color.nombre_color}`); }
  if (medida.tratamientos_seleccionados && medida.tratamientos_seleccionados.length > 0) {
    const nombresTrat = medida.tratamientos_seleccionados.map(id => tratamientos.value.find(t => t.cod_tratamiento === id)?.nombre_tratamiento).filter(Boolean);
    if (nombresTrat.length > 0) descripciones.push(`Tratamientos: ${nombresTrat.join(', ')}`);
  }
  if (medida.nro_sobre) descripciones.push(`Sobre: ${medida.nro_sobre}`);
  return {
    cod_medida_lente: codMedidaLente, cantidad: medida.cantidad || 1, cod_material_cristal: medida.cod_material_cristal || null, cod_color_cristal: medida.cod_color_cristal || null,
    cod_tipo_lente: medida.cod_tipo_lente || null, nro_sobre: medida.nro_sobre || null, descripcion_cristal: descripciones.join('; ') || null
  };
};

const formatearFecha = (fecha) => fecha ? new Date(fecha + 'T00:00:00Z').toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'UTC' }) : '';
function volver() { router.push({ name: 'GestionClientes' }); }

onMounted(() => {
  getCliente();
  cargarPrescripcionesCliente();
  cargarDoctores();
  cargarDatosParaFormulario(); // Carga todos los nuevos datos
});
</script>

<style scoped>
/* Estilos generales del panel */
.panel-container {
  padding: 24px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.cliente-info {
  color: #6c757d;
  font-size: 14px;
}

.seccion-prescripciones {
  margin-top: 2rem;
}

.seccion-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.seccion-header h2 {
  margin: 0;
}

.btn-primary {
  background: #007bff;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
}

.btn-primary:hover {
  background: #0056b3;
}

.btn-secondary {
  background: #6c757d;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
}

.btn-secondary:hover {
  background: #5a6268;
}

table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 4px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

th {
  background: #343a40;
  color: white;
  padding: 12px 8px;
  text-align: left;
  font-size: 13px;
}

td {
  padding: 10px 8px;
  border-bottom: 1px solid #dee2e6;
  font-size: 13px;
}

tr:hover {
  background: #f8f9fa;
}

.acciones-tabla {
  display: flex;
  gap: 5px;
}

td button {
  padding: 4px 8px;
  margin: 0 2px;
  border-radius: 3px;
  font-size: 11px;
  border: none;
  cursor: pointer;
}

.btn-desactivar {
  background: #dc3545;
  color: white;
}

td button:not(.btn-desactivar) {
  background: #ffc107;
  color: #212529;
}

.loading,
.sin-resultados {
  text-align: center;
  padding: 2rem;
  color: #6c757d;
  font-size: 1.1rem;
}

/* Estilos de Formulario */
.form-container {
  padding: 10px;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.campo-readonly {
  background-color: #e9ecef;
  cursor: not-allowed;
}

.form-section-header {
  font-size: 16px;
  font-weight: 600;
  margin: 20px 0 15px 0;
  padding-bottom: 8px;
  border-bottom: 1px solid #e0e0e0;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.form-group label {
  font-weight: 500;
  font-size: 13px;
  white-space: nowrap;
}

.form-input,
.form-group textarea {
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  width: 100%;
  box-sizing: border-box;
  font-size: 14px;
}

.form-section-header-container {
  margin: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.btn-add-medida {
  padding: 4px 10px;
  font-size: 12px;
  background-color: #28a745;
  color: white;
  border: none;
  cursor: pointer;
  border-radius: 4px;
}

.medida-container {
  border: 1px solid #e9ecef;
  border-radius: 6px;
  padding: 15px;
  margin-top: 1rem;
  background-color: #fcfcfc;
}

.distancia-tipo {
  display: flex;
  align-items: flex-end;
  margin-bottom: 1rem;
  gap: 1rem;
  flex-wrap: wrap;
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

.form-row-strict {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 10px;
  align-items: end;
}

.btn-guardar {
  background: #007bff;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
}

.btn-cancelar {
  background: #6c757d;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
}

.autocomplete-container {
  display: flex;
  align-items: center;
  gap: 8px;
}

.autocomplete-container> :first-child {
  flex-grow: 1;
}

.btn-add-inline {
  padding: 0;
  width: 38px;
  height: 38px;
  font-size: 20px;
  font-weight: bold;
  line-height: 38px;
  text-align: center;
  background-color: #28a745;
  color: white;
  border-radius: 4px;
  flex-shrink: 0;
  cursor: pointer;
  border: none;
}

.btn-add-inline:hover {
  background-color: #218838;
}

/* Estilos para la sección de Cristal */
.cristal-section {
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px dashed #ced4da;
}

.cristal-header {
  font-size: 14px;
  font-weight: bold;
  margin: 0 0 15px 0;
  color: #495057;
}

.cristal-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 15px;
}

.form-group-span-2 {
  grid-column: span 2;
}

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

.medidas-section-detalle {
  margin-top: 1.5rem;
}

.medida-detalle-item {
  border: 1px solid #e9ecef;
  border-radius: 8px;
  margin-bottom: 1rem;
  overflow: hidden;
}

.medida-header-detalle {
  padding: 0.5rem 1rem;
  background-color: #343a40;
  color: white;
  font-weight: bold;
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
  margin: 0.4rem 0;
  font-size: 0.9rem;
}

.ojo-detalle span,
.dip-detalle span,
.cristal-detalle span {
  font-weight: 600;
  color: #555;
}

.dip-detalle {
  padding: 0.5rem 1rem;
  background-color: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.cristal-detalle {
  padding: 0.75rem 1rem;
  background-color: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.cristal-detalle h6 {
  margin: 0 0 8px 0;
  font-size: 0.9rem;
  color: #343a40;
}

.cristal-detalle p {
  margin: 0;
  font-size: 0.9rem;
}

.tratamientos-detalle,
.descripcion-detalle {
  margin-top: 8px;
  font-size: 0.85rem;
}

.tratamientos-detalle strong,
.descripcion-detalle strong {
  display: block;
  color: #495057;
}

.descripcion-detalle p {
  font-style: italic;
  color: #6c757d;
  margin-top: 4px;
}

.entrega-detalle {
  margin-top: 1.5rem;
}

.entrega-detalle h4 {
  font-size: 1rem;
  color: #343a40;
  margin-bottom: 0.75rem;
}
.elegant-divider {
  width: 100%;
  height: 3px;
  background: linear-gradient(to right, #e0e0e0, #a0a0a0, #e0e0e0);
  border: none;
  margin: 40px 0;
  opacity: 0.7;
}

/* Media Queries para responsividad */
@media (max-width: 1200px) {
  .form-row-strict {
    grid-template-columns: repeat(4, 1fr);
  }

  .cristal-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .form-group-span-2 {
    grid-column: span 1;
  }
}

@media (max-width: 768px) {

  .form-row-strict,
  .cristal-grid {
    grid-template-columns: 1fr;
  }
}
</style>