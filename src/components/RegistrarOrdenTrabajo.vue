<template>
  <div>
    <h3>Órdenes de Trabajo</h3>
    <div class="filtros">
      <select v-model="filtroEstado" @change="aplicarFiltros">
        <option value="">Todos los estados</option>
        <option value="PENDIENTE">Pendiente</option>
        <option value="EN_PROCESO">En Proceso</option>
        <option value="TERMINADO">Terminado</option>
        <option value="ENTREGADO">Entregado</option>
        <option value="CANCELADO">Cancelado</option>
      </select>

      <select v-model="filtroTienda" @change="aplicarFiltros">
        <option value="">Todas las tiendas</option>
        <option v-for="tienda in tiendas" :key="tienda.cod_tienda" :value="tienda.cod_tienda">
          {{ tienda.nombre_tienda }}
        </option>
      </select>

      <input v-model="buscarCliente" @input="aplicarFiltros" placeholder="Buscar por cliente..." type="text" />
    </div>

    <table>
      <thead>
        <tr>
          <th>Nro. Boleta</th>
          <th>Cliente</th>
          <th>Tienda</th>
          <th>Fecha Pedido</th>
          <th>Fecha Entrega</th>
          <th>Monto Total</th>
          <th>Pagado</th>
          <th>Saldo</th>
          <th>Estado</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="orden in ordenesFiltradas" :key="orden.nro_boleta_sobre">
          <td>{{ orden.nro_boleta_sobre }}</td>
          <td>{{ getClienteNombre(orden.cliente) }}</td>
          <td>{{ getTiendaNombre(orden.tienda) }}</td>
          <td>{{ formatearFecha(orden.fecha_pedido) }}</td>
          <td>{{ orden.fecha_entrega ? formatearFecha(orden.fecha_entrega) : '-' }}</td>
          <td>Bs. {{ orden.monto_total }}</td>
          <td>Bs. {{ orden.monto_pagado || 0 }}</td>
          <td :class="{ 'saldo-pendiente': orden.monto_saldo > 0 }">
            Bs. {{ orden.monto_saldo }}
          </td>
          <td>
            <span :class="'estado-' + orden.estado_orden.toLowerCase()">
              {{ orden.estado_orden }}
            </span>
          </td>
          <td class="acciones-cell">
            <div class="dropdown-container">
              <button @click.stop="toggleDropdown(orden.nro_boleta_sobre)" class="btn-acciones">
                Acciones &#9662;
              </button>
              <div v-if="dropdownAbierto === orden.nro_boleta_sobre" class="dropdown-menu">
                <a @click="verDetalleOrden(orden)">Ver Detalles</a>
                <a @click="editarOrden(orden)">Editar Orden</a>
                <a @click="abrirModalPagos(orden)">Gestionar Pagos</a>
                <a @click="cambiarEstado(orden)">Cambiar Estado</a>
                <a @click="eliminarOrden(orden.nro_boleta_sobre)" class="dropdown-danger">Eliminar</a>
              </div>
            </div>
          </td>
        </tr>
      </tbody>
    </table>

    <BaseModal v-model="showModal" :title="editId ? 'Editar Orden de Trabajo' : 'Nueva Orden de Trabajo'" size="lg">
      <div class="form-grid">
        <div class="form-group">
          <label>Nro. Boleta/Sobre:</label>
          <input ref="nroSobreInput" v-model="formOrden.nro_boleta_sobre" type="number"
            placeholder="Número Boleta / Sobre" :disabled="editId" />
        </div>

        <div class="form-group">
            <label>Cliente:</label>
            <AutoComplete
              v-model="formOrden.cliente"
              :options="clientesOptions"
              placeholder="Buscar cliente..."
            />
        </div>

        <div class="form-group">
          <label>Tienda:</label>
          <select v-model="formOrden.tienda">
            <option value="">Seleccionar tienda</option>
            <option v-for="tienda in tiendas" :key="tienda.cod_tienda" :value="tienda.cod_tienda">
              {{ tienda.nombre_tienda }}
            </option>
          </select>
        </div>

        <div class="form-group">
          <label>Fecha Pedido:</label>
          <input v-model="formOrden.fecha_pedido" type="date" />
        </div>

        <div class="form-group">
          <label>Fecha Entrega:</label>
          <input v-model="formOrden.fecha_entrega" type="date" />
        </div>

        <div class="form-group">
          <label>Hora Entrega:</label>
          <input v-model="formOrden.hora_entrega" type="time" />
        </div>

        <div class="form-group">
          <label>Monto Total:</label>
          <input v-model="formOrden.monto_total" type="number" step="0.01" @input="calcularSaldo" />
        </div>

        <div class="form-group">
          <label>Monto a Cuenta:</label>
          <input v-model="formOrden.monto_acuenta" type="number" step="0.01" @input="calcularSaldo" />
        </div>

        <div class="form-group">
          <label>Saldo:</label>
          <input v-model="formOrden.monto_saldo" type="number" step="0.01" readonly />
        </div>

        <div class="form-group">
          <label>Estado:</label>
          <select v-model="formOrden.estado_orden">
            <option value="PENDIENTE">Pendiente</option>
            <option value="EN_PROCESO">En Proceso</option>
            <option value="TERMINADO">Terminado</option>
            <option value="ENTREGADO">Entregado</option>
            <option value="CANCELADO">Cancelado</option>
          </select>
        </div>
      </div>

      <div class="form-group full-width">
        <label>Observaciones:</label>
        <textarea v-model="formOrden.observaciones_orden" rows="3"
          placeholder="Observaciones de la orden..."></textarea>
      </div>
      
      <template #footer>
        <button @click="cerrarModal" class="btn btn-secondary">Cancelar</button>
        <button @click="guardarOrden" class="btn btn-primary">Guardar</button>
      </template>
    </BaseModal>

    <BaseModal v-model="showModalEstado" title="Cambiar Estado de Orden" size="md">
        <p><strong>Orden:</strong> {{ ordenSeleccionada?.nro_boleta_sobre }}</p>
        <p><strong>Cliente:</strong> {{ getClienteNombre(ordenSeleccionada?.cliente) }}</p>
        <p><strong>Estado actual:</strong> {{ ordenSeleccionada?.estado_orden }}</p>

        <div class="form-group">
          <label>Nuevo estado:</label>
          <select v-model="nuevoEstado">
            <option value="PENDIENTE">Pendiente</option>
            <option value="EN_PROCESO">En Proceso</option>
            <option value="TERMINADO">Terminado</option>
            <option value="ENTREGADO">Entregado</option>
            <option value="CANCELADO">Cancelado</option>
          </select>
        </div>
      <template #footer>
          <button @click="cerrarModalEstado" class="btn btn-secondary">Cancelar</button>
          <button @click="actualizarEstado" class="btn btn-primary">Cambiar Estado</button>
      </template>
    </BaseModal>

    <BaseModal v-model="showModalDetalle" :title="`Detalle de Orden - ${ordenSeleccionada?.nro_boleta_sobre}`" size="lg">
      <div class="detalle-grid">
        <div><strong>Cliente:</strong> {{ getClienteNombre(ordenSeleccionada?.cliente) }}</div>
        <div><strong>Tienda:</strong> {{ getTiendaNombre(ordenSeleccionada?.tienda) }}</div>
        <div><strong>Creado por:</strong> {{ getUsuarioNombre(ordenSeleccionada?.creado_por) }}</div>
        <div><strong>Fecha Pedido:</strong> {{ formatearFecha(ordenSeleccionada?.fecha_pedido) }}</div>
        <div><strong>Fecha Entrega:</strong> {{ ordenSeleccionada?.fecha_entrega ? formatearFecha(ordenSeleccionada.fecha_entrega) : 'No definida' }}</div>
        <div><strong>Hora Entrega:</strong> {{ ordenSeleccionada?.hora_entrega || 'No definida' }}</div>
        <div><strong>Monto Total:</strong> Bs. {{ ordenSeleccionada?.monto_total }}</div>
        <div><strong>Monto a Cuenta:</strong> Bs. {{ ordenSeleccionada?.monto_acuenta }}</div>
        <div><strong>Total Pagado:</strong> Bs. {{ ordenSeleccionada?.monto_pagado || 0 }}</div>
        <div><strong>Saldo:</strong> Bs. {{ ordenSeleccionada?.monto_saldo }}</div>
        <div><strong>Estado:</strong> {{ ordenSeleccionada?.estado_orden }}</div>
        <div><strong>Creado:</strong> {{ formatearFechaHora(ordenSeleccionada?.creado_en) }}</div>
      </div>

      <div v-if="ordenSeleccionada?.observaciones_orden" class="observaciones">
        <strong>Observaciones:</strong>
        <p>{{ ordenSeleccionada.observaciones_orden }}</p>
      </div>

      <template #footer>
          <button @click="cerrarModalDetalle" class="btn btn-secondary">Cerrar</button>
      </template>
    </BaseModal>

    <BaseModal v-model="showModalPagos" :title="`Gestión de Pagos - Orden ${ordenSeleccionada?.nro_boleta_sobre}`" size="lg">
        <div class="resumen-orden">
          <div class="resumen-grid">
            <div><strong>Cliente:</strong> {{ getClienteNombre(ordenSeleccionada?.cliente) }}</div>
            <div><strong>Monto Total:</strong> Bs. {{ ordenSeleccionada?.monto_total }}</div>
            <div><strong>Monto a Cuenta:</strong> Bs. {{ ordenSeleccionada?.monto_acuenta }}</div>
            <div class="highlight"><strong>Total Pagado:</strong> Bs. {{ ordenSeleccionada?.monto_pagado || 0 }}</div>
            <div class="highlight-saldo"><strong>Saldo Pendiente:</strong> Bs. {{ ordenSeleccionada?.monto_saldo }}</div>
          </div>
        </div>

        <div class="nuevo-pago">
          <h4>Registrar Nuevo Pago</h4>
          <div class="form-grid-pago">
            <div class="form-group">
              <label>Tipo de Pago:</label>
              <select v-model="formPago.tipo_pago">
                <option value="EFECTIVO">Efectivo</option>
                <option value="TARJETA">Tarjeta</option>
                <option value="TRANSFERENCIA">Transferencia</option>
                <option value="CHEQUE">Cheque</option>
                <option value="OTRO">Otro</option>
              </select>
            </div>
            <div class="form-group">
              <label>Monto:</label>
              <input v-model="formPago.monto_pago" type="number" step="0.01" :max="ordenSeleccionada?.monto_saldo" placeholder="0.00" />
            </div>
            <div class="form-group">
              <label>Fecha de Pago:</label>
              <input v-model="formPago.fecha_pago" type="date" />
            </div>
            <div class="form-group">
              <button @click="registrarPago" class="btn btn-success" :disabled="!formPago.monto_pago || formPago.monto_pago <= 0">
                Registrar Pago
              </button>
            </div>
          </div>
        </div>

        <div class="pagos-existentes">
          <h4>Historial de Pagos</h4>
          <table v-if="pagosOrden.length > 0" class="tabla-pagos">
            <thead>
              <tr>
                <th>Código</th>
                <th>Tipo</th>
                <th>Monto</th>
                <th>Fecha</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagosOrden" :key="pago.cod_pago">
                <td>{{ pago.cod_pago }}</td>
                <td>{{ pago.tipo_pago }}</td>
                <td>Bs. {{ pago.monto_pago }}</td>
                <td>{{ formatearFecha(pago.fecha_pago) }}</td>
                <td>
                  <button @click="eliminarPago(pago.cod_pago)" class="btn-eliminar">Eliminar</button>
                </td>
              </tr>
            </tbody>
          </table>
          <p v-else class="no-pagos">No hay pagos registrados para esta orden.</p>
        </div>

        <template #footer>
            <button @click="cerrarModalPagos" class="btn btn-secondary">Cerrar</button>
        </template>
    </BaseModal>

  </div>
