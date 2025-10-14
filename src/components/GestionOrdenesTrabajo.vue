<template>
  <v-container>
    <v-card>
      <v-card-title class="d-flex align-center pe-2">
        <v-icon icon="mdi-cash-register"></v-icon> &nbsp;
        Gestión de Órdenes de Trabajo
        <v-spacer></v-spacer>
        <v-btn prepend-icon="mdi-plus" color="primary" @click="abrirDialogOrden()">Nueva Orden</v-btn>
      </v-card-title>

      <v-divider></v-divider>

      <v-card-text>
        <v-text-field
          v-model="busqueda"
          label="Buscar por N° Boleta, Cliente o Estado"
          prepend-inner-icon="mdi-magnify"
          variant="outlined"
          hide-details
          single-line
          class="mb-4"
        ></v-text-field>
        
        <v-data-table
          :headers="headers"
          :items="ordenesFiltradas"
          :loading="cargando"
          item-value="nro_boleta_sobre"
          class="elevation-1"
        >
          <template v-slot:item.monto_total="{ item }">
            <span>{{ formatCurrency(item.monto_total) }}</span>
          </template>
          <template v-slot:item.monto_acuenta="{ item }">
            <span>{{ formatCurrency(item.monto_acuenta) }}</span>
          </template>
          <template v-slot:item.monto_saldo="{ item }">
            <v-chip :color="item.monto_saldo > 0 ? 'orange' : 'green'" dark>
              {{ formatCurrency(item.monto_saldo) }}
            </v-chip>
          </template>
          <template v-slot:item.estado_orden="{ item }">
            <v-chip :color="getEstadoColor(item.estado_orden)">{{ item.estado_orden }}</v-chip>
          </template>
          <template v-slot:item.actions="{ item }">
            <v-icon class="me-2" @click="abrirDialogPagos(item)" size="small">mdi-currency-usd</v-icon>
            <v-icon class="me-2" @click="abrirDialogOrden(item)" size="small">mdi-pencil</v-icon>
            <v-icon @click="eliminarOrden(item)" size="small">mdi-delete</v-icon>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>

    <!-- Dialog para Registrar/Editar Orden de Trabajo -->
    <v-dialog v-model="dialogOrden" max-width="800px" persistent>
      <v-card>
        <v-card-title>
          <span class="text-h5">{{ esEdicion ? 'Editar Orden' : 'Nueva Orden de Trabajo' }}</span>
        </v-card-title>
        <v-card-text>
          <v-container>
            <v-row>
              <v-col cols="12" sm="6" md="4">
                <v-text-field 
                  v-model="formOrden.nro_boleta_sobre" 
                  label="N° Boleta / Sobre" 
                  type="number"
                  :readonly="esEdicion"
                  variant="outlined"
                  density="compact"
                ></v-text-field>
              </v-col>
              <v-col cols="12" sm="6" md="8">
                 <v-autocomplete
                  v-model="formOrden.cliente"
                  :items="clientes"
                  item-title="nombreCompleto"
                  item-value="cod_cliente"
                  label="Buscar Cliente"
                  placeholder="Escribe para buscar..."
                  variant="outlined"
                  density="compact"
                  clearable
                ></v-autocomplete>
              </v-col>
              <v-col cols="12" sm="6" md="4">
                <v-text-field v-model="formOrden.fecha_pedido" label="Fecha Pedido" type="date" variant="outlined" density="compact"></v-text-field>
              </v-col>
              <v-col cols="12" sm="6" md="4">
                <v-text-field v-model="formOrden.fecha_entrega" label="Fecha Entrega" type="date" variant="outlined" density="compact"></v-text-field>
              </v-col>
              <v-col cols="12" sm="6" md="4">
                 <v-select
                  v-model="formOrden.estado_orden"
                  :items="['PENDIENTE', 'PAGADO', 'ENTREGADO', 'ANULADO']"
                  label="Estado"
                  variant="outlined"
                  density="compact"
                ></v-select>
              </v-col>
              <v-col cols="12" sm="6" md="4">
                <v-text-field v-model.number="formOrden.monto_total" label="Monto Total" type="number" prefix="$" variant="outlined" density="compact" @input="calcularSaldo"></v-text-field>
              </v-col>
              <v-col cols="12" sm="6" md="4">
                <v-text-field
                  v-model.number="formOrden.monto_acuenta"
                  :label="esEdicion ? 'A Cuenta' : 'A Cuenta (Inicial)'"
                  type="number"
                  prefix="$"
                  variant="outlined"
                  density="compact"
                  :readonly="esEdicion"
                  @input="calcularSaldo"
                ></v-text-field>
              </v-col>
              <v-col cols="12" sm="6" md="4">
                <v-text-field v-model.number="formOrden.monto_saldo" label="Saldo" type="number" prefix="$" variant="outlined" density="compact" readonly></v-text-field>
              </v-col>
               <v-col cols="12">
                <v-textarea v-model="formOrden.observaciones_orden" label="Observaciones" rows="2" variant="outlined" density="compact"></v-textarea>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="blue-darken-1" variant="text" @click="cerrarDialogOrden">Cancelar</v-btn>
          <v-btn color="blue-darken-1" variant="flat" @click="guardarOrden">Guardar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Dialog para Pagos -->
    <v-dialog v-model="dialogPagos" max-width="700px">
        <v-card>
            <v-card-title class="text-h5">Gestión de Pagos (Orden N° {{ ordenSeleccionada?.nro_boleta_sobre }})</v-card-title>
            <v-card-subtitle>Cliente: {{ ordenSeleccionada?.clientes.nombreCompleto }} - Saldo: <strong class="text-h6">{{ formatCurrency(ordenSeleccionada?.monto_saldo) }}</strong></v-card-subtitle>
            <v-card-text>
                <v-row>
                    <v-col cols="12" md="4">
                        <v-text-field v-model.number="nuevoPago.monto_pago" label="Monto a Pagar" type="number" prefix="$" variant="outlined" density="compact"></v-text-field>
                    </v-col>
                    <v-col cols="12" md="4">
                         <v-select v-model="nuevoPago.tipo_pago" :items="['EFECTIVO', 'TARJETA', 'TRANSFERENCIA', 'QR']" label="Tipo de Pago" variant="outlined" density="compact"></v-select>
                    </v-col>
                    <v-col cols="12" md="4">
                        <v-btn color="primary" @click="registrarPago" block>Añadir Pago</v-btn>
                    </v-col>
                </v-row>
                <v-divider class="my-4"></v-divider>
                <h4 class="mb-2">Historial de Pagos</h4>
                 <v-data-table :headers="pagosHeaders" :items="pagos" :loading="cargandoPagos">
                    <template v-slot:item.monto_pago="{ item }">
                        <span>{{ formatCurrency(item.monto_pago) }}</span>
                    </template>
                     <template v-slot:item.actions="{ item }">
                        <v-icon size="small" @click="eliminarPago(item)">mdi-delete</v-icon>
                    </template>
                 </v-data-table>
            </v-card-text>
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="blue-darken-1" variant="text" @click="dialogPagos = false">Cerrar</v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>

  </v-container>
