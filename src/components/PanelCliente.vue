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
          <button @click="irAFormularioNuevaPrescripcion" class="btn btn-primary"> + Registrar Prescripción </button>
        </div>
      </div>

      <div v-if="cargandoPrescripciones" class="loading">Cargando prescripciones...</div>
      <div v-else-if="prescripcionesCliente.length > 0" class="prescripcion-grid">
        <div v-for="prescripcion in prescripcionesCliente" :key="prescripcion.cod_prescripcion"
          class="prescripcion-card">
          <div class="card-header">
            <h4>Receta: {{ prescripcion.cod_receta || 'S/C' }}</h4>
            <span class="card-date">{{ formatearFecha(prescripcion.fecha_prescripcion) }}</span>
          </div>
          <div class="card-body">
            <p class="card-info-item"><strong>Nro. Sobre:</strong> <span>{{ prescripcion.num_sobre }}</span></p>
            <p class="card-info-item"><strong>Pedidos:</strong> <span>{{ [prescripcion.cod_pedido1, prescripcion.cod_pedido2].filter(p => p).join(', ') || '-' }}</span></p>
            <p v-if="prescripcion.notas_adicionales && prescripcion.notas_adicionales !== '-'" class="card-obs">{{ prescripcion.notas_adicionales }}</p>
          </div>
          <div class="card-actions">
            <button @click="irAFormularioEditarPrescripcion(prescripcion.cod_prescripcion)" class="btn-action btn-edit" title="Editar">✏️ Editar</button>
            <button @click="eliminarPrescripcion(prescripcion.cod_prescripcion)" class="btn-action btn-delete" title="Eliminar">🗑️ Eliminar</button>
          </div>
        </div>
      </div>
      <div v-else class="sin-resultados"><p>Este cliente aún no tiene prescripciones registradas.</p></div>
    </div>
    
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { supabase } from '../lib/supabaseClient';

const route = useRoute();
const router = useRouter();
const clienteId = ref(route.params.id);

const cliente = ref(null);
const prescripcionesCliente = ref([]);
const cargandoPrescripciones = ref(false);

onMounted(async () => {
  await inicializarPanel();
});

async function inicializarPanel() {
  cargandoPrescripciones.value = true;
  try {
    const [clienteRes, prescripcionesRes] = await Promise.all([
      supabase.from('clientes').select('*').eq('cod_cliente', clienteId.value).single(),
      supabase.from('prescripcion_clienten').select(`*`).eq('cod_cliente', clienteId.value).order('fecha_prescripcion', { ascending: false })
    ]);

    if (clienteRes.error) throw clienteRes.error;
    if (prescripcionesRes.error) throw prescripcionesRes.error;

    cliente.value = clienteRes.data;
    prescripcionesCliente.value = prescripcionesRes.data || [];

  } catch (error) {
    console.error("Error al inicializar el panel:", error);
    alert("Error al inicializar el panel: " + error.message);
  } finally {
    cargandoPrescripciones.value = false;
  }
}

async function recargarPrescripciones() {
    cargandoPrescripciones.value = true;
    try {
        const { data, error } = await supabase.from('prescripcion_clienten').select(`*`).eq('cod_cliente', clienteId.value).order('fecha_prescripcion', { ascending: false });
        if (error) throw error;
        prescripcionesCliente.value = data || [];
    } catch (error) {
        alert('Error al recargar prescripciones: ' + error.message);
    } finally {
        cargandoPrescripciones.value = false;
    }
}

async function eliminarPrescripcion(id) {
  if (!confirm('¿Está seguro de eliminar esta prescripción? Esta acción no se puede deshacer.')) return;
  try {
    const { error } = await supabase.from('prescripcion_clienten').delete().eq('cod_prescripcion', id);
    if (error) throw error;
    alert('Prescripción eliminada.');
    await recargarPrescripciones();
  } catch (error) {
    alert('Error al eliminar: ' + error.message);
  }
}

function irAFormularioNuevaPrescripcion() {
  router.push({ name: 'CrearPrescripcion', params: { clienteId: clienteId.value } });
}

function irAFormularioEditarPrescripcion(prescripcionId) {
  router.push({
    name: 'EditarPrescripcion',
    params: {
      clienteId: clienteId.value,
      prescripcionId: prescripcionId
    }
  });
}

const formatearFecha = (fecha) => fecha ? new Date(fecha + 'T00:00:00Z').toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'UTC' }) : '';
function volver() { router.push({ name: 'GestionClientes' }); }

</script>

<style scoped>
.panel-container { padding: 24px; }
.panel-header { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem; }
.cliente-info { color: #6c757d; font-size: 14px; }
.loading, .sin-resultados { text-align: center; padding: 2rem; color: #6c757d; font-size: 1.1rem; }
.elegant-divider { width: 100%; height: 1px; background-color: #dee2e6; margin: 24px 0; }
.seccion-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 1rem; }
.header-actions-group { display: flex; gap: 10px; }
.sub-header { margin-top: 2rem; margin-bottom: 1rem; color: #495057; font-weight: 500; }

.btn-primary, .btn-secondary, .btn-success, .btn-guardar, .btn-cancelar { color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-size: 14px; }
.btn-primary { background: #007bff; } .btn-primary:hover { background: #0056b3; }
.btn-secondary { background: #6c757d; } .btn-secondary:hover { background: #5a6268; }
.btn-success { background: #28a745; } .btn-success:hover { background: #218838; }
.btn-guardar { background: #007bff; }
.btn-cancelar { background: #6c757d; }

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

.form-container, .details-view-container { display: flex; flex-direction: column; gap: 1rem; }
.form-group { display: flex; flex-direction: column; gap: 4px; }
.form-input, .form-group textarea { padding: 5px 12px; border: 1px solid #ced4da; border-radius: 4px; width: 100%; box-sizing: border-box; font-size: 14px; }
.form-input:focus-within, .form-group textarea:focus-within { border-color: #80bdff; box-shadow: 0 0 0 0.2rem rgba(0,123,255,.25); }
.campo-readonly { background-color: #e9ecef; cursor: not-allowed; }

.form-grid-4-col { display: grid; grid-template-columns: 350px 1fr .7fr 1.1fr; gap: .5rem; }
.form-grid-5-col { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr; gap: .5rem; }
.medidas-grid-container { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; background-color: #f8f9fa; padding: .5rem; border-radius: 8px; border: 1px solid #e9ecef; }
.medida-columna { display: flex; flex-direction: column; gap: 1rem; }
.medida-header { font-weight: 600; color: #495057; padding-bottom: 0.1rem; margin-bottom: 0.1rem; border-bottom: 1px solid #dee2e6; }
.tipo-dip-grupo { display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; }
.ojos-fila { display: flex; flex-direction: column; gap: 0.5rem; }
.ojo-grupo { display: grid; grid-template-columns: 30px 1fr 1fr 1fr; gap: 0.5rem; align-items: center; }
.ojo-label { font-weight: bold; font-size: 1rem; text-align: center; }
.cristales-grid-container { display: grid; grid-template-columns: 80px 80px 1fr 1fr 1.5fr 1fr 1fr; gap: 0.5rem .5rem; align-items: center; }
.cristal-row-label { font-size: 0.9rem; font-weight: 600; text-align: right; }
</style>