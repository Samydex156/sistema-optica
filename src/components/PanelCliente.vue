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
        <h2> </h2>
        <div class="header-actions-group">
          <button @click="abrirModalNuevaOrden" class="btn btn-success"> + Nueva Orden </button>
          <button @click="abrirModalFormularioParaCrear" class="btn btn-primary"> + Nueva Prescripción </button>
        </div>
      </div>

      <h4 class="sub-header">Información de Cliente:</h4>
      <div v-if="cargandoPrescripciones" class="loading">Cargando prescripciones...</div>

      <div v-else-if="prescripcionesCliente.length > 0" class="prescripcion-grid">
        <div v-for="prescripcion in prescripcionesCliente" :key="prescripcion.cod_prescripcion"
          class="prescripcion-card clickable" @click="abrirModalDetalles(prescripcion)"
          title="Clic para ver detalles completos">
          <div class="card-header">
            <h4>Receta: {{ prescripcion.cod_receta || 'S/C' }}</h4>
            
            <span class="card-date">{{ formatearFecha(prescripcion.fecha_prescripcion) }}</span>
            <span class="card-date">{{ formatearFecha(prescripcion.fecha_entrega) }}</span>
          </div>
          <div class="card-body">

            <p class="card-info-item">
              <strong>Numero de sobre:</strong>
              <span>{{ prescripcion.codigo_pedido }}</span>
            </p>
            <p v-if="prescripcion.observacion_prescripcion && prescripcion.observacion_prescripcion !== '-'"
              class="card-obs">
              {{ prescripcion.observacion_prescripcion }}
            </p>
          </div>
          <div class="card-actions" @click.stop>
            <button @click="abrirModalFormularioParaEditar(prescripcion)" class="btn-action btn-edit" title="Editar">✏️
              Editar</button>
            <button @click="eliminarPrescripcion(prescripcion.cod_prescripcion)" class="btn-action btn-delete"
              title="Eliminar">🗑️ Eliminar</button>
          </div>
        </div>
      </div>

      <div v-else class="sin-resultados">
        <p>Este cliente aún no tiene prescripciones registradas.</p>
      </div>
    </div>
    
    <BaseModal v-model="mostrarModalFormulario" :title="tituloModalFormulario" size="xl">
      <form @submit.prevent="guardarPrescripcion" class="form-container">
        <div class="form-grid-4-col">
          <div class="form-group">
            <input :value="clienteNombreCompleto" readonly class="form-input campo-readonly" />
          </div>
          <div class="form-group">
            <input ref="recetaInputRef" v-model="formData.cod_receta" placeholder="Código Receta Ej. 1234-A"
              class="form-input" />
          </div>
          <div class="form-group">
            <div class="autocomplete-container">
              <AutoComplete v-model="formData.doctor_prescriptor" :options="doctoresOptions"
                placeholder="Doctor Prescriptor" @search-input="handleDoctorSearch" />
              <button type="button" @click="abrirModalNuevoDoctor" class="btn-add-inline"
                title="Agregar nuevo doctor">+</button>
            </div>
          </div>
          <div class="form-group">
            <input v-model="formData.fecha_prescripcion" type="date" class="form-input" />
          </div>
        </div>

        <div class="medidas-grid-container">
          <div class="medida-columna">
            <div class="medida-header">Medidas Lente 1</div>
            <div class="tipo-dip-grupo">
              <div class="form-group">
                <AutoComplete v-model="medidas[0].tipo_lente" :options="tipoLenteDistanciaOptions" placeholder="DISTANCIA" />
              </div>
              <div class="form-group">
                <input v-model="medidas[0].dip_lentes_binocular" class="form-input" placeholder="DIP" />
              </div>
            </div>
            <div class="ojos-fila">
              <div class="ojo-grupo">
                <label class="ojo-label">OD</label>
                <input v-model="medidas[0].esf_od" placeholder="ESF" class="form-input" />
                <input v-model="medidas[0].cil_od" placeholder="CIL" class="form-input" />
                <input v-model="medidas[0].eje_od" placeholder="EJE" type="number" min="0" max="180" class="form-input" />
              </div>
              <div class="ojo-grupo">
                <label class="ojo-label">OI</label>
                <input v-model="medidas[0].esf_oi" placeholder="ESF" class="form-input" />
                <input v-model="medidas[0].cil_oi" placeholder="CIL" class="form-input" />
                <input v-model="medidas[0].eje_oi" placeholder="EJE" type="number" min="0" max="180" class="form-input" />
              </div>
            </div>
          </div>
          <div class="medida-columna">
            <div class="medida-header">Medidas Lente 2</div>
            <div class="tipo-dip-grupo">
               <div class="form-group">
                <AutoComplete v-model="medidas[1].tipo_lente" :options="tipoLenteDistanciaOptions" placeholder="DISTANCIA" />
              </div>
              <div class="form-group">
                <input v-model="medidas[1].dip_lentes_binocular" class="form-input" placeholder="DIP" />
              </div>
            </div>
            <div class="ojos-fila">
              <div class="ojo-grupo">
                <label class="ojo-label">OD</label>
                <input v-model="medidas[1].esf_od" placeholder="ESF" class="form-input" />
                <input v-model="medidas[1].cil_od" placeholder="CIL" class="form-input" />
                <input v-model="medidas[1].eje_od" placeholder="EJE" type="number" min="0" max="180" class="form-input" />
              </div>
              <div class="ojo-grupo">
                <label class="ojo-label">OI</label>
                <input v-model="medidas[1].esf_oi" placeholder="ESF" class="form-input" />
                <input v-model="medidas[1].cil_oi" placeholder="CIL" class="form-input" />
                <input v-model="medidas[1].eje_oi" placeholder="EJE" type="number" min="0" max="180" class="form-input" />
              </div>
            </div>
          </div>
        </div>

        <div class="cristales-grid-container">
            <label class="cristal-row-label">Cristal 1:</label>
            <div class="form-group"><input v-model.number="medidas[0].cantidad" type="number" min="1" class="form-input" /></div>
            <div class="form-group"><AutoComplete v-model="medidas[0].cod_material_cristal" :options="materialesOptions" placeholder="Material" /></div>
            <div class="form-group"><AutoComplete v-model="medidas[0].cod_tipo_lente" :options="tiposLenteOptions" placeholder="Tipo"/></div>
            <div class="form-group"><MultiSelect v-model="medidas[0].tratamientos_seleccionados" :options="tratamientosOptions" placeholder="Tratamientos" /></div>
            <div class="form-group"><AutoComplete v-model="medidas[0].cod_color_cristal" :options="coloresOptions" placeholder="Color"/></div>
            <div class="form-group"><input v-model="medidas[0].nota_extra_cristal" class="form-input" placeholder="Nota Adicional"/></div>
            
            <label class="cristal-row-label">Cristal 2:</label>
            <div class="form-group"><input v-model.number="medidas[1].cantidad" type="number" min="1" class="form-input" /></div>
            <div class="form-group"><AutoComplete v-model="medidas[1].cod_material_cristal" :options="materialesOptions" placeholder="Material"/></div>
            <div class="form-group"><AutoComplete v-model="medidas[1].cod_tipo_lente" :options="tiposLenteOptions" placeholder="Tipo" /></div>
            <div class="form-group"><MultiSelect v-model="medidas[1].tratamientos_seleccionados" :options="tratamientosOptions" placeholder="Tratamientos"/></div>
            <div class="form-group"><AutoComplete v-model="medidas[1].cod_color_cristal" :options="coloresOptions" placeholder="Color"/></div>
            <div class="form-group"><input v-model="medidas[1].nota_extra_cristal" class="form-input" placeholder="Nota Adicional"/></div>
        </div>

        <div class="form-grid-5-col">
          <div class="form-group"> <AutoComplete v-model="formData.proveedor_id" :options="proveedoresOptions" placeholder="Proveedor" /></div>
          <div class="form-group"> <AutoComplete v-model="formData.armador_lente_id" :options="armadoresOptions" placeholder="Armador" /></div>
          <div class="form-group"> <AutoComplete v-model="formData.armazon_lente_id" :options="armazonesOptions" placeholder="Armazón"/></div>
          <div class="form-group"><input v-model="formData.fecha_entrega" type="date" class="form-input" placeholder="Fecha entrega"/></div>
          <div class="form-group"><input v-model="formData.codigo_pedido" type="text" class="form-input" placeholder="Núm. Sobre"/></div>
          <div class="form-group"><input v-model="medidas[0].nro_sobre" class="form-input" placeholder="Núm. Pedido 1" /></div>
          <div class="form-group"><input v-model="medidas[1].nro_sobre" class="form-input" placeholder="Núm. Pedido 2"/></div>
        </div>

        <div class="form-group">
          <textarea v-model="formData.observacion_prescripcion" rows="2" class="form-input" placeholder="Observaciones, notas o medidas adicionales"></textarea>
        </div>
      </form>
      <template #footer>
        <button @click="guardarPrescripcion" class="btn-guardar">{{ editId ? 'Actualizar' : 'Guardar' }}</button>
        <button @click="mostrarModalFormulario = false" class="btn-cancelar">Cancelar</button>
      </template>
    </BaseModal>

    <BaseModal v-model="mostrarModalDetalles" title="Detalles de la Prescripción" size="xl">
      <div v-if="cargandoMedidas" class="loading">Cargando detalles...</div>
      <div v-else-if="prescripcionSeleccionada" class="details-view-container">
        <div class="form-grid-4-col">
          <div class="detail-field"><span class="detail-label">Cliente</span><span class="detail-value readonly">{{ clienteNombreCompleto }}</span></div>
          <div class="detail-field"><span class="detail-label">Cód. Receta</span><span class="detail-value">{{ prescripcionSeleccionada.cod_receta || '-' }}</span></div>
          <div class="detail-field"><span class="detail-label">Doctor</span><span class="detail-value">{{ prescripcionSeleccionada.doctor_nombre || '-' }}</span></div>
          <div class="detail-field"><span class="detail-label">Fecha Medición</span><span class="detail-value">{{ formatearFecha(prescripcionSeleccionada.fecha_prescripcion) }}</span></div>
        </div>

        <div class="medidas-grid-container">
          <template v-for="(medida, index) in medidasModal" :key="`medida-view-${index}`">
            <div v-if="medida.tipo_lente" class="medida-columna">
              <div class="medida-header">Medidas Lente {{ index + 1 }}</div>
              <div class="tipo-dip-grupo">
                <div class="detail-field vertical"><span class="detail-label">Distancia</span><span class="detail-value">{{ medida.tipo_lente || '-' }}</span></div>
                <div class="detail-field vertical"><span class="detail-label">DIP</span><span class="detail-value">{{ medida.dip_lentes_binocular || '-' }}</span></div>
              </div>
              <div class="ojos-fila">
                <div class="ojo-grupo">
                  <label class="ojo-label">OD</label>
                  <div class="detail-field-ojo"><span class="detail-label-ojo">ESF</span><span class="detail-value-ojo">{{ medida.esf_od || '-' }}</span></div>
                  <div class="detail-field-ojo"><span class="detail-label-ojo">CIL</span><span class="detail-value-ojo">{{ medida.cil_od || '-' }}</span></div>
                  <div class="detail-field-ojo"><span class="detail-label-ojo">EJE</span><span class="detail-value-ojo">{{ medida.eje_od || '-' }}</span></div>
                </div>
                <div class="ojo-grupo">
                  <label class="ojo-label">OI</label>
                  <div class="detail-field-ojo"><span class="detail-label-ojo">ESF</span><span class="detail-value-ojo">{{ medida.esf_oi || '-' }}</span></div>
                  <div class="detail-field-ojo"><span class="detail-label-ojo">CIL</span><span class="detail-value-ojo">{{ medida.cil_oi || '-' }}</span></div>
                  <div class="detail-field-ojo"><span class="detail-label-ojo">EJE</span><span class="detail-value-ojo">{{ medida.eje_oi || '-' }}</span></div>
                </div>
              </div>
            </div>
          </template>
        </div>
        
        <div class="cristales-grid-container view-mode">
          <template v-for="(medida, index) in medidasModal" :key="`cristal-view-${index}`">
              <template v-if="medida.cristal || (medida.tratamientos && medida.tratamientos.length > 0)">
                  <label class="cristal-row-label">Cristal {{ index + 1 }}:</label>
                  <div class="detail-field vertical"><span class="detail-label">Cant.</span><span class="detail-value">{{ medida.cristal?.cantidad || '-' }}</span></div>
                  <div class="detail-field vertical"><span class="detail-label">Material</span><span class="detail-value">{{ medida.cristal?.material_cristal?.nombre_material || '-' }}</span></div>
                  <div class="detail-field vertical"><span class="detail-label">Tipo</span><span class="detail-value">{{ medida.cristal?.tipo_lente?.nombre_tipo_lente || '-' }}</span></div>
                  <div class="detail-field vertical" style="grid-column: span 1;"><span class="detail-label">Tratamientos</span><span class="detail-value">{{ medida.tratamientos?.map(t => t.tratamientos.nombre_tratamiento).join(', ') || '-' }}</span></div>
                  <div class="detail-field vertical"><span class="detail-label">Color</span><span class="detail-value">{{ medida.cristal?.color_cristal?.nombre_color || '-' }}</span></div>
                  <div class="detail-field vertical"><span class="detail-label">Nota Adicional</span><span class="detail-value">{{ medida.cristal?.nota_extra_cristal || '-' }}</span></div>
              </template>
          </template>
        </div>

        <div class="form-grid-5-col">
          <div class="detail-field"><span class="detail-label">Proveedor</span><span class="detail-value">{{ prescripcionSeleccionada.proveedor_nombre || '-' }}</span></div>
          <div class="detail-field"><span class="detail-label">Armador</span><span class="detail-value">{{ prescripcionSeleccionada.armador_nombre || '-' }}</span></div>
          <div class="detail-field"><span class="detail-label">Armazón</span><span class="detail-value">{{ prescripcionSeleccionada.armazon_nombre || '-' }}</span></div>
          <div class="detail-field"><span class="detail-label">Fecha Entrega</span><span class="detail-value">{{ formatearFecha(prescripcionSeleccionada.fecha_entrega) || '-' }}</span></div>
          <div class="detail-field"><span class="detail-label">Núm. Sobre</span><span class="detail-value">{{ prescripcionSeleccionada.codigo_pedido || '-' }}</span></div>
          <div class="detail-field"><span class="detail-label">Núm. Pedido 1</span><span class="detail-value">{{ medidasModal[0]?.cristal?.nro_sobre || '-' }}</span></div>
          <div class="detail-field"><span class="detail-label">Núm. Pedido 2</span><span class="detail-value">{{ medidasModal[1]?.cristal?.nro_sobre || '-' }}</span></div>
        </div>

        <div class="detail-field-full">
          <span class="detail-label">Observaciones, notas o medidas adicionales</span>
          <p class="detail-value-obs">{{ prescripcionSeleccionada.observacion_prescripcion || 'Sin observaciones.' }}</p>
        </div>
      </div>
      <template #footer>
        <button @click="exportarAPDF" class="btn-export-pdf">Exportar a PDF</button>
        <button @click="exportarAExcel" class="btn-export-excel">Exportar a Excel</button>
        <button @click="mostrarModalDetalles = false" class="btn-cancelar">Cerrar</button>
      </template>
    </BaseModal>


    <BaseModal v-model="mostrarModalNuevoDoctor" title="Registrar Nuevo Doctor">
      <form @submit.prevent="guardarNuevoDoctor" class="form-container">
        <div class="form-group"><label for="nombre_doctor_panel">Nombre Completo:</label><input id="nombre_doctor_panel" v-model="nuevoDoctorData.nombre_doctor" required class="form-input" /></div>
        <div class="form-group"><label for="telefono_doctor_panel">Teléfono:</label><input id="telefono_doctor_panel" v-model="nuevoDoctorData.telefono_doctor" class="form-input" /></div>
        <div class="form-group"><label for="especialidad_doctor_panel">Especialidad:</label><input id="especialidad_doctor_panel" v-model="nuevoDoctorData.especialidad_doctor" class="form-input" /></div>
      </form>
      <template #footer>
        <button @click="guardarNuevoDoctor" class="btn-guardar">Guardar Doctor</button>
        <button @click="mostrarModalNuevoDoctor = false" class="btn-cancelar">Cancelar</button>
      </template>
    </BaseModal>

    <BaseModal v-model="showModalOrden" title="Crear Nueva Orden de Trabajo" size="lg">
      <p class="orden-cliente-info"><strong>Cliente:</strong> {{ clienteNombreCompleto }}</p>
      <h4 class="form-section-header">Información de la Orden</h4>
      <div class="form-grid-orden-info">
        <div class="form-group"><label>Nro. Sobre/Boleta *</label><input ref="nroSobreOrdenInput" v-model="formOrden.nro_boleta_sobre" type="number" class="form-input" /></div>
        <div class="form-group"><label>Fecha Pedido</label><input v-model="formOrden.fecha_pedido" type="date" class="form-input" @change="actualizarFechaEntrega" /></div>
        <div class="form-group"><label>Fecha Entrega</label><input v-model="formOrden.fecha_entrega" type="date" class="form-input" /></div>
        <div class="form-group"><label>Hora Entrega</label><input v-model="formOrden.hora_entrega" type="time" class="form-input" /></div>
      </div>
      <h4 class="form-section-header">Detalles Financieros</h4>
      <div class="form-grid-orden-financiero">
        <div class="form-group"><label>Monto Total (Bs.)</label><input v-model="formOrden.monto_total" type="number" step="0.01" @input="calcularSaldo" class="form-input" /></div>
        <div class="form-group"><label>A Cuenta (Bs.)</label><input v-model="formOrden.monto_acuenta" type="number" step="0.01" @input="calcularSaldo" class="form-input" /></div>
        <div class="form-group"><label>Saldo (Bs.)</label><input v-model="formOrden.monto_saldo" type="number" step="0.01" readonly class="form-input campo-readonly" /></div>
      </div>
      <h4 class="form-section-header">Notas Adicionales</h4>
      <div class="form-group full-width"><textarea v-model="formOrden.observaciones_orden" rows="2" class="form-input"></textarea></div>
      <template #footer>
        <button @click="cerrarModalOrden" class="btn-cancelar">Cancelar</button>
        <button @click="guardarOrdenTrabajo" class="btn-guardar">Guardar Orden</button>
      </template>
    </BaseModal>
  </div>
