<template>
  <div class="panel-container">
    <!-- START: Header del Panel del Cliente -->
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
    <!-- END: Header del Panel del Cliente -->

    <div class="elegant-divider"></div>

    <!-- START: Sección de Acciones y Listado de Prescripciones -->
    <div class="seccion-prescripciones">
      <div class="seccion-header">
        <h2>Acciones del Cliente</h2>
        <div class="header-actions-group">
          <button @click="abrirModalNuevaOrden" class="btn btn-success"> + Nueva Orden </button>
          <button @click="abrirModalFormularioParaCrear" class="btn btn-primary"> + Nueva Prescripción </button>
        </div>
      </div>

      <h4 class="sub-header">Prescripciones Registradas</h4>
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
              <strong>Doctor:</strong>
              <span>{{ prescripcion.doctor_nombre }}</span>
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
    <!-- END: Sección de Acciones y Listado de Prescripciones -->

    <!-- START: Modal de Formulario para Prescripción (Crear/Editar) -->
    <BaseModal v-model="mostrarModalFormulario" :title="tituloModalFormulario" size="xl">
      <form @submit.prevent="guardarPrescripcion" class="form-container">
        <!-- START: Formulario - Información General -->
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
        <!-- END: Formulario - Información General -->

        <!-- START: Formulario - Medidas de Lentes -->
        <h4 class="form-section-header">Medidas de Lentes</h4>
        <div v-for="(medida, index) in medidas" :key="index" class="medida-container">
          <!-- Tipo y DIP -->
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
          <!-- Medidas por Ojo -->
          <div class="form-column-ojos">
            <div class="ojo-section">
              <h5 class="ojo-header">Ojo Derecho (OD)</h5>
              <div class="form-row-strict">
                <div class="form-group"><label>ESF</label><input v-model="medida.esf_od" class="form-input" /></div>
                <div class="form-group"><label>CIL</label><input v-model="medida.cil_od" class="form-input" /></div>
                <div class="form-group"><label>EJE</label><input v-model="medida.eje_od" type="number" min="0" max="180"
                    class="form-input" /></div>
                <div class="form-group"><label>ADIC</label><input v-model="medida.adic_od" class="form-input" /></div>
                <div class="form-group"><label>PRISMA</label><input v-model="medida.prisma_od"
                    @input="onPrismaChange(medida, 'od')" class="form-input" /></div>
                <div class="form-group"><label>BASE</label>
                  <AutoComplete v-model="medida.base_od" :options="baseOptions" placeholder="Base"
                    :disabled="!medida.prisma_od || medida.prisma_od === '0.00'" />
                </div>
                <div class="form-group"><label>ALTURA</label><input v-model="medida.altura_od" class="form-input" />
                </div>
              </div>
            </div>
            <div class="ojo-section">
              <h5 class="ojo-header">Ojo Izquierdo (OI)</h5>
              <div class="form-row-strict">
                <div class="form-group"><label>ESF</label><input v-model="medida.esf_oi" class="form-input" /></div>
                <div class="form-group"><label>CIL</label><input v-model="medida.cil_oi" class="form-input" /></div>
                <div class="form-group"><label>EJE</label><input v-model="medida.eje_oi" type="number" min="0" max="180"
                    class="form-input" /></div>
                <div class="form-group"><label>ADIC</label><input v-model="medida.adic_oi" class="form-input" /></div>
                <div class="form-group"><label>PRISMA</label><input v-model="medida.prisma_oi"
                    @input="onPrismaChange(medida, 'oi')" class="form-input" /></div>
                <div class="form-group"><label>BASE</label>
                  <AutoComplete v-model="medida.base_oi" :options="baseOptions" placeholder="Base"
                    :disabled="!medida.prisma_oi || medida.prisma_oi === '0.00'" />
                </div>
                <div class="form-group"><label>ALTURA</label><input v-model="medida.altura_oi" class="form-input" />
                </div>
              </div>
            </div>
          </div>
          <!-- Detalles del Cristal -->
          <div class="cristal-section">
            <h5 class="cristal-header">Detalles del Cristal y Tratamientos</h5>
            <div class="cristal-grid">
              <div class="form-group"><label>Cantidad</label><input v-model.number="medida.cantidad" type="number"
                  min="1" class="form-input" /></div>
              <div class="form-group"><label>Material</label>
                <AutoComplete v-model="medida.cod_material_cristal" :options="materialesOptions" />
              </div>
              <div class="form-group"><label>Tipo de Cristal</label>
                <AutoComplete v-model="medida.cod_tipo_lente" :options="tiposLenteOptions" />
              </div>
              <div class="form-group form-group-span-2"><label>Tratamientos</label>
                <MultiSelect v-model="medida.tratamientos_seleccionados" :options="tratamientosOptions" />
              </div>
              <div class="form-group"><label>Color</label>
                <AutoComplete v-model="medida.cod_color_cristal" :options="coloresOptions" />
              </div>
              <div class="form-group"><label>Nro. de Sobre</label><input v-model="medida.nro_sobre" class="form-input" />
              </div>
            </div>
          </div>
        </div>
        <div class="form-section-header-container">
          <button type="button" @click="agregarMedida" class="btn-add-medida">+ Agregar Medida</button>
        </div>
        <!-- END: Formulario - Medidas de Lentes -->

        <!-- START: Formulario - Secciones Adicionales -->
        <h4 class="form-section-header">Notas Adicionales</h4>
        <div class="form-group">
          <textarea v-model="formData.observacion_prescripcion" rows="3" class="form-input"></textarea>
        </div>
        <h4 class="form-section-header">Información de Entrega y Armado</h4>
        <div class="form-grid">
          <div class="form-group"><label>Proveedor</label>
            <AutoComplete v-model="formData.proveedor_id" :options="proveedoresOptions" />
          </div>
          <div class="form-group"><label>Armador</label>
            <AutoComplete v-model="formData.armador_lente_id" :options="armadoresOptions" />
          </div>
          <div class="form-group"><label>Armazón</label>
            <AutoComplete v-model="formData.armazon_lente_id" :options="armazonesOptions" />
          </div>
          <div class="form-group"><label>Fecha de Entrega</label><input v-model="formData.fecha_entrega" type="date"
              class="form-input" /></div>
          <div class="form-group"><label>Código de Pedido</label><input v-model="formData.codigo_pedido" type="text"
              class="form-input" /></div>
        </div>
        <!-- END: Formulario - Secciones Adicionales -->

      </form>
      <template #footer>
        <button @click="guardarPrescripcion" class="btn-guardar">{{ editId ? 'Actualizar' : 'Guardar' }}</button>
        <button @click="mostrarModalFormulario = false" class="btn-cancelar">Cancelar</button>
      </template>
    </BaseModal>
    <!-- END: Modal de Formulario para Prescripción (Crear/Editar) -->

    <!-- START: Modal de Detalles de Prescripción -->
    <BaseModal v-model="mostrarModalDetalles" title="Detalles de Prescripción" size="lg">
      <div v-if="prescripcionSeleccionada" class="detalles-content">
        <div class="info-grid">
          <div><label>Código:</label><strong><span>{{ prescripcionSeleccionada.cod_receta }}</span></strong></div>
          <div><label>Cliente:</label><span>{{ clienteNombreCompleto }}</span></div>
          <div><label>Doctor / Medición:</label><span>{{ prescripcionSeleccionada.doctor_nombre }}</span></div>
          <div><label>Fecha de Medición:</label><span>{{ formatearFecha(prescripcionSeleccionada.fecha_prescripcion)
              }}</span></div>
        </div>
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
        <div class="elegant-divider"></div>
        <div class="medidas-section-detalle">
          <h4>Medidas y detalles de los Cristales</h4>
          <div v-if="cargandoMedidas" class="loading">Cargando detalles...</div>
          <div v-else-if="medidasModal.length > 0">
            <div v-for="medida in medidasModal" :key="medida.cod_medida_lente" class="medida-detalle-item">
              <div class="medida-header-detalle"><span>{{ medida.tipo_lente }}</span></div>
              <div class="dip-detalle">
                <h6>Distancia Interpupilar:</h6>
                <p><span>DIP (mm):</span><strong>{{ medida.dip_lentes_binocular || '-' }} </strong> |
                  <span>OD(mm):</span>{{ medida.dip_lentes_od_monocular || '-' }} | <span>OI(mm):</span> {{
                  medida.dip_lentes_oi_monocular || '-' }}</p>
              </div>
              <div class="medidas-ojos-detalle">
                <div class="ojo-detalle">
                  <h6>Ojo Derecho (OD)</h6>
                  <p><span>ESF:</span> {{ medida.esf_od }} | <span>CIL:</span> {{ medida.cil_od }} | <span>EJE:</span>{{
                    medida.eje_od }}</p>
                  <p><span>ADIC:</span> {{ medida.adic_od }} | <span>ALT:</span> {{ medida.altura_od }}</p>
                  <p v-if="medida.prisma_od && medida.prisma_od !== '0.00'"><span>PRISMA:</span> {{ medida.prisma_od }}
                    <span>BASE:</span> {{ medida.base_od }}</p>
                </div>
                <div class="ojo-detalle">
                  <h6>Ojo Izquierdo (OI)</h6>
                  <p><span>ESF:</span> {{ medida.esf_oi }} | <span>CIL:</span> {{ medida.cil_oi }} | <span>EJE:</span>{{
                    medida.eje_oi }}</p>
                  <p><span>ADIC:</span> {{ medida.adic_oi }} | <span>ALT:</span> {{ medida.altura_oi }}</p>
                  <p v-if="medida.prisma_oi && medida.prisma_oi !== '0.00'"><span>PRISMA:</span> {{ medida.prisma_oi }}
                    <span>BASE:</span> {{ medida.base_oi }}</p>
                </div>
              </div>
              <div class="cristal-detalle" v-if="medida.cristal && medida.cristal.cod_cristal_medida">
                <h6>Detalles del Cristal:</h6>
                <p><span>Cantidad:</span> {{ medida.cristal.cantidad || 'N/A' }} | <span>Tipo:</span> {{
                  medida.cristal.tipo_lente?.nombre_tipo_lente || 'N/A' }} | <span>Material:</span> {{
                  medida.cristal.material_cristal?.nombre_material || 'N/A' }} | <span>Color:</span> {{
                  medida.cristal.color_cristal?.nombre_color || 'N/A' }} | <span>Sobre:</span> {{
                  medida.cristal.nro_sobre || 'N/A' }}</p>
                <div v-if="medida.tratamientos && medida.tratamientos.length > 0" class="tratamientos-detalle">
                  <strong>Tratamientos:</strong>
                  <span>{{medida.tratamientos.map(t => t.tratamientos.nombre_tratamiento).join(', ')}}</span>
                </div>
              </div>
            </div>
          </div>
          <div v-else class="sin-resultados">
            <p>No hay medidas registradas para esta prescripción.</p>
          </div>
        </div>
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
    <!-- END: Modal de Detalles de Prescripción -->

    <!-- START: Modal para Registrar Nuevo Doctor -->
    <BaseModal v-model="mostrarModalNuevoDoctor" title="Registrar Nuevo Doctor">
      <form @submit.prevent="guardarNuevoDoctor" class="form-container">
        <div class="form-group">
          <label for="nombre_doctor_panel">Nombre Completo:</label>
          <input id="nombre_doctor_panel" v-model="nuevoDoctorData.nombre_doctor" required class="form-input" />
        </div>
        <div class="form-group">
          <label for="telefono_doctor_panel">Teléfono:</label>
          <input id="telefono_doctor_panel" v-model="nuevoDoctorData.telefono_doctor" class="form-input" />
        </div>
        <div class="form-group">
          <label for="especialidad_doctor_panel">Especialidad:</label>
          <input id="especialidad_doctor_panel" v-model="nuevoDoctorData.especialidad_doctor" class="form-input" />
        </div>
      </form>
      <template #footer>
        <button @click="guardarNuevoDoctor" class="btn-guardar">Guardar Doctor</button>
        <button @click="mostrarModalNuevoDoctor = false" class="btn-cancelar">Cancelar</button>
      </template>
    </BaseModal>
    <!-- END: Modal para Registrar Nuevo Doctor -->

    <!-- START: Modal para Registrar Nueva Orden de Trabajo -->
    <BaseModal v-model="showModalOrden" title="Crear Nueva Orden de Trabajo" size="lg">
      <p class="orden-cliente-info"><strong>Cliente:</strong> {{ clienteNombreCompleto }}</p>
      <h4 class="form-section-header">Información de la Orden</h4>
      <div class="form-grid-orden-info">
        <div class="form-group">
          <label>Nro. Sobre/Boleta *</label>
          <input ref="nroSobreOrdenInput" v-model="formOrden.nro_boleta_sobre" type="number" class="form-input" />
        </div>
        <div class="form-group">
          <label>Fecha Pedido</label>
          <input v-model="formOrden.fecha_pedido" type="date" class="form-input" @change="actualizarFechaEntrega" />
        </div>
        <div class="form-group">
          <label>Fecha Entrega</label>
          <input v-model="formOrden.fecha_entrega" type="date" class="form-input" />
        </div>
        <div class="form-group">
          <label>Hora Entrega</label>
          <input v-model="formOrden.hora_entrega" type="time" class="form-input" />
        </div>
      </div>
      <h4 class="form-section-header">Detalles Financieros</h4>
      <div class="form-grid-orden-financiero">
        <div class="form-group">
          <label>Monto Total (Bs.)</label>
          <input v-model="formOrden.monto_total" type="number" step="0.01" @input="calcularSaldo" class="form-input" />
        </div>
        <div class="form-group">
          <label>A Cuenta (Bs.)</label>
          <input v-model="formOrden.monto_acuenta" type="number" step="0.01" @input="calcularSaldo"
            class="form-input" />
        </div>
        <div class="form-group">
          <label>Saldo (Bs.)</label>
          <input v-model="formOrden.monto_saldo" type="number" step="0.01" readonly class="form-input campo-readonly" />
        </div>
      </div>
      <h4 class="form-section-header">Notas Adicionales</h4>
      <div class="form-group full-width">
        <textarea v-model="formOrden.observaciones_orden" rows="3" class="form-input"></textarea>
      </div>
      <template #footer>
        <button @click="cerrarModalOrden" class="btn-cancelar">Cancelar</button>
        <button @click="guardarOrdenTrabajo" class="btn-guardar">Guardar Orden</button>
      </template>
    </BaseModal>
    <!-- END: Modal para Registrar Nueva Orden de Trabajo -->

  </div>