</template>

<script setup>
import { ref, onMounted, computed, nextTick } from "vue";
import { supabase } from "../lib/supabaseClient.js";
import BaseModal from "./BaseModal.vue";
import AutoComplete from "./AutoComplete.vue";

// Estados principales
const ordenes = ref([]);
const clientes = ref([]);
const tiendas = ref([]);
const usuarios = ref([]);
const pagosOrden = ref([]);
const dropdownAbierto = ref(null);

// Estados de modales
const showModal = ref(false);
const showModalEstado = ref(false);
const showModalDetalle = ref(false);
const showModalPagos = ref(false);
const editId = ref(null);
const ordenSeleccionada = ref(null);

// Estados de filtros
const filtroEstado = ref("");
const filtroTienda = ref("");
const buscarCliente = ref("");

const nroSobreInput = ref(null);

// Estados de formulario
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

// --- Manejo del Dropdown ---
const toggleDropdown = (id) => {
  if (dropdownAbierto.value === id) {
    dropdownAbierto.value = null;
  } else {
    dropdownAbierto.value = id;
  }
};

const closeDropdowns = () => {
  dropdownAbierto.value = null;
};

// Computed para filtros
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
      return cliente.includes(busqueda);
    });
  }

  return resultado;
});

// Computed para opciones de Autocomplete de clientes
const clientesOptions = computed(() => {
    return clientes.value.map(cliente => ({
        value: cliente.cod_cliente,
        label: `${cliente.nombre_cliente} ${cliente.apellido_paterno_cliente} ${cliente.apellido_materno_cliente || ''}`.trim()
    }));
});

