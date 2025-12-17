<template>
  <v-container fluid>
    
    <v-card variant="flat" border>
      <v-toolbar color="grey-lighten-4">
        <v-card-title class="text-h6 font-weight-regular">
          <v-icon icon="mdi-file-document-multiple-outline" start></v-icon>
          Órdenes de Trabajo
        </v-card-title>
        <v-spacer></v-spacer>
        <v-btn 
          color="primary" 
          @click="abrirModalCrear" 
          prepend-icon="mdi-plus"
          class="mr-2"
        >
          Nueva Orden
        </v-btn>
      </v-toolbar>

      <v-card-text>
        <v-row>
          <v-col cols="12" md="3">
            <v-select
              v-model="filtroEstado"
              :items="estadosOrden"
              label="Filtrar por estado"
              item-title="texto"
              item-value="valor"
              variant="outlined"
              density="compact"
              hide-details
              clearable
            ></v-select>
          </v-col>
          <v-col cols="12" md="3">
            <v-select
              v-model="filtroTienda"
              :items="tiendas"
              label="Filtrar por tienda"
              item-title="nombre_tienda"
              item-value="cod_tienda"
              variant="outlined"
              density="compact"
              hide-details
              clearable
            ></v-select>
          </v-col>
          <v-col cols="12" md="6">
            <v-text-field
              v-model="buscarCliente"
              label="Buscar por cliente..."
              prepend-inner-icon="mdi-magnify"
              variant="outlined"
              density="compact"
              hide-details
            ></v-text-field>
          </v-col>
        </v-row>
      </v-card-text>

      <v-data-table
        :headers="headers"
        :items="ordenesFiltradas"
        :loading="cargandoOrdenes"
        density="compact"
        hover
        class="elevation-0"
        no-data-text="No hay órdenes que coincidan con los filtros"
      >
        <template v-slot:item.nro_boleta_sobre="{ item }">
          <strong>#{{ item.nro_boleta_sobre }}</strong>
        </template>
        
        <template v-slot:item.cliente="{ item }">
          {{ getClienteNombre(item.cliente) }}
        </template>
        
        <template v-slot:item.tienda="{ item }">
          {{ getTiendaNombre(item.tienda) }}
        </template>

        <template v-slot:item.fecha_pedido="{ item }">
          {{ formatearFecha(item.fecha_pedido) }}
        </template>
        <template v-slot:item.fecha_entrega="{ item }">
          {{ item.fecha_entrega ? formatearFecha(item.fecha_entrega) : '-' }}
        </template>
        
        <template v-slot:item.monto_saldo="{ item }">
          <span :class="item.monto_saldo > 0 ? 'text-red font-weight-bold' : ''">
            Bs. {{ item.monto_saldo.toFixed(2) }}
          </span>
        </template>

        <template v-slot:item.estado_orden="{ item }">
          <v-chip
            :color="getEstadoColor(item.estado_orden)"
            size="small"
            label
            variant="tonal"
          >
            {{ item.estado_orden }}
          </v-chip>
        </template>
        
        <template v-slot:item.acciones="{ item }">
          <v-menu>
            <template v-slot:activator="{ props }">
              <v-btn icon="mdi-dots-vertical" variant="text" size="small" v-bind="props"></v-btn>
            </template>
            <v-list density="compact">
              <v-list-item @click="verDetalleOrden(item)" prepend-icon="mdi-eye-outline" title="Ver Detalles"></v-list-item>
              <v-list-item @click="editarOrden(item)" prepend-icon="mdi-pencil-outline" title="Editar Orden"></v-list-item>
              <v-list-item @click="abrirModalPagos(item)" prepend-icon="mdi-cash-multiple" title="Gestionar Pagos"></v-list-item>
              <v-list-item @click="cambiarEstado(item)" prepend-icon="mdi-swap-horizontal" title="Cambiar Estado"></v-list-item>
              <v-divider></v-divider>
              <v-list-item @click="eliminarOrden(item.nro_boleta_sobre)" prepend-icon="mdi-delete-outline" title="Eliminar" base-color="red-darken-1"></v-list-item>
            </v-list>
          </v-menu>
        </template>
      </v-data-table>
    </v-card>

    <v-dialog v-model="showModal" persistent max-width="1200px">
      <v-card>
        <v-card-title class="text-h5 pa-4 bg-grey-lighten-3">
          {{ editId ? 'Editar Orden de Trabajo' : 'Nueva Orden de Trabajo' }}
        </v-card-title>
        <v-card-text class="pt-4">
          <v-container>
            <v-row>
              <v-col cols="12" md="4">
                <v-text-field
                  ref="nroSobreInput"
                  v-model="formOrden.nro_boleta_sobre"
                  label="Nro. Boleta/Sobre"
                  type="number"
                  variant="outlined"
                  density="compact"
                  :disabled="!!editId"
                ></v-text-field>
              </v-col>
              <v-col cols="12" md="8">
                <v-autocomplete
                  v-model="formOrden.cliente"
                  :items="clientesOptions"
                  item-title="label"
                  item-value="value"
                  label="Cliente"
                  placeholder="Buscar cliente..."
                  variant="outlined"
                  density="compact"
                ></v-autocomplete>
              </v-col>
              
              <v-col cols="12" md="4">
                <v-select
                  v-model="formOrden.tienda"
                  :items="tiendas"
                  item-title="nombre_tienda"
                  item-value="cod_tienda"
                  label="Tienda"
                  variant="outlined"
                  density="compact"
                ></v-select>
              </v-col>
              <v-col cols="12" md="4">
                <v-text-field
                  v-model="formOrden.fecha_pedido"
                  label="Fecha Pedido"
                  type="date"
                  variant="outlined"
                  density="compact"
                ></v-text-field>
              </v-col>
              <v-col cols="12" md="4">
                <v-select
                  v-model="formOrden.estado_orden"
                  :items="estadosOrden"
                  item-title="texto"
                  item-value="valor"
                  label="Estado"
                  variant="outlined"
                  density="compact"
                ></v-select>
              </v-col>
              
              <v-col cols="12" md="4">
                <v-text-field
                  v-model="formOrden.fecha_entrega"
                  label="Fecha Entrega (Opcional)"
                  type="date"
                  variant="outlined"
                  density="compact"
                ></v-text-field>
              </v-col>
              <v-col cols="12" md="4">
                <v-text-field
                  v-model="formOrden.hora_entrega"
                  label="Hora Entrega (Opcional)"
                  type="time"
                  variant="outlined"
                  density="compact"
                ></v-text-field>
              </v-col>
              
              <v-col cols="12" md="4">
                <v-text-field
                  v-model="formOrden.monto_total"
                  label="Monto Total"
                  type="number"
                  step="0.01"
                  prefix="Bs."
                  variant="outlined"
                  density="compact"
                  @input="calcularSaldo"
                ></v-text-field>
              </v-col>
              <v-col cols="12" md="4">
                <v-text-field
                  v-model="formOrden.monto_acuenta"
                  label="Monto a Cuenta"
                  type="number"
                  step="0.01"
                  prefix="Bs."
                  variant="outlined"
                  density="compact"
                  @input="calcularSaldo"
                ></v-text-field>
              </v-col>
              <v-col cols="12" md="4">
                <v-text-field
                  v-model="formOrden.monto_saldo"
                  label="Saldo"
                  type="number"
                  step="0.01"
                  prefix="Bs."
                  variant="outlined"
                  density="compact"
                  readonly
                ></v-text-field>
              </v-col>

              <v-col cols="12">
                <v-textarea
                  v-model="formOrden.observaciones_orden"
                  label="Observaciones"
                  rows="3"
                  variant="outlined"
                ></v-textarea>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
        <v-card-actions class="pa-4 bg-grey-lighten-3">
          <v-spacer></v-spacer>
          <v-btn color="grey-darken-1" variant="text" @click="cerrarModal">Cancelar</v-btn>
          <v-btn color="blue-darken-1" variant="flat" @click="guardarOrden">Guardar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="showModalEstado" persistent max-width="500px">
      <v-card v-if="ordenSeleccionada">
        <v-card-title class="text-h5 pa-4 bg-grey-lighten-3">
          Cambiar Estado de Orden
        </v-card-title>
        <v-card-text class="pt-4">
          <p><strong>Orden:</strong> {{ ordenSeleccionada.nro_boleta_sobre }}</p>
          <p><strong>Cliente:</strong> {{ getClienteNombre(ordenSeleccionada.cliente) }}</p>
          <p class="mb-4"><strong>Estado actual:</strong> 
            <v-chip :color="getEstadoColor(ordenSeleccionada.estado_orden)" size="small" label>
              {{ ordenSeleccionada.estado_orden }}
            </v-chip>
          </p>

          <v-select
            v-model="nuevoEstado"
            :items="estadosOrden"
            item-title="texto"
            item-value="valor"
            label="Nuevo estado"
            variant="outlined"
          ></v-select>
        </v-card-text>
        <v-card-actions class="pa-4 bg-grey-lighten-3">
          <v-spacer></v-spacer>
          <v-btn color="grey-darken-1" variant="text" @click="cerrarModalEstado">Cancelar</v-btn>
          <v-btn color="blue-darken-1" variant="flat" @click="actualizarEstado">Cambiar Estado</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="showModalDetalle" max-width="900px">
      <v-card v-if="ordenSeleccionada">
        <v-card-title class="text-h5 pa-4 bg-grey-lighten-3">
          Detalle de Orden - {{ ordenSeleccionada.nro_boleta_sobre }}
        </v-card-title>
        <v-card-text class="pt-4">
          <v-row dense>
            <v-col cols="12" md="6"><strong>Cliente:</strong> {{ getClienteNombre(ordenSeleccionada.cliente) }}</v-col>
            <v-col cols="12" md="6"><strong>Tienda:</strong> {{ getTiendaNombre(ordenSeleccionada.tienda) }}</v-col>
            <v-col cols="12" md="6"><strong>Creado por:</strong> {{ getUsuarioNombre(ordenSeleccionada.creado_por) }}</v-col>
            <v-col cols="12" md="6"><strong>Creado:</strong> {{ formatearFechaHora(ordenSeleccionada.creado_en) }}</v-col>
            <v-col cols="12" md="6"><strong>Fecha Pedido:</strong> {{ formatearFecha(ordenSeleccionada.fecha_pedido) }}</v-col>
            <v-col cols="12" md="6"><strong>Fecha Entrega:</strong> {{ ordenSeleccionada.fecha_entrega ? formatearFecha(ordenSeleccionada.fecha_entrega) : 'No definida' }}</v-col>
            <v-col cols="12" md="6"><strong>Hora Entrega:</strong> {{ ordenSeleccionada.hora_entrega || 'No definida' }}</v-col>
            <v-col cols="12" md="6"><strong>Estado:</strong> 
              <v-chip :color="getEstadoColor(ordenSeleccionada.estado_orden)" size="small" label>
                {{ ordenSeleccionada.estado_orden }}
              </v-chip>
            </v-col>
            <v-col cols="12"><v-divider class="my-2"></v-divider></v-col>
            <v-col cols="12" md="4"><strong>Monto Total:</strong> Bs. {{ ordenSeleccionada.monto_total }}</v-col>
            <v-col cols="12" md="4"><strong>Monto a Cuenta:</strong> Bs. {{ ordenSeleccionada.monto_acuenta }}</v-col>
            <v-col cols="12" md="4"><strong>Total Pagado:</strong> Bs. {{ ordenSeleccionada.monto_pagado || 0 }}</v-col>
            <v-col cols="12" class="font-weight-bold text-h6">
              Saldo: 
              <span :class="ordenSeleccionada.monto_saldo > 0 ? 'text-red' : 'text-green'">
                Bs. {{ ordenSeleccionada.monto_saldo }}
              </span>
            </v-col>
          </v-row>

          <v-sheet v-if="ordenSeleccionada.observaciones_orden" border rounded="lg" class="pa-4 mt-4">
            <strong>Observaciones:</strong>
            <p>{{ ordenSeleccionada.observaciones_orden }}</p>
          </v-sheet>
        </v-card-text>
        <v-card-actions class="pa-4 bg-grey-lighten-3">
          <v-spacer></v-spacer>
          <v-btn color="grey-darken-1" variant="text" @click="cerrarModalDetalle">Cerrar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="showModalPagos" persistent max-width="1000px">
      <v-card v-if="ordenSeleccionada">
        <v-card-title class="text-h5 pa-4 bg-grey-lighten-3">
          Gestión de Pagos - Orden {{ ordenSeleccionada.nro_boleta_sobre }}
        </v-card-title>
        <v-card-text class="pt-4">
          
          <v-sheet border rounded="lg" class="pa-4 mb-4">
            <v-row>
              <v-col cols="12" md="6"><strong>Cliente:</strong> {{ getClienteNombre(ordenSeleccionada.cliente) }}</v-col>
              <v-col cols="12" md="6"><strong>Monto Total:</strong> Bs. {{ ordenSeleccionada.monto_total }}</v-col>
              <v-col cols="12" md="6" class="text-h6"><strong>Total Pagado:</strong> <span class="text-green-darken-1">Bs. {{ ordenSeleccionada.monto_pagado || 0 }}</span></v-col>
              <v-col cols="12" md="6" class="text-h6"><strong>Saldo Pendiente:</strong> <span class="text-red-darken-1">Bs. {{ ordenSeleccionada.monto_saldo }}</span></v-col>
            </v-row>
          </v-sheet>

          <v-card variant="outlined" class="mb-4">
            <v-card-title>Registrar Nuevo Pago</v-card-title>
            <v-card-text>
              <v-row align="end">
                <v-col cols="12" md="3">
                  <v-select
                    v-model="formPago.tipo_pago"
                    :items="['EFECTIVO', 'TARJETA', 'TRANSFERENCIA', 'CHEQUE', 'OTRO']"
                    label="Tipo de Pago"
                    variant="outlined"
                    density="compact"
                  ></v-select>
                </v-col>
                <v-col cols="12" md="3">
                  <v-text-field
                    v-model="formPago.monto_pago"
                    label="Monto"
                    type="number"
                    step="0.01"
                    :max="ordenSeleccionada.monto_saldo"
                    prefix="Bs."
                    variant="outlined"
                    density="compact"
                  ></v-text-field>
                </v-col>
                <v-col cols="12" md="3">
                  <v-text-field
                    v-model="formPago.fecha_pago"
                    label="Fecha de Pago"
                    type="date"
                    variant="outlined"
                    density="compact"
                  ></v-text-field>
                </v-col>
                <v-col cols="12" md="3">
                  <v-btn
                    color="success"
                    @click="registrarPago"
                    :disabled="!formPago.monto_pago || formPago.monto_pago <= 0 || cargandoPago"
                    :loading="cargandoPago"
                    prepend-icon="mdi-plus-circle-outline"
                    block
                  >
                    Registrar Pago
                  </v-btn>
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>
          
          <v-card variant="outlined">
            <v-card-title>Historial de Pagos</v-card-title>
            <v-table density="compact">
              <thead>
                <tr>
                  <th class="text-left">Código</th>
                  <th class="text-left">Tipo</th>
                  <th class="text-left">Monto</th>
                  <th class="text-left">Fecha</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="pagosOrden.length === 0">
                  <td colspan="5" class="text-center text-grey pa-4">No hay pagos registrados para esta orden.</td>
                </tr>
                <tr v-for="pago in pagosOrden" :key="pago.cod_pago">
                  <td>{{ pago.cod_pago }}</td>
                  <td><v-chip size="small" label variant="tonal">{{ pago.tipo_pago }}</v-chip></td>
                  <td>Bs. {{ pago.monto_pago }}</td>
                  <td>{{ formatearFecha(pago.fecha_pago) }}</td>
                  <td class="text-center">
                    <v-tooltip text="Eliminar Pago">
                      <template v-slot:activator="{ props }">
                        <v-btn 
                          v-bind="props"
                          icon="mdi-delete-outline" 
                          color="red" 
                          variant="text" 
                          size="small" 
                          @click="eliminarPago(pago.cod_pago)"
                        ></v-btn>
                      </template>
                    </v-tooltip>
                  </td>
                </tr>
              </tbody>
            </v-table>
          </v-card>

        </v-card-text>
        <v-card-actions class="pa-4 bg-grey-lighten-3">
          <v-spacer></v-spacer>
          <v-btn color="grey-darken-1" variant="text" @click="cerrarModalPagos">Cerrar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

  </v-container>
