<template>
  <v-container fluid>
    <v-card class="mb-4">
      <v-card-title class="text-h5">Reporte de Prescripciones</v-card-title>
      <v-card-subtitle>Filtra y analiza los registros de prescripciones por fecha, doctor, proveedor y
        armazón.</v-card-subtitle>
    </v-card>

    <v-card class="mb-4">
      <v-card-title class="text-subtitle-1 font-weight-bold"> Filtros de Búsqueda</v-card-title>
      <v-card-text>
        <v-row dense>
          <v-col cols="12" md="3">
            <v-text-field v-model="filtros.fechaInicio" label="Fecha Inicial (Entrega)" type="date" variant="outlined"
              density="compact" clearable></v-text-field>
          </v-col>
          <v-col cols="12" md="3">
            <v-text-field v-model="filtros.fechaFin" label="Fecha Final (Entrega)" type="date" variant="outlined"
              density="compact" clearable></v-text-field>
          </v-col>

          <v-col cols="12" md="2">
            <v-autocomplete v-model="filtros.doctor" :items="doctoresOptions" item-title="label" item-value="value"
              label="Doctor" variant="outlined" density="compact" clearable></v-autocomplete>
          </v-col>
          <v-col cols="12" md="2">
            <v-autocomplete v-model="filtros.proveedor" :items="proveedoresOptions" item-title="label"
              item-value="value" label="Proveedor" variant="outlined" density="compact" clearable></v-autocomplete>
          </v-col>
          <v-col cols="12" md="2">
            <v-autocomplete v-model="filtros.armazon" :items="armazonesOptions" item-title="label" item-value="value"
              label="Armazón" variant="outlined" density="compact" clearable></v-autocomplete>
          </v-col>
        </v-row>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn @click="limpiarFiltros" variant="text" prepend-icon="mdi-broom">
          Limpiar
        </v-btn>
        <v-btn @click="aplicarFiltros" color="primary" variant="flat" prepend-icon="mdi-magnify" :loading="cargando">
          Filtrar
        </v-btn>
        <v-btn @click="exportarPDF" color="secondary" variant="flat" prepend-icon="mdi-file-pdf-box"
          :disabled="resultadosBusqueda.length === 0 || cargando" class="ml-2">
          Exportar PDF
        </v-btn>
      </v-card-actions>
    </v-card>

    <v-progress-linear v-if="cargando" indeterminate color="primary" class="my-4"></v-progress-linear>

    <v-alert v-if="busquedaRealizada && !cargando && resultadosBusqueda.length === 0" type="info" variant="outlined"
      icon="mdi-information-outline" class="mt-4">
      No se encontraron resultados para los filtros seleccionados.
    </v-alert>

    <v-row v-if="!cargando && resultadosBusqueda.length > 0">

      <v-col cols="12" md="3">
        <v-card class="mb-4" style="position: sticky; top: 80px;">
          <v-card-text class="text-center">
            <div class="text-h4 font-weight-bold">{{ totalResultados }}</div>
            <div class="text-subtitle-1">Prescripciones Encontradas</div>
          </v-card-text>
        </v-card>

        <v-card class="mb-4">
          <v-card-title>Resumen por Doctor</v-card-title>
          <v-list density="compact">
            <v-list-item v-for="(count, doctor) in resumenPorDoctor" :key="doctor" :title="doctor"
              :subtitle="`${count} prescripciones`"></v-list-item>
          </v-list>
        </v-card>

        <v-card class="mb-4">
          <v-card-title>Resumen por Proveedor</v-card-title>
          <v-list density="compact">
            <v-list-item v-for="(count, proveedor) in resumenPorProveedor" :key="proveedor" :title="proveedor"
              :subtitle="`${count} prescripci(ón/ones)`"></v-list-item>
          </v-list>
        </v-card>

        <v-card>
          <v-card-title>Resumen por Armazón</v-card-title>
          <v-list density="compact">
            <v-list-item v-for="(count, armazon) in resumenPorArmazon" :key="armazon" :title="armazon"
              :subtitle="`${count} prescripci(ón/ones)`"></v-list-item>
          </v-list>
        </v-card>
      </v-col>

      <v-col cols="12" md="9">
        <v-card>
          <v-tabs v-model="tab" bg-color="primary" fixed-tabs>
            <v-tab value="detalle" prepend-icon="mdi-table">Detalle (Tabla)</v-tab>
            <v-tab value="graficas" prepend-icon="mdi-chart-bar">Resumen (Gráficas)</v-tab>
          </v-tabs>

          <v-card-text class="pt-4">
            <v-window v-model="tab">

              <v-window-item value="detalle">
                <v-data-table :headers="tableHeaders" :items="resultadosBusqueda" :items-per-page="15"
                  class="elevation-0" density="compact">
                  <template v-slot:item.cliente="{ item }">
                    {{ item.clientes.nombre_cliente }} {{ item.clientes.apellido_paterno_cliente }}
                  </template>
                  <template v-slot:item.doctor="{ item }">
                    {{ item.doctores.nombre_doctor }}
                  </template>
                  <template v-slot:item.proveedor="{ item }">
                    {{ item.proveedores ? item.proveedores.nombre_proveedor : 'N/A' }}
                  </template>
                  <template v-slot:item.armazon="{ item }">
                    {{ item.armazon_lente ? item.armazon_lente.nombre_armazon : 'N/A' }}
                  </template>
                  <template v-slot:item.fecha_prescripcion="{ item }">
                    {{ new Date(item.fecha_prescripcion + 'T00:00:00').toLocaleDateString() }}
                  </template>
                  <template v-slot:item.fecha_entrega="{ item }">
                    {{ new Date(item.fecha_entrega + 'T00:00:00').toLocaleDateString() }}
                  </template>
                </v-data-table>
              </v-window-item>

              <v-window-item value="graficas">
                <v-row>
                  <v-col cols="12">
                    <v-card variant="outlined">
                      <v-card-title>Prescripciones por Doctor (Top 5 + Otros)</v-card-title>
                      <v-card-text>
                        <VueApexCharts type="bar" height="350" :options="chartDoctorOptions"
                          :series="chartDoctorSeries">
                        </VueApexCharts>
                      </v-card-text>
                    </v-card>
                  </v-col>

                  <v-col cols="12" md="6">
                    <v-card variant="outlined">
                      <v-card-title>Distribución por Proveedor</v-card-title>
                      <v-card-text>
                        <VueApexCharts type="pie" height="350" :options="chartProveedorOptions"
                          :series="chartProveedorSeries">
                        </VueApexCharts>
                      </v-card-text>
                    </v-card>
                  </v-col>

                  <v-col cols="12" md="6">
                    <v-card variant="outlined">
                      <v-card-title>Distribución por Armazón</v-card-title>
                      <v-card-text>
                        <VueApexCharts type="donut" height="350" :options="chartArmazonOptions"
                          :series="chartArmazonSeries">
                        </VueApexCharts>
                      </v-card-text>
                    </v-card>
                  </v-col>
                </v-row>
              </v-window-item>

            </v-window>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { supabase } from '../lib/supabaseClient';