</template>

<script setup>
import { ref, onMounted, reactive, computed } from 'vue';
import { supabase } from '../lib/supabaseClient';
import { useAuth } from '../composables/useAuth';

const { user } = useAuth();
const cargando = ref(true);
const cargandoPagos = ref(false);
const ordenes = ref([]);
const clientes = ref([]);
const busqueda = ref('');

const dialogOrden = ref(false);
const dialogPagos = ref(false);
const esEdicion = ref(false);

const formOrden = reactive({
  nro_boleta_sobre: null,
  cliente: null,
  tienda: null,
  creado_por: null,
  fecha_pedido: new Date().toISOString().split('T')[0],
  fecha_entrega: null,
  fecha_pago_total: null,
  monto_total: 0,
  monto_acuenta: 0,
  monto_saldo: 0,
  observaciones_orden: '',
  estado_orden: 'PENDIENTE',
});

const ordenSeleccionada = ref(null);
const pagos = ref([]);
const nuevoPago = reactive({
    nro_boleta_sobre: null,
    tipo_pago: 'EFECTIVO',
    monto_pago: null,
    fecha_pago: new Date().toISOString().split('T')[0],
});

const headers = [
  { title: 'N° Boleta', key: 'nro_boleta_sobre', align: 'start' },
  { title: 'Cliente', key: 'clientes.nombreCompleto' },
  { title: 'Fecha Pedido', key: 'fecha_pedido' },
  { title: 'Monto Total', key: 'monto_total' },
  { title: 'A Cuenta', key: 'monto_acuenta' },
  { title: 'Saldo', key: 'monto_saldo' },
  { title: 'Estado', key: 'estado_orden' },
  { title: 'Acciones', key: 'actions', sortable: false },
];