</template>

<script setup>
import { ref, onMounted, computed, nextTick, onUnmounted } from "vue";
import { supabase } from "../lib/supabaseClient.js";
// Ya no se importan BaseModal ni AutoComplete

// --- ESTADO PRINCIPAL ---
const ordenes = ref([]);
const clientes = ref([]);
const tiendas = ref([]);
const usuarios = ref([]);
const pagosOrden = ref([]);
const cargandoOrdenes = ref(false); // Estado de carga para la tabla
const cargandoPago = ref(false); // Estado de carga para registrar pago

// --- ESTADOS DE MODALES ---
const showModal = ref(false);
const showModalEstado = ref(false);
const showModalDetalle = ref(false);
const showModalPagos = ref(false);
const editId = ref(null);
const ordenSeleccionada = ref(null);

// --- ESTADOS DE FILTROS ---
const filtroEstado = ref("");
const filtroTienda = ref("");
const buscarCliente = ref("");

const nroSobreInput = ref(null); // Ref para el v-text-field

// Constante para los estados (más limpio para v-select)
const estadosOrden = [
  { valor: "PENDIENTE", texto: "Pendiente" },
  { valor: "EN_PROCESO", texto: "En Proceso" },
  { valor: "TERMINADO", texto: "Terminado" },
  { valor: "ENTREGADO", texto: "Entregado" },
  { valor: "CANCELADO", texto: "Cancelado" }
];