// Funciones principales
async function cargarDatos() {
  await Promise.all([
    cargarOrdenes(),
    cargarClientes(),
    cargarTiendas(),
    cargarUsuarios()
  ]);
   window.addEventListener('click', closeDropdowns);
}

async function cargarOrdenes() {
  const { data } = await supabase
    .from("orden_trabajo")
    .select("*")
    .order("creado_en", { ascending: false });

  if (data) {
    for (let orden of data) {
      const montoPagado = await calcularMontoPagado(orden.nro_boleta_sobre);
      orden.monto_pagado = montoPagado + orden.monto_acuenta;
      orden.monto_saldo = orden.monto_total - orden.monto_pagado;
    }
  }
  ordenes.value = data || [];
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
  const montoPago = parseFloat(formPago.value.monto_pago);
  if (montoPago <= 0) {
    alert("El monto del pago debe ser mayor a 0");
    return;
  }
  if (montoPago > ordenSeleccionada.value.monto_saldo) {
    alert("El monto del pago no puede ser mayor al saldo pendiente");
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
    await cargarOrdenes(); // Recargamos toda la data para asegurar consistencia
    await cargarPagosOrden(ordenSeleccionada.value.nro_boleta_sobre);
    
    // Actualizamos la orden seleccionada en la UI
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
}

async function eliminarPago(codPago) {
  if (confirm("¿Estás seguro de eliminar este pago?")) {
    const { data: pagoData } = await supabase.from("pagos_orden").select("monto_pago, nro_boleta_sobre").eq("cod_pago", codPago).single();
    if (pagoData) {
      await supabase.from("pagos_orden").delete().eq("cod_pago", codPago);
      await cargarOrdenes(); // Recargar todas las órdenes para recalcular saldos
      await cargarPagosOrden(pagoData.nro_boleta_sobre); // Recargar pagos de la orden afectada
      
      const ordenActualizada = ordenes.value.find(o => o.nro_boleta_sobre === pagoData.nro_boleta_sobre);
      if (ordenActualizada) {
        ordenSeleccionada.value = ordenActualizada;
      }
    }
  }
}

function abrirModalCrear() {
  editId.value = null;
  limpiarFormulario();
  cargarDatos();
  showModal.value = true;
  nextTick(() => nroSobreInput.value?.focus());
}

function editarOrden(orden) {
  editId.value = orden.nro_boleta_sobre;
  formOrden.value = { ...orden };
  showModal.value = true;
  dropdownAbierto.value = null; // Cerrar dropdown
}

function verDetalleOrden(orden) {
  ordenSeleccionada.value = orden;
  showModalDetalle.value = true;
  dropdownAbierto.value = null; // Cerrar dropdown
}

function cambiarEstado(orden) {
  ordenSeleccionada.value = orden;
  nuevoEstado.value = orden.estado_orden;
  showModalEstado.value = true;
  dropdownAbierto.value = null; // Cerrar dropdown
}

async function abrirModalPagos(orden) {
  ordenSeleccionada.value = orden;
  await cargarPagosOrden(orden.nro_boleta_sobre);
  showModalPagos.value = true;
  dropdownAbierto.value = null; // Cerrar dropdown
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

function aplicarFiltros() { /* El computed lo hace automáticamente */ }

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

function formatearFecha(fecha) { return new Date(fecha).toLocaleDateString('es-ES'); }
function formatearFechaHora(fecha) { return new Date(fecha).toLocaleString('es-ES'); }

onMounted(cargarDatos);

</script>

<style scoped>
/* ESTILOS ESPECÍFICOS DEL COMPONENTE, LOS ESTILOS DEL MODAL FUERON REMOVIDOS */

.orden-trabajo-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #e0e0e0;
}
.filtros {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 4px;
  flex-wrap: wrap;
}
.filtros select,
.filtros input {
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  flex: 1;
  min-width: 200px;
}
table {
  width: 100%;
  border-collapse: collapse;
}
th {
  background: #343a40;
  color: white;
  padding: 12px 8px;
  text-align: left;
  font-size: 13px;
  font-weight: 500;
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
.saldo-pendiente {
  color: #dc3545;
  font-weight: bold;
}
.estado-pendiente, .estado-en_proceso, .estado-terminado, .estado-entregado, .estado-cancelado {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 500;
  white-space: nowrap;
}
.estado-pendiente { background: #fff3cd; color: #856404; }
.estado-en_proceso { background: #cce5ff; color: #004085; }
.estado-terminado { background: #d4edda; color: #155724; }
.estado-entregado { background: #e2e3e5; color: #383d41; }
.estado-cancelado { background: #f8d7da; color: #721c24; }

.acciones-cell {
  position: relative;
  text-align: center;
}
.dropdown-container {
  display: inline-block;
  position: relative;
}
.btn-acciones {
  padding: 6px 12px;
  border: 1px solid #6c757d;
  background-color: #f8f9fa;
  color: #343a40;
  border-radius: 4px;
  cursor: pointer;
}
.dropdown-menu {
  position: absolute;
  right: 0;
  top: 100%;
  background-color: white;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
  z-index: 100;
  min-width: 160px;
  display: flex;
  flex-direction: column;
}
.dropdown-menu a {
  padding: 10px 15px;
  text-decoration: none;
  color: #333;
  display: block;
  cursor: pointer;
  font-size: 14px;
}
.dropdown-menu a:hover {
  background-color: #f2f2f2;
}
.dropdown-danger {
    color: #dc3545 !important;
}
.dropdown-danger:hover {
    background-color: #f8d7da !important;
}

.btn-eliminar {
  background-color: transparent;
  border: 1px solid #dc3545;
  color: #dc3545;
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
}
.btn-eliminar:hover {
    background-color: #dc3545;
    color: white;
}

/* ESTILOS PARA BOTONES GENERALES */
.btn {
  padding: 10px 20px;
  margin: 0 5px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s ease;
  text-transform: uppercase;
}
.btn-primary {
  background-color: #007bff;
  color: white;
}
.btn-primary:hover {
  background-color: #0056b3;
}
.btn-secondary {
  background-color: #6c757d;
  color: white;
}
.btn-secondary:hover {
  background-color: #5a6268;
}
.btn-success {
    background-color: #28a745;
    color: white;
}
.btn-success:hover {
    background-color: #218838;
}
.btn-success:disabled {
    background-color: #a3d9b1;
    cursor: not-allowed;
}

/* ESTILOS PARA EL CONTENIDO DENTRO DE LOS MODALES */
.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 15px;
}
.form-grid-pago {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr auto;
  gap: 15px;
  align-items: end;
}
.form-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}
.full-width {
  grid-column: 1 / -1;
}
.form-group label {
  font-weight: 500;
  color: #333;
  font-size: 14px;
}
.form-group input, .form-group select, .form-group textarea {
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  width: 100%;
  box-sizing: border-box;
}
.detalle-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}
.observaciones {
  margin-top: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 4px;
  border-left: 4px solid #007bff;
}
.resumen-orden {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
  border: 1px solid #e9ecef;
}
.resumen-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}
.highlight {
  font-weight: bold;
  color: #155724;
}
.highlight-saldo {
    font-weight: bold;
    color: #dc3545;
}
.nuevo-pago, .pagos-existentes {
  border: 1px solid #dee2e6;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
}
.nuevo-pago h4, .pagos-existentes h4 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #495057;
  font-size: 16px;
}
.tabla-pagos {
  width: 100%;
  border-collapse: collapse;
}
.tabla-pagos th { background: #e9ecef; color: #495057; padding: 10px 8px; text-align: left; }
.tabla-pagos td { padding: 10px 8px; border-bottom: 1px solid #dee2e6; }
.no-pagos { text-align: center; color: #6c757d; font-style: italic; margin: 20px 0; }

@media (max-width: 768px) {
  .table-container { overflow-x: auto; }
  table { min-width: 800px; }
  .form-grid, .detalle-grid, .resumen-grid, .form-grid-pago {
    grid-template-columns: 1fr;
  }
}
</style>