</template>

<script setup>
// --- START: Importaciones y Configuración Inicial ---
import { ref, onMounted, reactive, computed, nextTick, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { supabase } from '../lib/supabaseClient';
import BaseModal from './BaseModal.vue';
import AutoComplete from './Autocomplete.vue';
import MultiSelect from './MultiSelect.vue';
import * as XLSX from 'xlsx';
import jsPDF from 'jspdf';
import 'jspdf-autotable';

const route = useRoute();
const router = useRouter();
const clienteId = ref(route.params.id);
// --- END: Importaciones y Configuración Inicial ---

// --- START: Estado del Componente (Datos Principales) ---
const cliente = ref(null);
const prescripcionesCliente = ref([]);
const doctores = ref([]);
const materiales = ref([]);
const colores = ref([]);
const tiposLente = ref([]);
const tratamientos = ref([]);
const proveedores = ref([]);
const armadores = ref([]);
const armazones = ref([]);
const tiendaUsuario = ref(null);
// --- END: Estado del Componente (Datos Principales) ---

// --- START: Refs para valores predeterminados ---
const defaultProveedorId = ref(null);
const defaultArmadorId = ref(null);
const defaultArmazonId = ref(null);
// --- END: Refs para valores predeterminados ---


// --- START: Estado de la UI (Modales, Cargas, Refs) ---
const cargandoPrescripciones = ref(false);
const cargandoMedidas = ref(false);
const mostrarModalFormulario = ref(false);
const mostrarModalDetalles = ref(false); // Vuelve a ser el controlador del modal de detalles
const mostrarModalNuevoDoctor = ref(false);
const showModalOrden = ref(false);
const editId = ref(null);
const recetaInputRef = ref(null);
const nroSobreOrdenInput = ref(null);
const prescripcionSeleccionada = ref(null);
const medidasModal = ref([]);
const doctorSearchText = ref('');
// --- END: Estado de la UI (Modales, Cargas, Refs) ---

// --- START: Estado de Formularios (Datos Reactivos) ---
const formData = reactive({
  cod_receta: '',
  doctor_prescriptor: '',
  fecha_prescripcion: new Date().toISOString().split('T')[0],
  observacion_prescripcion: '',
  proveedor_id: null, 
  armador_lente_id: null, 
  armazon_lente_id: null,
  fecha_entrega: new Date().toISOString().split('T')[0],
  codigo_pedido: ''
});

const getMedidaInicial = () => ({
  tipo_lente: '', 
  esf_od: '', cil_od: '', eje_od: '',
  esf_oi: '', cil_oi: '', eje_oi: '',
  dip_lentes_binocular: '',
  cantidad: 2, 
  cod_material_cristal: null, 
  cod_color_cristal: null, 
  cod_tipo_lente: null,
  nro_sobre: '', 
  nota_extra_cristal: '',
  tratamientos_seleccionados: [],
});
const medidas = ref([getMedidaInicial(), getMedidaInicial()]);


const nuevoDoctorData = reactive({ nombre_doctor: '', telefono_doctor: '', especialidad_doctor: '' });
const formOrden = ref({
  nro_boleta_sobre: "", cliente: "", tienda: "", fecha_pedido: new Date().toISOString().split('T')[0],
  fecha_entrega: "", hora_entrega: "16:00", monto_total: 0, monto_acuenta: 0, monto_saldo: 0,
  observaciones_orden: "", estado_orden: "PENDIENTE"
});
// --- END: Estado de Formularios (Datos Reactivos) ---

// --- START: Propiedades Computadas y Opciones de Selectores ---
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
// --- END: Propiedades Computadas y Opciones de Selectores ---

// --- START: Observadores para establecer valores por defecto ---
watch(proveedores, (newVal) => {
  if (newVal) {
    const optalvision = newVal.find(p => p.nombre_proveedor.toUpperCase() === 'OPTALVISION');
    if (optalvision) defaultProveedorId.value = optalvision.cod_proveedor;
  }
});
watch(armadores, (newVal) => {
  if (newVal) {
    const jaime = newVal.find(a => a.nombre_armador.toUpperCase() === 'JAIME');
    if (jaime) defaultArmadorId.value = jaime.cod_armador;
  }
});
watch(armazones, (newVal) => {
  if (newVal) {
    const propio = newVal.find(a => a.nombre_armazon.toUpperCase() === 'PROPIO');
    if (propio) defaultArmazonId.value = propio.cod_armazon;
  }
});
// --- END: Observadores para establecer valores por defecto ---

// --- START: Ciclo de Vida del Componente ---
onMounted(async () => {
  await inicializarPanel();
});
// --- END: Ciclo de Vida del Componente ---

// --- START: Lógica de API (Llamadas a Supabase) ---
const api = {
  getCliente: () => supabase.from('clientes').select('*').eq('cod_cliente', clienteId.value).single(),
  getPrescripciones: () => supabase.from('prescripcion_cliente').select(`*, doctores:doctor_prescriptor(nombre_doctor), proveedores:proveedor_id(nombre_proveedor), armador_lente:armador_lente_id(nombre_armador), armazon_lente:armazon_lente_id(nombre_armazon)`).eq('cliente', clienteId.value).order('fecha_prescripcion', { ascending: false }),
  getDoctores: () => supabase.from('doctores').select('cod_doctor, nombre_doctor').order('nombre_doctor'),
  getDatosFormulario: () => Promise.all([
    supabase.from('material_cristal').select('*').order('nombre_material'),
    supabase.from('color_cristal').select('*').order('nombre_color'),
    supabase.from('tipo_lente').select('*').order('nombre_tipo_lente'),
    supabase.from('tratamientos').select('*').order('nombre_tratamiento'),
    supabase.from('proveedores').select('cod_proveedor, nombre_proveedor').order('nombre_proveedor'),
    supabase.from('armador_lente').select('*').order('nombre_armador'),
    supabase.from('armazon_lente').select('*').order('nombre_armazon')
  ]),
  getMedidasDePrescripcion: (id) => supabase.from('medida_lente').select(`*, cristal:cristal_medida (*, material_cristal(nombre_material), color_cristal(nombre_color), tipo_lente(nombre_tipo_lente)), tratamientos:medida_lente_tratamiento(*, tratamientos(nombre_tratamiento))`).eq('prescripcion', id).order('cod_medida_lente'),
  getTiendaUsuario: () => supabase.from("tiendas").select("cod_tienda").limit(1).single(),
  verificarCodigoReceta: (codigo, idExcluir) => {
    let query = supabase.from('prescripcion_cliente').select(`cod_receta, clientes:cliente (nombre_cliente, apellido_paterno_cliente)`).eq('cod_receta', codigo.trim());
    if (idExcluir) query = query.neq('cod_prescripcion', idExcluir);
    return query.limit(1).single();
  },
  upsertPrescripcion: (data, id) => id ? supabase.from('prescripcion_cliente').update(data).eq('cod_prescripcion', id).select().single() : supabase.from('prescripcion_cliente').insert(data).select().single(),
  deleteMedidasByPrescripcionId: async (id) => {
    const { data: medidasDB } = await supabase.from('medida_lente').select('cod_medida_lente').eq('prescripcion', id);
    if (medidasDB?.length > 0) {
      await supabase.from('medida_lente').delete().in('medida_lente', medidasDB.map(m => m.cod_medida_lente));
    }
  },
  insertMedidas: (data) => supabase.from('medida_lente').insert(data).select(),
  insertCristales: (data) => supabase.from('cristal_medida').insert(data),
  insertTratamientos: (data) => supabase.from('medida_lente_tratamiento').insert(data),
  deletePrescripcion: (id) => supabase.from('prescripcion_cliente').delete().eq('cod_prescripcion', id),
};
// --- END: Lógica de API (Llamadas a Supabase) ---

// --- START: Lógica de Inicialización ---
async function inicializarPanel() {
  cargandoPrescripciones.value = true;
  try {
    const [{ data: clienteData }, { data: prescripcionesData }, { data: doctoresData }, formSelectsData, { data: tiendaData }] = await Promise.all([
      api.getCliente(),
      api.getPrescripciones(),
      api.getDoctores(),
      api.getDatosFormulario(),
      api.getTiendaUsuario()
    ]);

    cliente.value = clienteData;
    prescripcionesCliente.value = (prescripcionesData || []).map(p => ({ ...p, doctor_nombre: p.doctores?.nombre_doctor || 'N/A', proveedor_nombre: p.proveedores?.nombre_proveedor, armador_nombre: p.armador_lente?.nombre_armador, armazon_nombre: p.armazon_lente?.nombre_armazon }));
    doctores.value = doctoresData || [];
    [materiales.value, colores.value, tiposLente.value, tratamientos.value, proveedores.value, armadores.value, armazones.value] = formSelectsData.map(res => res.data || []);
    tiendaUsuario.value = tiendaData?.cod_tienda;
  } catch (error) {
    alert("Error al inicializar el panel: " + error.message);
  } finally {
    cargandoPrescripciones.value = false;
  }
}
async function recargarPrescripciones() {
  cargandoPrescripciones.value = true;
  try {
    const { data, error } = await api.getPrescripciones();
    if (error) throw error;
    prescripcionesCliente.value = (data || []).map(p => ({ ...p, doctor_nombre: p.doctores?.nombre_doctor || 'N/A', proveedor_nombre: p.proveedores?.nombre_proveedor, armador_nombre: p.armador_lente?.nombre_armador, armazon_nombre: p.armazon_lente?.nombre_armazon }));
  } catch (error) {
    alert('Error al recargar prescripciones: ' + error.message);
  } finally {
    cargandoPrescripciones.value = false;
  }
}
// --- END: Lógica de Inicialización ---

// --- START: Lógica de Prescripciones (CRUD y Formularios) ---
async function guardarPrescripcion() {
  const medidasValidas = medidas.value.filter(m => m.tipo_lente);

  if (medidasValidas.length === 0 || !formData.doctor_prescriptor) {
    alert('Asegúrese de seleccionar un doctor y de que al menos una medida tenga un TIPO/DISTANCIA.');
    return;
  }

  try {
    if (formData.cod_receta) {
      const { data: recetaExistente, error: errReceta } = await api.verificarCodigoReceta(formData.cod_receta, editId.value);
      if (errReceta && errReceta.code !== 'PGRST116') throw new Error('No se pudo verificar el código de receta.');
      if (recetaExistente) {
        alert(`El código de receta "${formData.cod_receta}" ya está en uso por el cliente: ${recetaExistente.clientes.nombre_cliente} ${recetaExistente.clientes.apellido_paterno_cliente}`.trim());
        recetaInputRef.value?.focus();
        return;
      }
    }

    const { data: prescripcionGuardada, error } = await upsertPrescription();
    if (error) throw error;

    await processMedidasAndDetails(prescripcionGuardada.cod_prescripcion, medidasValidas);

    alert(editId.value ? 'Prescripción actualizada con éxito.' : 'Prescripción guardada con éxito.');
    mostrarModalFormulario.value = false;
    await recargarPrescripciones();
  } catch (error) {
    alert('Error al guardar la prescripción: ' + error.message);
  }
}

function upsertPrescription() {
  const prescripcionData = {
    cliente: parseInt(clienteId.value),
    cod_receta: formData.cod_receta || '-',
    doctor_prescriptor: parseInt(formData.doctor_prescriptor),
    fecha_prescripcion: formData.fecha_prescripcion,
    observacion_prescripcion: formData.observacion_prescripcion || '-',
    proveedor_id: formData.proveedor_id || null,
    armador_lente_id: formData.armador_lente_id || null,
    armazon_lente_id: formData.armazon_lente_id || null,
    fecha_entrega: formData.fecha_entrega || null,
    codigo_pedido: formData.codigo_pedido || null,
  };
  return api.upsertPrescripcion(prescripcionData, editId.value);
}

async function processMedidasAndDetails(prescripcionId, medidasValidas) {
  if (editId.value) {
    await api.deleteMedidasByPrescripcionId(prescripcionId);
  }

  const medidasData = medidasValidas.map(m => ({ ...prepararDatosMedida(m), prescripcion: prescripcionId }));
  const { data: nuevasMedidas, error: errMed } = await api.insertMedidas(medidasData);
  if (errMed) throw errMed;

  const cristalesData = nuevasMedidas.map((medida, index) => prepararDatosCristal(medidasValidas[index], medida.cod_medida_lente)).filter(Boolean);
  if (cristalesData.length > 0) {
    const { error: errCristal } = await api.insertCristales(cristalesData);
    if (errCristal) throw errCristal;
  }

  const tratamientosData = nuevasMedidas.flatMap((medida, index) =>
    (medidasValidas[index].tratamientos_seleccionados || []).map(tratId => ({
      cod_medida_lente: medida.cod_medida_lente,
      cod_tratamiento: tratId
    }))
  );
  if (tratamientosData.length > 0) {
    const { error: errTrat } = await api.insertTratamientos(tratamientosData);
    if (errTrat) throw errTrat;
  }
}

async function eliminarPrescripcion(id) {
  if (!confirm('¿Está seguro de eliminar esta prescripción? Esto eliminará también todas sus medidas y detalles de cristal asociados.')) return;
  try {
    const { error } = await api.deletePrescripcion(id);
    if (error) throw error;
    alert('Prescripción eliminada.');
    await recargarPrescripciones();
  } catch (error) {
    alert('Error al eliminar: ' + error.message);
  }
}
// --- END: Lógica de Prescripciones (CRUD y Formularios) ---

// --- START: Lógica de Orden de Trabajo ---
function abrirModalNuevaOrden() {
  limpiarFormularioOrden();
  showModalOrden.value = true;
  nextTick(() => { nroSobreOrdenInput.value?.focus(); });
}
function cerrarModalOrden() { showModalOrden.value = false; }
function limpiarFormularioOrden() {
  const hoy = new Date().toISOString().split('T')[0];
  formOrden.value = {
    nro_boleta_sobre: "", cliente: clienteId.value, tienda: tiendaUsuario.value, fecha_pedido: hoy,
    fecha_entrega: "", hora_entrega: "16:00", monto_total: 0, monto_acuenta: 0, monto_saldo: 0,
    observaciones_orden: "", estado_orden: "PENDIENTE"
  };
  actualizarFechaEntrega();
}
async function guardarOrdenTrabajo() {
  if (!formOrden.value.nro_boleta_sobre) { alert("El número de sobre es requerido"); return; }
  if (!tiendaUsuario.value) { alert("No se ha podido asignar una tienda a la orden. Recargue la página."); return; }
  const ordenData = {
    nro_boleta_sobre: parseInt(formOrden.value.nro_boleta_sobre), cliente: parseInt(formOrden.value.cliente),
    tienda: tiendaUsuario.value, fecha_pedido: formOrden.value.fecha_pedido,
    fecha_entrega: formOrden.value.fecha_entrega || null, hora_entrega: formOrden.value.hora_entrega || null,
    monto_total: parseFloat(formOrden.value.monto_total) || 0, monto_acuenta: parseFloat(formOrden.value.monto_acuenta) || 0,
    monto_saldo: parseFloat(formOrden.value.monto_saldo) || 0, observaciones_orden: formOrden.value.observaciones_orden || null,
    estado_orden: formOrden.value.estado_orden
  };
  try {
    const { error } = await supabase.from("orden_trabajo").insert(ordenData);
    if (error) {
      if (error.code === '23505') { alert("Error: Ya existe una orden con este número de sobre."); }
      else { throw error; }
    } else {
      alert("Orden de trabajo creada exitosamente");
      cerrarModalOrden();
    }
  } catch (error) {
    alert("Error al crear la orden: " + error.message);
  }
}
function actualizarFechaEntrega() {
  if (formOrden.value.fecha_pedido) {
    const fechaPedido = new Date(formOrden.value.fecha_pedido + 'T00:00:00');
    fechaPedido.setDate(fechaPedido.getDate() + 2);
    formOrden.value.fecha_entrega = fechaPedido.toISOString().split('T')[0];
  }
}
function calcularSaldo() {
  const total = parseFloat(formOrden.value.monto_total) || 0;
  const acuenta = parseFloat(formOrden.value.monto_acuenta) || 0;
  formOrden.value.monto_saldo = total - acuenta;
}
// --- END: Lógica de Orden de Trabajo ---

// --- START: Lógica de Doctores ---
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
// --- END: Lógica de Doctores ---

// --- START: Manejadores de Modales y UI ---
function limpiarFormularioPrescripcion() {
  editId.value = null;
  const hoy = new Date().toISOString().split('T')[0];
  Object.assign(formData, {
    cod_receta: '', 
    doctor_prescriptor: '', 
    fecha_prescripcion: hoy,
    observacion_prescripcion: '', 
    proveedor_id: defaultProveedorId.value, 
    armador_lente_id: defaultArmadorId.value, 
    armazon_lente_id: defaultArmazonId.value,
    fecha_entrega: hoy, 
    codigo_pedido: ''
  });
  
  medidas.value = [getMedidaInicial(), getMedidaInicial()];
  medidas.value[0].tipo_lente = 'LEJOS';
}

function abrirModalFormularioParaCrear() {
  limpiarFormularioPrescripcion();
  mostrarModalFormulario.value = true;
  nextTick(() => { recetaInputRef.value?.focus(); });
};

async function abrirModalFormularioParaEditar(prescripcion) {
  limpiarFormularioPrescripcion();
  editId.value = prescripcion.cod_prescripcion;
  Object.assign(formData, {
    cod_receta: prescripcion.cod_receta, 
    doctor_prescriptor: prescripcion.doctor_prescriptor,
    fecha_prescripcion: prescripcion.fecha_prescripcion, 
    observacion_prescripcion: prescripcion.observacion_prescripcion,
    proveedor_id: prescripcion.proveedor_id, 
    armador_lente_id: prescripcion.armador_lente_id,
    armazon_lente_id: prescripcion.armazon_lente_id, 
    fecha_entrega: prescripcion.fecha_entrega || new Date().toISOString().split('T')[0],
    codigo_pedido: prescripcion.codigo_pedido,
  });

  const { data: medidasData, error } = await api.getMedidasDePrescripcion(prescripcion.cod_prescripcion);
  if (error) { alert("Error cargando datos para editar: " + error.message); return; }

  const medidasCargadas = (medidasData || []).map(m => {
    const cristalInfo = m.cristal && m.cristal[0] ? m.cristal[0] : {};
    const { tipo_lente: _tipoLenteCristal, ...restoCristalInfo } = cristalInfo;
    return { 
      ...getMedidaInicial(), ...m, ...restoCristalInfo,
      tratamientos_seleccionados: m.tratamientos ? m.tratamientos.map(t => t.cod_tratamiento) : []
    };
  });
  
  medidas.value = [
    medidasCargadas[0] || getMedidaInicial(),
    medidasCargadas[1] || getMedidaInicial()
  ];

  mostrarModalFormulario.value = true;
  nextTick(() => { recetaInputRef.value?.focus(); });
};

async function abrirModalDetalles(prescripcion) {
  prescripcionSeleccionada.value = prescripcion;
  mostrarModalDetalles.value = true;
  cargandoMedidas.value = true;
  medidasModal.value = [];
  try {
    const { data, error } = await api.getMedidasDePrescripcion(prescripcion.cod_prescripcion);
    if (error) throw error;
    
    const medidasCompletas = Array(2).fill(null);
    const dataMapeada = (data || []).map(medida => ({ ...medida, cristal: medida.cristal[0] || null }));
    
    dataMapeada.forEach((medida, index) => {
        if (index < 2) {
            medidasCompletas[index] = medida;
        }
    });

    medidasModal.value = medidasCompletas;

  } catch (error) {
    alert('Error al cargar las medidas: ' + error.message);
  } finally {
    cargandoMedidas.value = false;
  }
};
// --- END: Manejadores de Modales y UI ---

// --- START: Lógica de Exportación ---
function exportarAExcel() {
  if (!prescripcionSeleccionada.value) return;
  try {
    const prescripcion = prescripcionSeleccionada.value;
    const dataParaExportar = [];

    dataParaExportar.push(['Información General']);
    dataParaExportar.push(['Cliente', clienteNombreCompleto.value]);
    dataParaExportar.push(['Código Receta', prescripcion.cod_receta]);
    dataParaExportar.push(['Doctor', prescripcion.doctor_nombre]);
    dataParaExportar.push(['Fecha Medición', formatearFecha(prescripcion.fecha_prescripcion)]);
    dataParaExportar.push([]);

    dataParaExportar.push(['Entrega y Armado']);
    dataParaExportar.push(['Proveedor', prescripcion.proveedor_nombre || '-']);
    dataParaExportar.push(['Armador', prescripcion.armador_nombre || '-']);
    dataParaExportar.push(['Armazón', prescripcion.armazon_nombre || '-']);
    dataParaExportar.push(['Fecha Entrega', formatearFecha(prescripcion.fecha_entrega) || '-']);
    dataParaExportar.push(['Número de sobre', prescripcion.codigo_pedido || '-']);
    dataParaExportar.push([]);

    dataParaExportar.push(['Medidas y Cristales']);
    const headersMedidas = ['Tipo', 'Ojo', 'ESF', 'CIL', 'EJE', 'DIP', 'Cristal', 'Tratamientos'];
    dataParaExportar.push(headersMedidas);

    medidasModal.value.forEach(medida => {
      if (!medida) return;
      const dip = medida.dip_lentes_binocular || '-';
      const nota = medida.cristal?.nota_extra_cristal ? `, Nota: ${medida.cristal.nota_extra_cristal}` : '';
      const cristal = medida.cristal ? `Cant:${medida.cristal.cantidad}, Mat:${medida.cristal.material_cristal?.nombre_material}, Tipo:${medida.cristal.tipo_lente?.nombre_tipo_lente}${nota}` : '-';
      const tratamientos = medida.tratamientos?.map(t => t.tratamientos?.nombre_tratamiento).filter(Boolean).join(', ') || '-';

      dataParaExportar.push([medida.tipo_lente, 'OD', medida.esf_od, medida.cil_od, medida.eje_od, dip, cristal, tratamientos]);
      dataParaExportar.push(['', 'OI', medida.esf_oi, medida.cil_oi, medida.eje_oi, '', '', '']);
    });
    dataParaExportar.push([]);

    if (prescripcion.observacion_prescripcion && prescripcion.observacion_prescripcion !== '-') {
      dataParaExportar.push(['Notas Adicionales']);
      dataParaExportar.push([prescripcion.observacion_prescripcion]);
    }

    const workbook = XLSX.utils.book_new();
    const worksheet = XLSX.utils.aoa_to_sheet(dataParaExportar);
    worksheet['!cols'] = [{ wch: 20 }, { wch: 5 }, { wch: 10 }, { wch: 10 }, { wch: 10 }, { wch: 10 }, { wch: 40 }, { wch: 40 }];
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Prescripción');
    XLSX.writeFile(workbook, `Prescripcion_${clienteNombreCompleto.value.replace(' ', '_')}_${prescripcion.cod_receta || 'SC'}.xlsx`);

  } catch (error) {
    console.error("Error al exportar a Excel:", error);
    alert("Ocurrió un error al intentar generar el archivo Excel.");
  }
}

function exportarAPDF() {
  if (!prescripcionSeleccionada.value) return;
  try {
    const prescripcion = prescripcionSeleccionada.value;
    const doc = new jsPDF();
    let verticalOffset = 15;

    doc.setFontSize(18);
    doc.text(`Prescripción Óptica - ${clienteNombreCompleto.value || ''}`, 14, verticalOffset);
    verticalOffset += 10;

    doc.setFontSize(11);
    doc.text(`Código Receta: ${prescripcion.cod_receta || '-'}`, 14, verticalOffset);
    doc.text(`Proveedor: ${prescripcion.proveedor_nombre || '-'}`, 105, verticalOffset);
    verticalOffset += 7;
    doc.text(`Doctor: ${prescripcion.doctor_nombre || '-'}`, 14, verticalOffset);
    doc.text(`Armador: ${prescripcion.armador_nombre || '-'}`, 105, verticalOffset);
    verticalOffset += 7;
    doc.text(`Fecha Medición: ${formatearFecha(prescripcion.fecha_prescripcion)}`, 14, verticalOffset);
    doc.text(`Armazón: ${prescripcion.armazon_nombre || '-'}`, 105, verticalOffset);
    verticalOffset += 7;
    doc.text(`Cód. Pedido: ${prescripcion.codigo_pedido || '-'}`, 14, verticalOffset);
    doc.text(`Fecha Entrega: ${formatearFecha(prescripcion.fecha_entrega) || '-'}`, 105, verticalOffset);
    verticalOffset += 12;

    let finalY = verticalOffset;

    if (medidasModal.value && medidasModal.value.some(m => m)) {
        const head = [['Tipo', 'Ojo', 'ESF', 'CIL', 'EJE', 'DIP']];
        const body = [];
        
        medidasModal.value.forEach(medida => {
            if (!medida) return;
            const dip = medida.dip_lentes_binocular || '-';
            
            body.push([ { content: medida.tipo_lente || '-', rowSpan: 2 }, 'OD', medida.esf_od || '-', medida.cil_od || '-', medida.eje_od || '-', { content: dip, rowSpan: 2 }]);
            body.push(['OI', medida.esf_oi || '-', medida.cil_oi || '-', medida.eje_oi || '-']);

            const cristal = medida.cristal ? `Cristal: ${medida.cristal.material_cristal?.nombre_material || 'N/A'}, ${medida.cristal.tipo_lente?.nombre_tipo_lente || 'N/A'}` : 'Sin detalles de cristal.';
            const tratamientos = medida.tratamientos?.length > 0 ? `Tratamientos: ${medida.tratamientos.map(t => t.tratamientos?.nombre_tratamiento).filter(Boolean).join(', ')}` : '';
            const nota = medida.cristal?.nota_extra_cristal ? `Nota: ${medida.cristal.nota_extra_cristal}`: '';

            const cellContent = [cristal, tratamientos, nota].filter(Boolean).join('\n');
            
            body.push([{ content: cellContent, colSpan: 6, styles: { fillColor: [245, 245, 245], fontSize: 9 } }]);
        });

        doc.autoTable({
            startY: verticalOffset,
            head: head,
            body: body,
            theme: 'grid',
            headStyles: { fillColor: [22, 160, 133] },
        });
        finalY = doc.autoTable.previous.finalY;
    } else {
        doc.text('No hay medidas registradas para esta prescripción.', 14, finalY);
        finalY += 10;
    }
    
    if (prescripcion.observacion_prescripcion && prescripcion.observacion_prescripcion !== '-') {
        doc.setFontSize(12);
        doc.text('Notas Adicionales:', 14, finalY + 10);
        doc.setFontSize(10);
        doc.text(prescripcion.observacion_prescripcion, 14, finalY + 16, { maxWidth: 180 });
    }

    doc.save(`Prescripcion_${clienteNombreCompleto.value.replace(' ', '_')}_${prescripcion.cod_receta || 'SC'}.pdf`);

  } catch(error) {
    console.error("Error al exportar a PDF:", error);
    alert("Ocurrió un error al intentar generar el archivo PDF.");
  }
}
// --- END: Lógica de Exportación ---

// --- START: Funciones de Ayuda (Helpers) ---
const prepararDatosMedida = (medida) => ({
  tipo_lente: medida.tipo_lente,
  esf_od: medida.esf_od || '-', 
  cil_od: medida.cil_od || '-', 
  eje_od: parseInt(medida.eje_od) || 0,
  esf_oi: medida.esf_oi || '-', 
  cil_oi: medida.cil_oi || '-', 
  eje_oi: parseInt(medida.eje_oi) || 0,
  dip_lentes_binocular: medida.dip_lentes_binocular || null,
});

const prepararDatosCristal = (medida, codMedidaLente) => {
  if (!medida.cod_material_cristal && !medida.cod_color_cristal && !medida.cod_tipo_lente && !medida.nro_sobre && !medida.nota_extra_cristal) return null;
  return {
    cod_medida_lente: codMedidaLente, 
    cantidad: medida.cantidad || 1, 
    cod_material_cristal: medida.cod_material_cristal || null, 
    cod_color_cristal: medida.cod_color_cristal || null,
    cod_tipo_lente: medida.cod_tipo_lente || null, 
    nro_sobre: medida.nro_sobre || null,
    nota_extra_cristal: medida.nota_extra_cristal || null,
  };
};

const formatearFecha = (fecha) => fecha ? new Date(fecha + 'T00:00:00Z').toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'UTC' }) : '';
function volver() { router.push({ name: 'GestionClientes' }); }
// --- END: Funciones de Ayuda (Helpers) ---
</script>

