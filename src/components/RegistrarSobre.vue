<template>
  <v-container>
    <div v-if="cargando" class="d-flex justify-center align-center" style="height: 60vh;">
      <v-progress-circular indeterminate color="primary" size="64"></v-progress-circular>
      <div class="ml-4 text-h6">Cargando datos...</div>
    </div>

    <v-form @submit.prevent="guardarSobre" v-else>
      <v-card>
        <v-card-title class="text-h5 border-b">
          Registrar Pedido de Sobre
        </v-card-title>

        <v-card-text class="py-4">
          <v-row dense>
            <v-col cols="12" md="4">
              <v-text-field
                v-model.number="formData.numero_sobre"
                label="Número de Sobre"
                type="number"
                variant="outlined"
                density="compact"
                :rules="[v => !!v || 'El número de sobre es requerido']"
                required
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="8">
              <v-text-field
                v-model="formData.nombre_cliente"
                label="Nombre del Cliente"
                variant="outlined"
                density="compact"
                :rules="[v => !!v || 'El nombre del cliente es requerido']"
                required
              ></v-text-field>
            </v-col>
          </v-row>

          <v-row dense>
            <v-col cols="12" md="4">
              <v-text-field
                v-model="formData.fecha_pedido"
                label="Fecha Pedido"
                type="date"
                variant="outlined"
                density="compact"
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="4">
              <v-text-field
                v-model="formData.fecha_entrega"
                label="Fecha Entrega"
                type="date"
                variant="outlined"
                density="compact"
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="4">
              <v-text-field
                v-model="formData.hora_entrega"
                label="Hora Entrega"
                type="time"
                variant="outlined"
                density="compact"
              ></v-text-field>
            </v-col>
          </v-row>

          <v-row dense>
            <v-col cols="12" md="6">
              <v-autocomplete
                v-model="formData.cod_doctor"
                :items="doctoresOptions"
                item-title="label"
                item-value="value"
                label="Doctor"
                variant="outlined"
                density="compact"
                clearable
              ></v-autocomplete>
            </v-col>
            <v-col cols="12" md="6">
              <v-text-field
                v-model="formData.fecha_cancelacion_total"
                label="Fecha Cancelación Total"
                type="date"
                variant="outlined"
                density="compact"
              ></v-text-field>
            </v-col>
          </v-row>

          <v-row dense>
            <v-col cols="12" md="6">
              <v-select
                v-model="formData.estado_pedido"
                :items="['pendiente', 'entregado', 'cancelado']"
                label="Estado del Pedido"
                variant="outlined"
                density="compact"
                required
              ></v-select>
            </v-col>
          </v-row>

          <v-divider class="my-4"></v-divider>
          <v-row dense>
            <v-col cols="12" md="4">
              <v-text-field
                v-model.number="formData.monto_total"
                label="Monto Total"
                type="number"
                step="0.01"
                prefix="Bs."
                variant="outlined"
                density="compact"
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="4">
              <v-text-field
                v-model.number="formData.monto_a_cuenta"
                label="Monto a Cuenta"
                type="number"
                step="0.01"
                prefix="Bs."
                variant="outlined"
                density="compact"
              ></v-text-field>
            </v-col>
            <v-col cols="12" md="4">
              <v-text-field
                :model-value="saldoCalculado"
                label="Saldo"
                type="number"
                prefix="Bs."
                variant="outlined"
                density="compact"
                readonly
                bg-color="grey-lighten-4"
              ></v-text-field>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions class="pa-4 border-t">
          <v-spacer></v-spacer>
          <v-btn @click="cancelar" variant="text">Cancelar</v-btn>
          <v-btn type="submit" color="primary" variant="flat" :loading="guardando" :disabled="cargando || guardando">
            Guardar Pedido
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-form>
  </v-container>
</template>

<script setup>
import { ref, onMounted, reactive, computed } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from '../lib/supabaseClient';

const router = useRouter();
const cargando = ref(true);
const guardando = ref(false);
const doctores = ref([]);

const getInitialFormData = () => ({
  numero_sobre: null,
  nombre_cliente: '',
  fecha_pedido: new Date().toISOString().split('T')[0],
  fecha_entrega: null,
  hora_entrega: null,
  cod_doctor: null,
  monto_total: 0,
  monto_a_cuenta: 0,
  fecha_cancelacion_total: null,
  estado_pedido: 'pendiente',
});

const formData = reactive(getInitialFormData());

const doctoresOptions = computed(() => doctores.value.map(d => ({ value: d.cod_doctor, label: d.nombre_doctor })));

const saldoCalculado = computed(() => {
  const total = parseFloat(formData.monto_total) || 0;
  const aCuenta = parseFloat(formData.monto_a_cuenta) || 0;
  return (total - aCuenta).toFixed(2);
});

onMounted(async () => {
  await cargarDatos();
});

async function cargarDatos() {
  cargando.value = true;
  try {
    const { data, error } = await supabase.from('doctores').select('*');
    if (error) throw error;
    doctores.value = data || [];
  } catch (error) {
    console.error("Error al cargar doctores:", error);
    alert("Error al cargar la lista de doctores.");
  } finally {
    cargando.value = false;
  }
}

async function guardarSobre() {
  if (!formData.numero_sobre) {
    alert('El número de sobre es obligatorio.');
    return;
  }
  if (!formData.nombre_cliente.trim()) {
    alert('El nombre del cliente es obligatorio.');
    return;
  }

  guardando.value = true;
  try {
    // Preparamos los datos. Omitimos 'saldo' ya que es generado en BD.
    const dataToInsert = {
      numero_sobre: formData.numero_sobre,
      nombre_cliente: formData.nombre_cliente.toUpperCase(),
      fecha_pedido: formData.fecha_pedido,
      fecha_entrega: formData.fecha_entrega,
      hora_entrega: formData.hora_entrega,
      cod_doctor: formData.cod_doctor,
      monto_total: formData.monto_total,
      monto_a_cuenta: formData.monto_a_cuenta,
      fecha_cancelacion_total: formData.fecha_cancelacion_total,
      estado_pedido: formData.estado_pedido,
    };

    const { error } = await supabase
      .from('pedidos_sobres')
      .insert(dataToInsert);

    if (error) {
      if (error.code === '23505') { // Unique violation
        throw new Error('El número de sobre ya existe.');
      }
      throw error;
    }

    alert('Pedido de sobre registrado con éxito.');
    router.push({ name: 'PanelPrincipal' }); // O donde sea conveniente regresar
  } catch (error) {
    console.error("Error al guardar:", error);
    alert('Error al guardar el pedido: ' + error.message);
  } finally {
    guardando.value = false;
  }
}

function cancelar() {
  router.back();
}
</script>

<style scoped>
.border-b {
  border-bottom: 1px solid rgba(0,0,0,0.12);
}
.border-t {
  border-top: 1px solid rgba(0,0,0,0.12);
}
</style>