import VueApexCharts from 'vue3-apexcharts';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

const cargando = ref(true);
const busquedaRealizada = ref(false);
const doctores = ref([]);
const proveedores = ref([]);
const armazones = ref([]);
const resultadosBusqueda = ref([]);

const tab = ref('detalle');

const filtros = ref({
  fechaInicio: '',
  fechaFin: '',
  doctor: null,
  proveedor: null,
  armazon: null,
});

const tableHeaders = ref([
  { title: 'Cód. Receta', key: 'cod_receta', sortable: true },
  { title: 'Cliente', key: 'cliente', sortable: true },
  { title: 'Doctor', key: 'doctor', sortable: true },
  { title: 'Fecha Prescripción', key: 'fecha_prescripcion', sortable: true },
  { title: 'Fecha Entrega', key: 'fecha_entrega', sortable: true },
  { title: 'Proveedor', key: 'proveedor', sortable: true },
  { title: 'Armazón', key: 'armazon', sortable: true },
]);


const todosOption = { value: null, label: 'Todos' };

const doctoresOptions = computed(() => [
  todosOption,
  ...doctores.value.map(d => ({ value: d.cod_doctor, label: d.nombre_doctor }))
]);

const proveedoresOptions = computed(() => [
  todosOption,
  ...proveedores.value.map(p => ({ value: p.cod_proveedor, label: p.nombre_proveedor }))
]);