<style scoped>
/* ESTILOS GENERALES Y DE PANEL (sin cambios) */
.panel-container { padding: 24px; }
.panel-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem; }
.cliente-info { color: #6c757d; font-size: 14px; }
.loading, .sin-resultados { text-align: center; padding: 2rem; color: #6c757d; font-size: 1.1rem; }
.elegant-divider { width: 100%; height: 1px; background-color: #dee2e6; margin: 24px 0; }
.seccion-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 1rem; }
.header-actions-group { display: flex; gap: 10px; }
.sub-header { margin-top: 2rem; margin-bottom: 1rem; color: #495057; font-weight: 500; }

/* ESTILOS DE BOTONES (sin cambios) */
.btn-primary, .btn-secondary, .btn-success, .btn-guardar, .btn-cancelar { color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-size: 14px; }
.btn-primary { background: #007bff; } .btn-primary:hover { background: #0056b3; }
.btn-secondary { background: #6c757d; } .btn-secondary:hover { background: #5a6268; }
.btn-success { background: #28a745; } .btn-success:hover { background: #218838; }
.btn-guardar { background: #007bff; }
.btn-cancelar { background: #6c757d; }

/* ESTILOS DE TARJETAS (sin cambios) */
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

/* ESTILOS DE FORMULARIOS (sin cambios) */
.form-container, .details-view-container { display: flex; flex-direction: column; gap: 1rem; }
.form-group { display: flex; flex-direction: column; gap: 4px; }
.form-input, .form-group textarea { padding: 6px 10px; border: 1px solid #ced4da; border-radius: 4px; width: 100%; box-sizing: border-box; font-size: 12px; }
.form-input:focus-within, .form-group textarea:focus-within { border-color: #80bdff; box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25); }
.campo-readonly { background-color: #e9ecef; cursor: not-allowed; }
.autocomplete-container { display: flex; align-items: center; gap: 6px; }
.autocomplete-container> :first-child { flex-grow: 1; }
.btn-add-inline { padding: 0; width: 31px; height: 31px; font-size: 18px; background-color: #28a745; color: white; border-radius: 4px; flex-shrink: 0; cursor: pointer; border: none; }
.btn-add-inline:hover { background-color: #218838; }

/* ESTRUCTURA DE GRID PARA FORMULARIO Y VISTA DE DETALLES (sin cambios) */
.form-grid-4-col, .form-grid-5-col,
.medidas-grid-container, .medida-columna, .tipo-dip-grupo, .ojos-fila, .ojo-grupo,
.cristales-grid-container {
  display: grid;
}
.form-grid-4-col { grid-template-columns: repeat(4, 1fr); gap: 12px 8px; }
.form-grid-5-col { grid-template-columns: repeat(7, 1fr); gap: 12px 8px; }
.medidas-grid-container { grid-template-columns: 1fr 1fr; gap: 40px; background-color: #f8f9fa; padding: 10px; border-radius: 8px; border: 1px solid #e9ecef; }
.medida-columna { grid-template-areas: "header header" "tipo-dip medidas-ojo"; grid-template-columns: 85px 1fr; gap: 5px 2px; align-items: start; }
.medida-header { grid-area: header; font-weight: 600; color: #505050; padding-bottom: 4px; margin-bottom: 4px; border-bottom: 1px solid #dee2e6; }
.tipo-dip-grupo { grid-area: tipo-dip; display: flex; flex-direction: column; gap: 12px; }
.ojos-fila { grid-area: medidas-ojo; display: flex; flex-direction: column; gap: 8px; }
.ojo-grupo { grid-template-columns: 30px 1fr 1fr 1fr; gap: 6px; align-items: center; }
.ojo-label { font-weight: bold; font-size: 12px; text-align: center; }
.cristales-grid-container { grid-template-columns: 60px 70px 1fr 1fr 1.5fr 1fr 1fr; gap: 5px 8px; align-items: center; }
.cristales-grid-container.view-mode { align-items: stretch; }
.cristal-row-label { font-size: 12px; font-weight: 600; text-align: right; padding-right: 10px; }

/* NUEVOS ESTILOS PARA LA VISTA DE DETALLES */
.detail-field, .detail-field-full, .detail-field-ojo {
  background-color: #f8f9fa;
  border: 1px solid #e9ecef;
  padding: 6px 10px;
  border-radius: 4px;
  font-size: 12px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-height: 31px; /* Coincide con la altura del input */
}
.detail-field.vertical {
    gap: 2px;
}
.detail-field-ojo {
  flex-direction: column;
  text-align: center;
  padding: 2px 4px;
}
.detail-label, .detail-label-ojo {
  font-size: 9px;
  color: #6c757d;
  font-weight: 500;
}
.detail-value, .detail-value-ojo {
  font-weight: 600;
  color: #343a40;
  word-wrap: break-word;
}
.detail-value.readonly {
    background-color: #e9ecef;
    padding: 0 4px;
    border-radius: 2px;
}
.detail-field-full {
  width: 100%;
}
.detail-value-obs {
  font-weight: 500;
  white-space: pre-wrap;
  margin: 4px 0 0 0;
  padding: 8px;
  background-color: #f8f9fa;
  border-radius: 4px;
  min-height: 40px;
}

/* OTROS ESTILOS (sin cambios) */
.form-group.full-width { grid-column: 1 / -1; }
.form-grid-orden-info { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 16px; }
.form-grid-orden-financiero { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 16px; }
.orden-cliente-info { font-size: 1rem; padding: 10px 14px; background-color: #e7f3ff; border: 1px solid #b3d7ff; border-radius: 6px; margin-bottom: 16px; }
.btn-export-pdf, .btn-export-excel { color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-size: 14px; margin-right: 10px; }
.btn-export-pdf { background-color: #dc3545; } .btn-export-pdf:hover { background-color: #c82333; }
.btn-export-excel { background-color: #217346; } .btn-export-excel:hover { background-color: #1c623b; }

/* MEDIA QUERIES (sin cambios) */
@media (max-width: 1300px) { .form-grid-5-col { grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); } }
@media (max-width: 1100px) { .form-grid-4-col { grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); } }
@media (max-width: 992px) { .medidas-grid-container { grid-template-columns: 1fr; } .medida-columna { grid-template-areas: "header" "tipo-dip" "medidas-ojo"; grid-template-columns: 1fr; } }
@media (max-width: 768px) { .cristales-grid-container { grid-template-columns: 1fr 1fr; gap: 8px; } .cristal-row-label { grid-column: 1 / -1; text-align: left; padding: 4px 0; background-color: #e9ecef; padding-left: 10px; border-radius: 4px; margin-top: 8px; } .cristales-grid-container .form-group, .cristales-grid-container .detail-field { grid-column: span 2; } }
</style>