</template>

<script setup>
// --- START: Importaciones y Configuración Inicial ---
import { ref, onMounted, reactive, computed, nextTick } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { supabase } from '../lib/supabaseClient';
import BaseModal from './BaseModal.vue';
import AutoComplete from './Autocomplete.vue';
import MultiSelect from './MultiSelect.vue';

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

// --- START: Estado de la UI (Modales, Cargas, Refs) ---
const cargandoPrescripciones = ref(false);
const cargandoMedidas = ref(false);
const mostrarModalFormulario = ref(false);
const mostrarModalDetalles = ref(false);
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
  proveedor_id: null, armador_lente_id: null, armazon_lente_id: null,
  fecha_entrega: null, codigo_pedido: ''
});
const medidas = ref([]);
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
const tipoLenteDistanciaOptions = ref([{ value: 'LEJOS', label: 'LEJOS' }, { value: 'CERCA', label: 'CERCA' }, { value: 'PROGRESIVO', label: 'PROGRESIVO' }, { value: 'INTERMEDIO', label: 'INTERMEDIO' }]);
const baseOptions = ref([{ value: 'NASAL', label: 'NASAL' }, { value: 'TEMPORAL', label: 'TEMPORAL' }, { value: 'SUPERIOR', label: 'SUPERIOR' }, { value: 'INFERIOR', label: 'INFERIOR' }]);
// --- END: Propiedades Computadas y Opciones de Selectores ---

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
  // FIX: Ajuste en la consulta para obtener el `cod_tratamiento` y evitar el conflicto de `tipo_lente`.
  getMedidasDePrescripcion: (id) => supabase.from('medida_lente').select(`*, cristal:cristal_medida (*, material_cristal(nombre_material), color_cristal(nombre_color), tipo_lente(nombre_tipo_lente)), tratamientos:medida_lente_tratamiento(cod_tratamiento)`).eq('prescripcion', id).order('cod_medida_lente'),
  getTiendaUsuario: () => supabase.from("tiendas").select("cod_tienda").limit(1).single(),
  verificarCodigoReceta: (codigo, idExcluir) => {
    let query = supabase.from('prescripcion_cliente').select(`cod_receta, clientes:cliente (nombre_cliente, apellido_paterno_cliente)`).eq('cod_receta', codigo.trim());
    if (idExcluir) query = query.neq('cod_prescripcion', idExcluir);
    return query.limit(1).single();
  },
  upsertPrescripcion: (data, id) => id ? supabase.from('prescripcion_cliente').update(data).eq('cod_prescripcion', id).select().single() : supabase.from('prescripcion_cliente').insert(data).select().single(),
  deleteMedidasByPrescripcionId: async (id) => {
    const { data: medidas } = await supabase.from('medida_lente').select('cod_medida_lente').eq('prescripcion', id);
    if (medidas?.length > 0) {
      await supabase.from('medida_lente').delete().in('cod_medida_lente', medidas.map(m => m.cod_medida_lente));
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
const getMedidaInicial = () => ({
  tipo_lente: '', esf_od: '', cil_od: '', eje_od: 0, prisma_od: '0.00', base_od: null, altura_od: '', adic_od: '',
  esf_oi: '', cil_oi: '', eje_oi: 0, prisma_oi: '0.00', base_oi: null, altura_oi: '', adic_oi: '',
  dip_lentes_binocular: null, dip_lentes_od_monocular: null, dip_lentes_oi_monocular: null,
  cantidad: 2, cod_material_cristal: null, cod_color_cristal: null, cod_tipo_lente: null,
  nro_sobre: '', tratamientos_seleccionados: [],
});

async function guardarPrescripcion() {
  if (medidas.value.some(m => !m.tipo_lente) || !formData.doctor_prescriptor) {
    alert('Asegúrese de que todas las medidas tengan un tipo/distancia y que haya seleccionado un doctor.');
    return;
  }

  try {
    const { data: recetaExistente, error: errReceta } = await api.verificarCodigoReceta(formData.cod_receta, editId.value);
    if (errReceta && errReceta.code !== 'PGRST116') throw new Error('No se pudo verificar el código de receta.');
    if (recetaExistente) {
      alert(`El código de receta "${formData.cod_receta}" ya está en uso por el cliente: ${recetaExistente.clientes.nombre_cliente} ${recetaExistente.clientes.apellido_paterno_cliente}`.trim());
      recetaInputRef.value?.focus();
      return;
    }

    const { data: prescripcionGuardada, error } = await upsertPrescription();
    if (error) throw error;

    await processMedidasAndDetails(prescripcionGuardada.cod_prescripcion);

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

async function processMedidasAndDetails(prescripcionId) {
  if (editId.value) {
    await api.deleteMedidasByPrescripcionId(prescripcionId);
  }

  const medidasData = medidas.value.map(m => ({ ...prepararDatosMedida(m), prescripcion: prescripcionId }));
  const { data: nuevasMedidas, error: errMed } = await api.insertMedidas(medidasData);
  if (errMed) throw errMed;

  const cristalesData = nuevasMedidas.map((medida, index) => prepararDatosCristal(medidas.value[index], medida.cod_medida_lente)).filter(Boolean);
  if (cristalesData.length > 0) {
    const { error: errCristal } = await api.insertCristales(cristalesData);
    if (errCristal) throw errCristal;
  }

  const tratamientosData = nuevasMedidas.flatMap((medida, index) =>
    (medidas.value[index].tratamientos_seleccionados || []).map(tratId => ({
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
  Object.assign(formData, {
    cod_receta: '', doctor_prescriptor: '', fecha_prescripcion: new Date().toISOString().split('T')[0],
    observacion_prescripcion: '', proveedor_id: null, armador_lente_id: null, armazon_lente_id: null,
    fecha_entrega: null, codigo_pedido: ''
  });
  medidas.value = [getMedidaInicial()];
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
    cod_receta: prescripcion.cod_receta, doctor_prescriptor: prescripcion.doctor_prescriptor,
    fecha_prescripcion: prescripcion.fecha_prescripcion, observacion_prescripcion: prescripcion.observacion_prescripcion,
    proveedor_id: prescripcion.proveedor_id, armador_lente_id: prescripcion.armador_lente_id,
    armazon_lente_id: prescripcion.armazon_lente_id, fecha_entrega: prescripcion.fecha_entrega,
    codigo_pedido: prescripcion.codigo_pedido,
  });

  const { data: medidasData, error } = await api.getMedidasDePrescripcion(prescripcion.cod_prescripcion);
  if (error) { alert("Error cargando datos para editar: " + error.message); return; }

  if (medidasData?.length > 0) {
    // FIX: Mapeo corregido para evitar conflicto de propiedades y cargar tratamientos.
    medidas.value = medidasData.map(m => {
      const cristalInfo = m.cristal && m.cristal[0] ? m.cristal[0] : {};
      // Omitir 'tipo_lente' de cristalInfo para evitar sobreescribir el 'tipo_lente' (distancia) de la medida principal.
      const { tipo_lente: _, ...restOfCristalInfo } = cristalInfo;
      // Mapear los tratamientos para obtener solo los IDs, que es lo que necesita el MultiSelect.
      const tratamientosSeleccionados = m.tratamientos ? m.tratamientos.map(t => t.cod_tratamiento) : [];
      return { ...m, ...restOfCristalInfo, tratamientos_seleccionados: tratamientosSeleccionados };
    });
  } else {
    medidas.value = [getMedidaInicial()];
  }

  mostrarModalFormulario.value = true;
  nextTick(() => { recetaInputRef.value?.focus(); });
};
async function abrirModalDetalles(prescripcion) {
  prescripcionSeleccionada.value = prescripcion;
  cargandoMedidas.value = true;
  try {
    const { data, error } = await api.getMedidasDePrescripcion(prescripcion.cod_prescripcion);
    if (error) throw error;
    medidasModal.value = data.map(medida => ({ ...medida, cristal: medida.cristal[0] || null })) || [];
  } catch (error) {
    alert('Error al cargar las medidas: ' + error.message);
  } finally {
    cargandoMedidas.value = false;
  }
  mostrarModalDetalles.value = true;
};
// --- END: Manejadores de Modales y UI ---

// --- START: Funciones de Ayuda (Helpers) ---
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
  return {
    cod_medida_lente: codMedidaLente, cantidad: medida.cantidad || 1, cod_material_cristal: medida.cod_material_cristal || null, cod_color_cristal: medida.cod_color_cristal || null,
    cod_tipo_lente: medida.cod_tipo_lente || null, nro_sobre: medida.nro_sobre || null
  };
};
const formatearFecha = (fecha) => fecha ? new Date(fecha + 'T00:00:00Z').toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'UTC' }) : '';
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
function volver() { router.push({ name: 'GestionClientes' }); }
// --- END: Funciones de Ayuda (Helpers) ---
</script>

<style scoped>
/* START: Estilos Generales del Panel */
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

.loading,
.sin-resultados {
  text-align: center;
  padding: 2rem;
  color: #6c757d;
  font-size: 1.1rem;
}

.elegant-divider {
  width: 100%;
  height: 3px;
  background: linear-gradient(to right, #e0e0e0, #a0a0a0, #e0e0e0);
  border: none;
  margin: 40px 0;
  opacity: 0.7;
}

/* END: Estilos Generales del Panel */

/* START: Estilos de la Sección de Prescripciones */
.seccion-prescripciones {
  margin-top: 2rem;
}

.seccion-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.seccion-header h2 {
  margin: 0;
}

.header-actions-group {
  display: flex;
  gap: 10px;
}

.sub-header {
  margin-top: 2rem;
  margin-bottom: 1rem;
  color: #495057;
  font-weight: 500;
}

/* END: Estilos de la Sección de Prescripciones */

/* START: Estilos de Botones Generales */
.btn-primary,
.btn-secondary,
.btn-success,
.btn-guardar,
.btn-cancelar {
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
}

.btn-primary {
  background: #007bff;
}

.btn-primary:hover {
  background: #0056b3;
}

.btn-secondary {
  background: #6c757d;
}

.btn-secondary:hover {
  background: #5a6268;
}

.btn-success {
  background: #28a745;
}

.btn-success:hover {
  background: #218838;
}

.btn-guardar {
  background: #007bff;
}

.btn-cancelar {
  background: #6c757d;
}

/* END: Estilos de Botones Generales */

/* START: Estilos de Tarjetas de Prescripción */
.prescripcion-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.prescripcion-card {
  background-color: rgb(255, 255, 255);
  border-radius: 8px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
  border: 1px solid #c0c0c0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.clickable {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.clickable:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1rem;
  background-color: #ffc368;
  border-bottom: 1px solid #e9ecef;
}

.card-header h4 {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
  color: #343a40;
}

.card-date {
  font-size: 0.8rem;
  color: #6c757d;
  background-color: #e9ecef;
  padding: 3px 8px;
  border-radius: 12px;
}

.card-body {
  padding: 1rem;
  flex-grow: 1;
}

.card-info-item {
  margin: 0 0 0.5rem 0;
  font-size: 0.9rem;
}

.card-info-item strong {
  color: #495057;
}

.card-info-item span {
  color: #212529;
}

.card-obs {
  font-size: 0.85rem;
  color: #6c757d;
  margin-top: 1rem;
  overflow: hidden;
  text-overflow: ellipsis;
}

.card-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  background-color: #ffffff;
  border-top: 1px solid #e9ecef;
}

.btn-action {
  padding: 5px 12px;
  font-size: 0.8rem;
  border: 1px solid transparent;
  border-radius: 5px;
  cursor: pointer;
  background: none;
  display: flex;
  align-items: center;
  gap: 4px;
}

.btn-action.btn-edit {
  color: #ffc107;
  border-color: #ffc107;
}

.btn-action.btn-edit:hover {
  background-color: #ffc107;
  color: #212529;
}

.btn-action.btn-delete {
  color: #dc3545;
  border-color: #dc3545;
}

.btn-action.btn-delete:hover {
  background-color: #dc3545;
  color: white;
}

/* END: Estilos de Tarjetas de Prescripción */

/* START: Estilos de Formularios (Generales) */
.form-container {
  padding: 10px;
  display: flex;
  flex-direction: column;
  gap: 15px;
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

.campo-readonly {
  background-color: #e9ecef;
  cursor: not-allowed;
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

/* END: Estilos de Formularios (Generales) */

/* START: Estilos del Formulario de Prescripción (Específicos) */
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

.btn-desactivar {
  background: #dc3545;
  color: white;
  border: none;
  cursor: pointer;
  border-radius: 4px;
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

.form-row-strict {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 10px;
  align-items: end;
}

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

/* END: Estilos del Formulario de Prescripción (Específicos) */

/* START: Estilos del Formulario de Orden de Trabajo (Específicos) */
.form-group.full-width {
  grid-column: 1 / -1;
}

.form-grid-orden-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 16px;
}

.form-grid-orden-financiero {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 16px;
}

.orden-cliente-info {
  font-size: 1rem;
  padding: 12px 16px;
  background-color: #e7f3ff;
  border: 1px solid #b3d7ff;
  border-radius: 6px;
  margin-bottom: 20px;
}

/* END: Estilos del Formulario de Orden de Trabajo (Específicos) */

/* START: Estilos del Modal de Detalles */
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

.tratamientos-detalle {
  margin-top: 8px;
  font-size: 0.85rem;
}

.tratamientos-detalle strong {
  display: block;
  color: #495057;
}

.entrega-detalle {
  margin-top: 1.5rem;
}

.entrega-detalle h4 {
  font-size: 1rem;
  color: #343a40;
  margin-bottom: 0.75rem;
}

/* END: Estilos del Modal de Detalles */

/* START: Media Queries para Responsividad */
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

  .form-grid-orden-info,
  .form-grid-orden-financiero {
    grid-template-columns: 1fr;
  }

  .form-row-strict,
  .cristal-grid {
    grid-template-columns: 1fr;
  }
}

/* END: Media Queries para Responsividad */
</style>