const armazonesOptions = computed(() => [
  todosOption,
  ...armazones.value.map(a => ({ value: a.cod_armazon, label: a.nombre_armazon }))
]);

onMounted(async () => {
  await cargarDatosFiltros();
});

const cargarDatosFiltros = async () => {
  cargando.value = true;
  try {
    const [doctoresRes, proveedoresRes, armazonesRes] = await Promise.all([
      supabase.from('doctores').select('*').order('nombre_doctor'),
      supabase.from('proveedores').select('*').order('nombre_proveedor'),
      supabase.from('armazon_lente').select('*').order('nombre_armazon')
    ]);

    if (doctoresRes.data) doctores.value = doctoresRes.data;
    if (proveedoresRes.data) proveedores.value = proveedoresRes.data;
    if (armazonesRes.data) armazones.value = armazonesRes.data;

  } catch (error) {
    console.error("Error cargando datos para filtros:", error);
    alert('No se pudieron cargar los datos de los filtros: ' + error.message);
  } finally {
    cargando.value = false;
  }
};

const aplicarFiltros = async () => {
  cargando.value = true;
  busquedaRealizada.value = true;

  try {
    let query = supabase
      .from('prescripcion_clienten')
      .select(`
        cod_prescripcion,
        cod_receta,
        fecha_prescripcion,
        fecha_entrega,
        clientes (nombre_cliente, apellido_paterno_cliente),
        doctores (nombre_doctor),
        proveedores (nombre_proveedor),
        armazon_lente (nombre_armazon)
      `);

    if (filtros.value.fechaInicio) {
      query = query.gte('fecha_entrega', filtros.value.fechaInicio);
    }
    if (filtros.value.fechaFin) {
      query = query.lte('fecha_entrega', filtros.value.fechaFin);
    }

    if (filtros.value.doctor) {
      query = query.eq('doctor_prescriptor', filtros.value.doctor);
    }
    if (filtros.value.proveedor) {
      query = query.eq('cod_proveedor', filtros.value.proveedor);
    }
    if (filtros.value.armazon) {
      query = query.eq('cod_armazon', filtros.value.armazon);
    }

    const { data, error } = await query.order('fecha_entrega', { ascending: false });

    if (error) throw error;

    resultadosBusqueda.value = data;
    tab.value = 'detalle'; // Regresar a la pestaña de detalle en cada nueva búsqueda

  } catch (error) {
    console.error("Error al buscar prescripciones:", error);
    alert('No se pudieron obtener los datos: ' + error.message);
  } finally {
    cargando.value = false;
  }
};

const exportarPDF = () => {
  const doc = new jsPDF();

  // Título
  doc.setFontSize(18);
  doc.text('Reporte de Prescripciones', 14, 22);

  // Fecha de generación
  doc.setFontSize(10);
  doc.text(`Generado el: ${new Date().toLocaleDateString()} ${new Date().toLocaleTimeString()}`, 14, 30);

  // Definir columnas y filas para la tabla
  const columns = [
    { header: 'Cód. Receta', dataKey: 'cod_receta' },
    { header: 'Cliente', dataKey: 'cliente' },
    { header: 'Doctor', dataKey: 'doctor' },
    { header: 'F. Prescripción', dataKey: 'fecha_prescripcion' },
    { header: 'F. Entrega', dataKey: 'fecha_entrega' },
    { header: 'Proveedor', dataKey: 'proveedor' },
    { header: 'Armazón', dataKey: 'armazon' },
  ];

  const rows = resultadosBusqueda.value.map(item => ({
    cod_receta: item.cod_receta,
    cliente: `${item.clientes.nombre_cliente} ${item.clientes.apellido_paterno_cliente}`,
    doctor: item.doctores.nombre_doctor,
    fecha_prescripcion: new Date(item.fecha_prescripcion + 'T00:00:00').toLocaleDateString(),
    fecha_entrega: new Date(item.fecha_entrega + 'T00:00:00').toLocaleDateString(),
    proveedor: item.proveedores ? item.proveedores.nombre_proveedor : 'N/A',
    armazon: item.armazon_lente ? item.armazon_lente.nombre_armazon : 'N/A',
  }));

  // Generar tabla
  autoTable(doc, {
    startY: 35,
    head: [columns.map(col => col.header)],
    body: rows.map(row => columns.map(col => row[col.dataKey])),
    theme: 'striped',
    headStyles: { fillColor: [25, 118, 210] }, // Color primario (azul)
    styles: { fontSize: 8 },
  });

  // Guardar PDF
  doc.save(`reporte_prescripciones_${new Date().toISOString().slice(0, 10)}.pdf`);
};