const pagosHeaders = [
    { title: 'Fecha', key: 'fecha_pago' },
    { title: 'Tipo', key: 'tipo_pago' },
    { title: 'Monto', key: 'monto_pago' },
    { title: 'Acciones', key: 'actions', sortable: false },
];

const ordenesFiltradas = computed(() => {
  if (!busqueda.value) {
    return ordenes.value;
  }
  const busquedaLower = busqueda.value.toLowerCase();
  return ordenes.value.filter(orden => {
    const nombreCompleto = orden.clientes?.nombreCompleto?.toLowerCase() || '';
    const nroBoleta = orden.nro_boleta_sobre?.toString() || '';
    const estado = orden.estado_orden?.toLowerCase() || '';
    return nombreCompleto.includes(busquedaLower) || nroBoleta.includes(busquedaLower) || estado.includes(busquedaLower);
  });
});


onMounted(async () => {
  await cargarOrdenes();
  await cargarClientes();
  cargando.value = false;
});

async function cargarOrdenes() {
  cargando.value = true;
  try {
    const { data, error } = await supabase
      .from('orden_trabajo')
      .select(`
        *,
        clientes (
          cod_cliente,
          nombre_cliente,
          apellido_paterno_cliente,
          apellido_materno_cliente
        )
      `)
      .order('creado_en', { ascending: false });

    if (error) throw error;
    ordenes.value = data.map(orden => ({
      ...orden,
      clientes: {
        ...orden.clientes,
        nombreCompleto: `${orden.clientes.nombre_cliente} ${orden.clientes.apellido_paterno_cliente}`.trim()
      }
    }));
  } catch (err) {
    console.error('Error cargando órdenes:', err);
    alert('No se pudieron cargar las órdenes de trabajo.');
  } finally {
    cargando.value = false;
  }
}

async function cargarClientes() {
    try {
        const { data, error } = await supabase.from('clientes').select('*');
        if (error) throw error;
        clientes.value = data.map(c => ({
            ...c,
            nombreCompleto: `${c.nombre_cliente} ${c.apellido_paterno_cliente} ${c.apellido_materno_cliente || ''}`.trim()
        }));
    } catch (error) {
        console.error('Error cargando clientes:', error);
    }
}

function abrirDialogOrden(item = null) {
  if (item) {
    esEdicion.value = true;
    Object.assign(formOrden, { ...item, cliente: item.cliente });
  } else {
    esEdicion.value = false;
    Object.assign(formOrden, {
      nro_boleta_sobre: null,
      cliente: null,
      tienda: user.value?.tienda_usuario,
      creado_por: user.value?.cod_usuario,
      fecha_pedido: new Date().toISOString().split('T')[0],
      fecha_entrega: null,
      fecha_pago_total: null,
      monto_total: 0,
      monto_acuenta: 0,
      monto_saldo: 0,
      observaciones_orden: '',
      estado_orden: 'PENDIENTE',
    });
  }
  dialogOrden.value = true;
}

function cerrarDialogOrden() {
  dialogOrden.value = false;
  esEdicion.value = false;
}

function calcularSaldo() {
    formOrden.monto_saldo = (formOrden.monto_total || 0) - (formOrden.monto_acuenta || 0);
}