// --- ESTADOS DE FORMULARIOS ---
const formOrden = ref({
  nro_boleta_sobre: "",
  cliente: "",
  tienda: "",
  fecha_pedido: new Date().toISOString().split('T')[0],
  fecha_entrega: "",
  hora_entrega: "",
  monto_total: 0,
  monto_acuenta: 0,
  monto_saldo: 0,
  observaciones_orden: "",
  estado_orden: "PENDIENTE"
});

const formPago = ref({
  tipo_pago: "EFECTIVO",
  monto_pago: "",
  fecha_pago: new Date().toISOString().split('T')[0]
});

const nuevoEstado = ref("");

// --- HEADERS PARA V-DATA-TABLE ---
const headers = [
  { title: 'Nro. Boleta', key: 'nro_boleta_sobre', sortable: true },
  { title: 'Cliente', key: 'cliente', sortable: true },
  { title: 'Tienda', key: 'tienda', sortable: true },
  { title: 'Fecha Pedido', key: 'fecha_pedido', sortable: true },
  { title: 'Fecha Entrega', key: 'fecha_entrega', sortable: true },
  { title: 'Monto Total', key: 'monto_total', sortable: true, align: 'end' },
  { title: 'Pagado', key: 'monto_pagado', sortable: true, align: 'end' },
  { title: 'Saldo', key: 'monto_saldo', sortable: true, align: 'end' },
  { title: 'Estado', key: 'estado_orden', sortable: true },
  { title: 'Acciones', key: 'acciones', sortable: false, align: 'center' }
];