const limpiarFiltros = () => {
  filtros.value = {
    fechaInicio: '',
    fechaFin: '',
    doctor: null,
    proveedor: null,
    armazon: null,
  };
  resultadosBusqueda.value = [];
  busquedaRealizada.value = false;
};

const totalResultados = computed(() => resultadosBusqueda.value.length);

const crearResumen = (campo, nombreSubcampo, defaultNombre) => {
  if (!resultadosBusqueda.value.length) return {};

  return resultadosBusqueda.value.reduce((acc, prescripcion) => {
    const nombre = prescripcion[campo]?.[nombreSubcampo] || defaultNombre;
    acc[nombre] = (acc[nombre] || 0) + 1;
    return acc;
  }, {});
};

const resumenPorDoctor = computed(() => crearResumen('doctores', 'nombre_doctor', 'Desconocido'));
const resumenPorProveedor = computed(() => crearResumen('proveedores', 'nombre_proveedor', 'N/A'));
const resumenPorArmazon = computed(() => crearResumen('armazon_lente', 'nombre_armazon', 'N/A'));

// 1. Lógica para agrupar Doctores (Top 5 + Otros)
const resumenDoctorAgrupado = computed(() => {
  const resumen = resumenPorDoctor.value;
  // Convertir el objeto a un array [nombre, total] y ordenarlo
  const entries = Object.entries(resumen).sort(([, countA], [, countB]) => countB - countA);

  // Si hay 5 o menos, devolver el resumen tal cual
  if (entries.length <= 5) {
    return resumen;
  }

  // Tomar el Top 5
  const top5 = entries.slice(0, 5);
  // Agrupar el resto
  const otros = entries.slice(5);

  // Crear el nuevo objeto agrupado
  const grouped = Object.fromEntries(top5);
  // Sumar el resto en la categoría "OTROS"
  grouped['OTROS'] = otros.reduce((acc, [, count]) => acc + count, 0);

  return grouped;
});

// 2. Datos para el Gráfico de Doctores (Barras)
const chartDoctorOptions = computed(() => ({
  chart: { id: 'bar-doctores' },
  xaxis: {
    categories: Object.keys(resumenDoctorAgrupado.value)
  },
  tooltip: {
    y: { formatter: (val) => `${val} prescripciones` }
  }
}));

const chartDoctorSeries = computed(() => [{
  name: 'Prescripciones',
  data: Object.values(resumenDoctorAgrupado.value)
}]);

// 3. Datos para el Gráfico de Proveedores (Torta/Pie)
const chartProveedorOptions = computed(() => ({
  chart: { id: 'pie-proveedores' },
  labels: Object.keys(resumenPorProveedor.value),
  responsive: [{
    breakpoint: 480,
    options: { legend: { position: 'bottom' } }
  }],
  tooltip: {
    y: { formatter: (val) => `${val} prescripciones` }
  }
}));

const chartProveedorSeries = computed(() => Object.values(resumenPorProveedor.value));

// 4. Datos para el Gráfico de Armazones (Dona/Donut)
const chartArmazonOptions = computed(() => ({
  chart: { id: 'donut-armazones' },
  labels: Object.keys(resumenPorArmazon.value),
  responsive: [{
    breakpoint: 480,
    options: { legend: { position: 'bottom' } }
  }],
  tooltip: {
    y: { formatter: (val) => `${val} prescripciones` }
  }
}));

const chartArmazonSeries = computed(() => Object.values(resumenPorArmazon.value));

</script>

<style scoped></style>