async function guardarOrden() {
  if (!formOrden.nro_boleta_sobre || !formOrden.cliente) {
      alert('El N° de boleta y el cliente son obligatorios.');
      return;
  }

  const pagoInicial = !esEdicion.value ? (Number(formOrden.monto_acuenta) || 0) : 0;

  // Recalculamos montos para asegurar que son numéricos
  formOrden.monto_total = Number(formOrden.monto_total) || 0;
  // En modo edición, `monto_acuenta` es la suma de pagos existentes (readonly).
  // En modo nuevo, es el pago inicial que el usuario ingresa.
  formOrden.monto_acuenta = Number(formOrden.monto_acuenta) || 0;
  formOrden.monto_saldo = formOrden.monto_total - formOrden.monto_acuenta;

  const dataToSave = { ...formOrden };

  try {
    const { error: ordenError } = await supabase
      .from('orden_trabajo')
      .upsert(dataToSave);
    
    if (ordenError) throw ordenError;
    
    // Si es una orden nueva con un pago inicial, creamos el registro de pago
    if (!esEdicion.value && pagoInicial > 0) {
        const pagoData = {
            nro_boleta_sobre: formOrden.nro_boleta_sobre,
            tipo_pago: 'EFECTIVO', // Se asume EFECTIVO para el pago inicial
            monto_pago: pagoInicial,
            fecha_pago: formOrden.fecha_pedido,
        };
        const { error: pagoError } = await supabase.from('pagos_orden').insert(pagoData);

        if (pagoError) {
             console.error('Error al registrar pago inicial:', pagoError);
             alert('¡Atención! La orden se guardó, pero no se pudo registrar el pago inicial. Por favor, añádelo manualmente desde la gestión de pagos.');
        }
    }
    
    alert(`Orden ${esEdicion.value ? 'actualizada' : 'creada'} con éxito.`);
    cerrarDialogOrden();
    await cargarOrdenes();

  } catch (error) {
    console.error('Error al guardar la orden:', error);
    alert('Error al guardar la orden: ' + error.message);
  }
}

async function eliminarOrden(item) {
  if (confirm(`¿Estás seguro de que quieres eliminar la orden N° ${item.nro_boleta_sobre}? Esta acción no se puede deshacer.`)) {
    try {
      // Primero eliminamos los pagos asociados
      const { error: pagosError } = await supabase.from('pagos_orden').delete().eq('nro_boleta_sobre', item.nro_boleta_sobre);
      if (pagosError) throw pagosError;

      // Luego eliminamos la orden
      const { error: ordenError } = await supabase.from('orden_trabajo').delete().eq('nro_boleta_sobre', item.nro_boleta_sobre);
      if (ordenError) throw ordenError;

      alert('Orden y pagos asociados eliminados con éxito.');
      await cargarOrdenes();
    } catch (error) {
      console.error('Error al eliminar:', error);
      alert('Error al eliminar la orden: ' + error.message);
    }
  }
}

// --- Lógica de Pagos ---

async function abrirDialogPagos(orden) {
    ordenSeleccionada.value = orden;
    nuevoPago.nro_boleta_sobre = orden.nro_boleta_sobre;
    nuevoPago.monto_pago = null;
    await cargarPagos(orden.nro_boleta_sobre);
    dialogPagos.value = true;
}

async function cargarPagos(nro_boleta) {
    cargandoPagos.value = true;
    try {
        const { data, error } = await supabase
            .from('pagos_orden')
            .select('*')
            .eq('nro_boleta_sobre', nro_boleta)
            .order('fecha_pago', { ascending: false });
        if (error) throw error;
        pagos.value = data;
    } catch (error) {
        console.error('Error cargando pagos:', error);
    } finally {
        cargandoPagos.value = false;
    }
}