// --- COMPUTED: FILTROS Y OPCIONES ---
// Tu lógica de filtrado es perfecta y v-data-table la consume
// sin problemas a través de :items
const ordenesFiltradas = computed(() => {
  let resultado = ordenes.value;

  if (filtroEstado.value) {
    resultado = resultado.filter(o => o.estado_orden === filtroEstado.value);
  }

  if (filtroTienda.value) {
    resultado = resultado.filter(o => o.tienda === parseInt(filtroTienda.value));
  }

  if (buscarCliente.value) {
    const busqueda = buscarCliente.value.toLowerCase();
    resultado = resultado.filter(o => {
      const cliente = getClienteNombre(o.cliente).toLowerCase();
      return cliente.includes(busqueda) || o.nro_boleta_sobre.toString().includes(busqueda);
    });
  }

  return resultado;
});

// Tu computed para v-autocomplete es perfecto
const clientesOptions = computed(() => {
    return clientes.value.map(cliente => ({
        value: cliente.cod_cliente,
        label: `${cliente.nombre_cliente} ${cliente.apellido_paterno_cliente} ${cliente.apellido_paterno_cliente || ''}`.trim()
    }));
});

// --- LÓGICA DE DATOS (SUPABASE) ---
// (Toda tu lógica de carga y guardado se mantiene. Solo se añade 'cargandoOrdenes')
async function cargarDatos() {
  await Promise.all([
    cargarOrdenes(),
    cargarClientes(),
    cargarTiendas(),
    cargarUsuarios()
  ]);
}

