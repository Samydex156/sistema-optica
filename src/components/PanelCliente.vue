<template>
  <v-container>
    <div v-if="cliente">
      <v-row align="center" justify="space-between" class="mb-2">
        <v-col cols="12" md="auto">
          <h1 class="text-h4 font-weight-bold">{{ cliente.nombre_cliente }} {{ cliente.apellido_paterno_cliente }}</h1>
          <div class="text-subtitle-1 text-medium-emphasis">
            <v-icon start icon="mdi-phone"></v-icon>
            <span>{{ cliente.telefono_cliente || 'No registrado' }}</span>
          </div>
        </v-col>
        <v-col cols="12" md="auto" class="text-md-right">
          <v-btn @click="volver" prepend-icon="mdi-arrow-left" variant="tonal">
            Volver a la lista
          </v-btn>
        </v-col>
      </v-row>
    </div>
    <div v-else class="d-flex justify-center py-8">
      <v-progress-circular indeterminate color="primary"></v-progress-circular>
    </div>
    
    <v-divider class="my-6"></v-divider>

    <div class="seccion-prescripciones">
      <v-row align="center" justify="space-between" class="mb-4">
        <v-col>
          <h2 class="text-h5">Historial de Prescripciones</h2>
        </v-col>
        <v-col class="text-right">
          <v-btn @click="irAFormularioNuevaPrescripcion" color="primary" prepend-icon="mdi-plus">
            Registrar Prescripción
          </v-btn>
        </v-col>
      </v-row>

      <div v-if="cargandoPrescripciones" class="d-flex justify-center py-10">
        <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
        <div class="ml-4 text-h6 align-self-center">Cargando prescripciones...</div>
      </div>

      <v-row v-else-if="prescripcionesCliente.length > 0">
        <v-col 
          v-for="prescripcion in prescripcionesCliente" 
          :key="prescripcion.cod_prescripcion"
          cols="12" sm="6" lg="4"
        >
          <v-card variant="outlined" class="h-100 d-flex flex-column">
            <v-card-item>
              <template #title>
                <div class="d-flex justify-space-between align-center">
                  <span class="text-h6 font-weight-bold">Receta: {{ prescripcion.cod_receta || 'S/C' }}</span>
                   <v-chip size="small" variant="tonal">{{ formatearFecha(prescripcion.fecha_prescripcion) }}</v-chip>
                </div>
              </template>
            </v-card-item>
            
            <v-divider></v-divider>

            <v-card-text class="flex-grow-1">
              <div class="mb-3">
                <strong>Nro. Sobre:</strong>
                <span class="ml-2">{{ prescripcion.num_sobre || '-' }}</span>
              </div>
              <div class="mb-3">
                <strong>Pedidos:</strong>
                <span class="ml-2">{{ [prescripcion.cod_pedido1, prescripcion.cod_pedido2].filter(p => p).join(', ') || '-' }}</span>
              </div>
              <div v-if="prescripcion.notas_adicionales && prescripcion.notas_adicionales !== '-'">
                <v-icon size="small" class="mr-1" color="grey">mdi-note-text-outline</v-icon>
                <em class="text-medium-emphasis">{{ prescripcion.notas_adicionales }}</em>
              </div>
            </v-card-text>

            <v-divider></v-divider>

            <v-card-actions>
              <v-spacer></v-spacer>
              <v-tooltip text="Editar Prescripción" location="top">
                <template v-slot:activator="{ props }">
                  <v-btn 
                    v-bind="props"
                    icon="mdi-pencil" 
                    variant="text" 
                    color="primary" 
                    @click="irAFormularioEditarPrescripcion(prescripcion.cod_prescripcion)"
                  ></v-btn>
                </template>
              </v-tooltip>
              <v-tooltip text="Eliminar Prescripción" location="top">
                 <template v-slot:activator="{ props }">
                  <v-btn 
                    v-bind="props"
                    icon="mdi-delete" 
                    variant="text" 
                    color="error" 
                    @click="eliminarPrescripcion(prescripcion.cod_prescripcion)"
                  ></v-btn>
                 </template>
              </v-tooltip>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>

      <v-alert
        v-else
        type="info"
        variant="tonal"
        border="start"
        icon="mdi-information-outline"
        title="Sin Registros"
      >
        Este cliente aún no tiene prescripciones registradas. Puedes añadir la primera haciendo clic en "Registrar Prescripción".
      </v-alert>
    </div>
  </v-container>
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
    alert("Error al inicializar el panel: ".concat(error.message));
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
        alert('Error al recargar prescripciones: '.concat(error.message));
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
    alert('Error al eliminar: '.concat(error.message));
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

const formatearFecha = (fecha) => fecha ? new Date(fecha.concat('T00:00:00Z')).toLocaleDateString('es-ES', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'UTC' }) : '';
function volver() { router.push({ name: 'GestionClientes' }); }
</script>

<style scoped>
/* ¡Ya no se necesita CSS personalizado gracias a Vuetify! */
</style>