async function registrarPago() {
    if (!nuevoPago.monto_pago || nuevoPago.monto_pago <= 0) {
        alert('El monto del pago debe ser mayor a cero.');
        return;
    }

    try {
        // 1. Insertar el nuevo pago
        const { error: insertError } = await supabase.from('pagos_orden').insert(nuevoPago);
        if (insertError) throw insertError;

        // 2. Actualizar el monto a cuenta y saldo de la orden
        const nuevoAcuenta = (ordenSeleccionada.value.monto_acuenta || 0) + nuevoPago.monto_pago;
        const nuevoSaldo = ordenSeleccionada.value.monto_total - nuevoAcuenta;
        const nuevoEstado = nuevoSaldo <= 0 ? 'PAGADO' : ordenSeleccionada.value.estado_orden;
        
        const { error: updateError } = await supabase
            .from('orden_trabajo')
            .update({ 
                monto_acuenta: nuevoAcuenta,
                monto_saldo: nuevoSaldo,
                estado_orden: nuevoEstado,
                ...(nuevoSaldo <= 0 && { fecha_pago_total: new Date().toISOString().split('T')[0] })
             })
            .eq('nro_boleta_sobre', ordenSeleccionada.value.nro_boleta_sobre);
        
        if (updateError) throw updateError;
        
        alert('Pago registrado con éxito.');
        await cargarPagos(ordenSeleccionada.value.nro_boleta_sobre); // Recargar pagos
        await cargarOrdenes(); // Recargar la lista principal de órdenes
        
        // Actualizar el objeto local para que la UI del dialog se refresque
        ordenSeleccionada.value.monto_acuenta = nuevoAcuenta;
        ordenSeleccionada.value.monto_saldo = nuevoSaldo;
        ordenSeleccionada.value.estado_orden = nuevoEstado;
        
        nuevoPago.monto_pago = null; // Limpiar input

    } catch (error) {
        console.error('Error al registrar pago:', error);
        alert('Error: ' + error.message);
    }
}

async function eliminarPago(pago) {
    if (!confirm(`¿Seguro que quieres eliminar este pago de ${formatCurrency(pago.monto_pago)}?`)) return;
    try {
        // 1. Eliminar el pago
        const { error: deleteError } = await supabase.from('pagos_orden').delete().eq('cod_pago', pago.cod_pago);
        if (deleteError) throw deleteError;

        // 2. Re-calcular y actualizar la orden principal
        const nuevoAcuenta = (ordenSeleccionada.value.monto_acuenta || 0) - pago.monto_pago;
        const nuevoSaldo = ordenSeleccionada.value.monto_total - nuevoAcuenta;
        const nuevoEstado = nuevoSaldo > 0 && ordenSeleccionada.value.estado_orden === 'PAGADO' ? 'PENDIENTE' : ordenSeleccionada.value.estado_orden;

        const { error: updateError } = await supabase
            .from('orden_trabajo')
            .update({ 
                monto_acuenta: nuevoAcuenta, 
                monto_saldo: nuevoSaldo, 
                estado_orden: nuevoEstado,
                ...(nuevoSaldo > 0 && { fecha_pago_total: null })
            })
            .eq('nro_boleta_sobre', pago.nro_boleta_sobre);

        if (updateError) throw updateError;
        
        alert('Pago eliminado.');
        await cargarPagos(pago.nro_boleta_sobre);
        await cargarOrdenes();

        ordenSeleccionada.value.monto_acuenta = nuevoAcuenta;
        ordenSeleccionada.value.monto_saldo = nuevoSaldo;
        ordenSeleccionada.value.estado_orden = nuevoEstado;

    } catch(error) {
        console.error('Error al eliminar pago:', error);
        alert('Error: ' + error.message);
    }
}


// --- Utilidades ---
function formatCurrency(value) {
  if (value === null || value === undefined) return '$0.00';
  return value.toLocaleString('es-BO', { style: 'currency', currency: 'BOB' });
}

function getEstadoColor(estado) {
  switch (estado) {
    case 'PAGADO': return 'success';
    case 'PENDIENTE': return 'warning';
    case 'ENTREGADO': return 'info';
    case 'ANULADO': return 'error';
    default: return 'grey';
  }
}
</script>