async function cargarOrdenes() {
  cargandoOrdenes.value = true;
  const { data } = await supabase
    .from("orden_trabajo")
    .select("*")
    .order("creado_en", { ascending: false });

  if (data) {
    for (let orden of data) {
      const montoPagado = await calcularMontoPagado(orden.nro_boleta_sobre);
      orden.monto_pagado = (montoPagado + (orden.monto_acuenta || 0)).toFixed(2);
      orden.monto_saldo = (orden.monto_total - orden.monto_pagado).toFixed(2);
    }
  }
  ordenes.value = data || [];
  cargandoOrdenes.value = false;
}

async function calcularMontoPagado(nroBoleta) {
  const { data } = await supabase
    .from("pagos_orden")
    .select("monto_pago")
    .eq("nro_boleta_sobre", nroBoleta);

  if (!data || data.length === 0) return 0;
  return data.reduce((total, pago) => total + parseFloat(pago.monto_pago), 0);
}

async function cargarClientes() {
  const { data } = await supabase.from("clientes").select("*");
  clientes.value = data || [];
}

async function cargarTiendas() {
  const { data } = await supabase.from("tiendas").select("*");
  tiendas.value = data || [];
}

async function cargarUsuarios() {
  const { data } = await supabase.from("usuarios").select("*");
  usuarios.value = data || [];
}

async function cargarPagosOrden(nroBoleta) {
  const { data } = await supabase
    .from("pagos_orden")
    .select("*")
    .eq("nro_boleta_sobre", nroBoleta)
    .order("fecha_pago", { ascending: false });
  pagosOrden.value = data || [];
}

async function guardarOrden() {
  const clienteId = parseInt(formOrden.value.cliente);
  if (isNaN(clienteId)) {
    alert("Por favor, seleccione un cliente válido.");
    return;
  }

  const ordenData = {
    cliente: clienteId,
    tienda: parseInt(formOrden.value.tienda),
    fecha_pedido: formOrden.value.fecha_pedido,
    fecha_entrega: formOrden.value.fecha_entrega || null,
    hora_entrega: formOrden.value.hora_entrega || null,
    monto_total: parseFloat(formOrden.value.monto_total) || 0,
    monto_acuenta: parseFloat(formOrden.value.monto_acuenta) || 0,
    monto_saldo: parseFloat(formOrden.value.monto_saldo) || 0,
    observaciones_orden: formOrden.value.observaciones_orden || null,
    estado_orden: formOrden.value.estado_orden
  };

  if (editId.value) {
    await supabase.from("orden_trabajo").update(ordenData).eq("nro_boleta_sobre", editId.value);
  } else {
    ordenData.nro_boleta_sobre = parseInt(formOrden.value.nro_boleta_sobre);
    await supabase.from("orden_trabajo").insert(ordenData);
  }

  await cargarOrdenes();
  cerrarModal();
}

async function eliminarOrden(nroBoleta) {
  if (confirm("¿Estás seguro de eliminar esta orden? También se eliminarán todos los pagos asociados.")) {
    await supabase.from("pagos_orden").delete().eq("nro_boleta_sobre", nroBoleta);
    await supabase.from("orden_trabajo").delete().eq("nro_boleta_sobre", nroBoleta);
    await cargarOrdenes();
  }
}

async function actualizarEstado() {
  await supabase
    .from("orden_trabajo")
    .update({ estado_orden: nuevoEstado.value })
    .eq("nro_boleta_sobre", ordenSeleccionada.value.nro_boleta_sobre);

  await cargarOrdenes();
  cerrarModalEstado();
}

async function registrarPago() {
  cargandoPago.value = true;
  const montoPago = parseFloat(formPago.value.monto_pago);
  if (montoPago <= 0) {
    alert("El monto del pago debe ser mayor a 0");
    cargandoPago.value = false;
    return;
  }
  if (montoPago > ordenSeleccionada.value.monto_saldo) {
    alert("El monto del pago no puede ser mayor al saldo pendiente");
    cargandoPago.value = false;
    return;
  }
  const pagoData = {
    nro_boleta_sobre: ordenSeleccionada.value.nro_boleta_sobre,
    tipo_pago: formPago.value.tipo_pago,
    monto_pago: montoPago,
    fecha_pago: formPago.value.fecha_pago
  };
  const { error } = await supabase.from("pagos_orden").insert(pagoData);

  if (!error) {
    await cargarOrdenes();
    await cargarPagosOrden(ordenSeleccionada.value.nro_boleta_sobre);
    
    const ordenActualizada = ordenes.value.find(o => o.nro_boleta_sobre === ordenSeleccionada.value.nro_boleta_sobre);
    if (ordenActualizada) {
        ordenSeleccionada.value = ordenActualizada;
    }

    if (ordenActualizada.monto_saldo <= 0 && ordenActualizada.estado_orden === 'TERMINADO') {
      await supabase.from("orden_trabajo").update({ estado_orden: 'ENTREGADO' }).eq("nro_boleta_sobre", ordenSeleccionada.value.nro_boleta_sobre);
      ordenSeleccionada.value.estado_orden = 'ENTREGADO';
      await cargarOrdenes();
    }
    
    formPago.value = { tipo_pago: "EFECTIVO", monto_pago: "", fecha_pago: new Date().toISOString().split('T')[0] };
    alert("Pago registrado exitosamente");
  } else {
    alert("Error al registrar el pago: " + error.message);
  }
  cargandoPago.value = false;
}

async function eliminarPago(codPago) {
  if (confirm("¿Estás seguro de eliminar este pago?")) {
    const { data: pagoData } = await supabase.from("pagos_orden").select("monto_pago, nro_boleta_sobre").eq("cod_pago", codPago).single();
    if (pagoData) {
      await supabase.from("pagos_orden").delete().eq("cod_pago", codPago);
      await cargarOrdenes();
      await cargarPagosOrden(pagoData.nro_boleta_sobre);
      
      const ordenActualizada = ordenes.value.find(o => o.nro_boleta_sobre === pagoData.nro_boleta_sobre);
      if (ordenActualizada) {
        ordenSeleccionada.value = ordenActualizada;
      }
    }
  }
}

// --- LÓGICA DE MODALES ---
// (Tu lógica de apertura y cierre es perfecta)
function abrirModalCrear() {
  editId.value = null;
  limpiarFormulario();
  showModal.value = true;
  // nextTick para enfocar el v-text-field
  nextTick(() => nroSobreInput.value?.focus()); 
}

function editarOrden(orden) {
  editId.value = orden.nro_boleta_sobre;
  // Hacemos una copia para no mutar el estado original
  formOrden.value = { ...orden }; 
  showModal.value = true;
}

function verDetalleOrden(orden) {
  ordenSeleccionada.value = orden;
  showModalDetalle.value = true;
}

function cambiarEstado(orden) {
  ordenSeleccionada.value = orden;
  nuevoEstado.value = orden.estado_orden;
  showModalEstado.value = true;
}

async function abrirModalPagos(orden) {
  ordenSeleccionada.value = orden;
  await cargarPagosOrden(orden.nro_boleta_sobre);
  showModalPagos.value = true;
}

function cerrarModal() {
  showModal.value = false;
  editId.value = null;
}
function cerrarModalEstado() {
  showModalEstado.value = false;
  ordenSeleccionada.value = null;
}
function cerrarModalDetalle() {
  showModalDetalle.value = false;
  ordenSeleccionada.value = null;
}
function cerrarModalPagos() {
  showModalPagos.value = false;
  ordenSeleccionada.value = null;
  pagosOrden.value = [];
}

// --- FUNCIONES HELPER ---
function limpiarFormulario() {
  formOrden.value = {
    nro_boleta_sobre: "", cliente: "", tienda: "",
    fecha_pedido: new Date().toISOString().split('T')[0], fecha_entrega: "",
    hora_entrega: "", monto_total: 0, monto_acuenta: 0, monto_saldo: 0,
    observaciones_orden: "", estado_orden: "PENDIENTE"
  };
}

function calcularSaldo() {
  const total = parseFloat(formOrden.value.monto_total) || 0;
  const acuenta = parseFloat(formOrden.value.monto_acuenta) || 0;
  formOrden.value.monto_saldo = total - acuenta;
}

function getClienteNombre(clienteId) {
  const cliente = clientes.value.find(c => c.cod_cliente === clienteId);
  return cliente ? `${cliente.nombre_cliente} ${cliente.apellido_paterno_cliente}` : 'N/A';
}

function getTiendaNombre(tiendaId) {
  const tienda = tiendas.value.find(t => t.cod_tienda === tiendaId);
  return tienda ? tienda.nombre_tienda : 'N/A';
}

function getUsuarioNombre(usuarioId) {
  if (!usuarioId) return 'N/A';
  const usuario = usuarios.value.find(u => u.cod_usuario === usuarioId);
  return usuario ? usuario.nombre_usuario : 'N/A';
}

function formatearFecha(fecha) { 
  if (!fecha) return '-';
  // Corregir problema de zona horaria al formatear
  const [year, month, day] = fecha.split('T')[0].split('-');
  return `${day}/${month}/${year}`;
}
function formatearFechaHora(fecha) { 
  if (!fecha) return '-';
  return new Date(fecha).toLocaleString('es-ES'); 
}

/**
 * Nueva función helper para dar color a los v-chip de estado
 */
function getEstadoColor(estado) {
  switch (estado) {
    case 'PENDIENTE': return 'orange';
    case 'EN_PROCESO': return 'blue';
    case 'TERMINADO': return 'green';
    case 'ENTREGADO': return 'grey';
    case 'CANCELADO': return 'red';
    default: return 'default';
  }
}

// --- CICLO DE VIDA ---
onMounted(cargarDatos);
onUnmounted(() => {
  // Limpiar listeners si los hubiera (ej. el de dropdowns)
  // window.removeEventListener('click', closeDropdowns); // Ya no se necesita
});
</script>

<style scoped>

</style>