<template>
  <v-container fluid class="bg-grey-lighten-4 pa-6" style="min-height: 100vh;">
    <!-- Encabezado -->
    <div class="d-flex flex-wrap justify-space-between align-center mb-6">
      <div>
        <h1 class="text-h4 font-weight-bold text-grey-darken-3">Dashboard de Prescripciones</h1>
        <p class="text-subtitle-1 text-grey-darken-1 mb-0">Analítica avanzada de ventas, tratamientos y tipos de lentes.</p>
      </div>
      <div class="mt-4 mt-sm-0 d-flex flex-wrap gap-2">
        <v-btn color="info" prepend-icon="mdi-chart-box-outline" @click="exportarDashboardPDF" :loading="cargandoDashboardPdf" :disabled="resultadosBusqueda.length === 0 || cargando">
          Gráficas PDF
        </v-btn>
        <v-btn color="success" prepend-icon="mdi-file-excel" @click="exportarCSV" :disabled="resultadosBusqueda.length === 0 || cargando">
          Tabla CSV
        </v-btn>
        <v-btn color="error" prepend-icon="mdi-file-pdf-box" @click="exportarPDF" :disabled="resultadosBusqueda.length === 0 || cargando">
          Tabla PDF
        </v-btn>
      </div>
    </div>

    <!-- Barra de Filtros -->
    <v-card class="mb-6 rounded-lg elevation-2">
      <v-card-text class="pa-4">
        <v-row dense align="center">
          <v-col cols="12" md="2">
            <v-text-field v-model="filtros.fechaInicio" label="Desde (Prescrip.)" type="date" variant="outlined" density="compact" hide-details></v-text-field>
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="filtros.fechaFin" label="Hasta (Prescrip.)" type="date" variant="outlined" density="compact" hide-details></v-text-field>
          </v-col>
          <v-col cols="12" md="2">
            <v-autocomplete v-model="filtros.doctor" :items="doctoresOptions" item-title="label" item-value="value" label="Doctor" variant="outlined" density="compact" hide-details clearable></v-autocomplete>
          </v-col>
          <v-col cols="12" md="2">
            <v-autocomplete v-model="filtros.proveedor" :items="proveedoresOptions" item-title="label" item-value="value" label="Proveedor" variant="outlined" density="compact" hide-details clearable></v-autocomplete>
          </v-col>
          <v-col cols="12" md="2">
            <v-autocomplete v-model="filtros.armazon" :items="armazonesOptions" item-title="label" item-value="value" label="Armazón" variant="outlined" density="compact" hide-details clearable></v-autocomplete>
          </v-col>
          <v-col cols="12" md="2">
            <v-btn color="primary" variant="flat" block @click="aplicarFiltros" :loading="cargando" prepend-icon="mdi-magnify">
              Filtrar
            </v-btn>
          </v-col>
        </v-row>
      </v-card-text>
    </v-card>

    <v-progress-linear v-if="cargando" indeterminate color="primary" class="mb-4 rounded"></v-progress-linear>

    <v-alert v-if="busquedaRealizada && !cargando && resultadosBusqueda.length === 0" type="info" variant="tonal" icon="mdi-information-outline" class="mb-6">
      No se encontraron resultados para los filtros seleccionados en este período.
    </v-alert>

    <template v-if="!cargando && resultadosBusqueda.length > 0">
      <!-- Tarjetas KPI -->
      <v-row class="mb-4">
        <!-- KPI 1 -->
        <v-col cols="12" sm="6" md="3">
          <v-card class="rounded-lg elevation-2 border-l-primary h-100">
            <v-card-text class="d-flex align-center h-100">
              <v-avatar color="primary-lighten-4" class="mr-4" size="56">
                <v-icon color="primary" size="32">mdi-receipt-text-check</v-icon>
              </v-avatar>
              <div>
                <div class="text-caption text-uppercase text-grey-darken-1 font-weight-bold">Total Prescripciones</div>
                <div class="text-h4 font-weight-black text-grey-darken-4">{{ totalResultados }}</div>
              </div>
            </v-card-text>
          </v-card>
        </v-col>
        <!-- KPI 2 -->
        <v-col cols="12" sm="6" md="3">
          <v-card class="rounded-lg elevation-2 border-l-info h-100">
            <v-card-text class="d-flex align-center h-100">
              <v-avatar color="info-lighten-4" class="mr-4" size="56">
                <v-icon color="info" size="32">mdi-doctor</v-icon>
              </v-avatar>
              <div class="w-100 overflow-hidden">
                <div class="text-caption text-uppercase text-grey-darken-1 font-weight-bold">Doctor Principal</div>
                <div class="text-h6 font-weight-bold text-grey-darken-4 text-truncate" :title="kpiDoctorEstrella.nombre">{{ kpiDoctorEstrella.nombre }}</div>
                <div class="text-caption">{{ kpiDoctorEstrella.cantidad }} prescripciones</div>
              </div>
            </v-card-text>
          </v-card>
        </v-col>
        <!-- KPI 3 -->
        <v-col cols="12" sm="6" md="3">
          <v-card class="rounded-lg elevation-2 border-l-success h-100">
            <v-card-text class="d-flex align-center h-100">
              <v-avatar color="success-lighten-4" class="mr-4" size="56">
                <v-icon color="success" size="32">mdi-star-circle</v-icon>
              </v-avatar>
              <div class="w-100 overflow-hidden">
                <div class="text-caption text-uppercase text-grey-darken-1 font-weight-bold">Tratamiento Top</div>
                <div class="text-h6 font-weight-bold text-grey-darken-4 text-truncate" :title="kpiTratamientoTop.nombre">{{ kpiTratamientoTop.nombre }}</div>
                <div class="text-caption">{{ kpiTratamientoTop.cantidad }} aplicaciones</div>
              </div>
            </v-card-text>
          </v-card>
        </v-col>
        <!-- KPI 4 -->
        <v-col cols="12" sm="6" md="3">
          <v-card class="rounded-lg elevation-2 border-l-warning h-100">
            <v-card-text class="d-flex align-center h-100">
              <v-avatar color="warning-lighten-4" class="mr-4" size="56">
                <v-icon color="warning" size="32">mdi-glasses</v-icon>
              </v-avatar>
              <div>
                <div class="text-caption text-uppercase text-grey-darken-1 font-weight-bold">Ventas Progresivos</div>
                <div class="text-h4 font-weight-black text-grey-darken-4">{{ kpiPorcentajeProgresivos }}%</div>
                <div class="text-caption">Del total de lentes</div>
              </div>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- Grid de Gráficas -->
      <v-row class="mb-4">
        <!-- Gráfico de Tendencia -->
        <v-col cols="12" md="8">
          <v-card class="rounded-lg elevation-2 h-100">
            <v-card-title class="font-weight-bold">
              Evolución de Prescripciones
            </v-card-title>
            <v-card-text>
              <VueApexCharts ref="chartTendenciaRef" type="area" height="300" :options="chartTendenciaOptions" :series="chartTendenciaSeries"></VueApexCharts>
            </v-card-text>
          </v-card>
        </v-col>
        <!-- Top Tratamientos -->
        <v-col cols="12" md="4">
          <v-card class="rounded-lg elevation-2 h-100">
            <v-card-title class="font-weight-bold">
              Top 5 Tratamientos Solicitados
            </v-card-title>
            <v-card-text>
              <VueApexCharts ref="chartTratamientosRef" type="bar" height="300" :options="chartTratamientosOptions" :series="chartTratamientosSeries"></VueApexCharts>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <v-row class="mb-6">
        <!-- Tipos de Lentes -->
        <v-col cols="12" md="4">
          <v-card class="rounded-lg elevation-2 h-100">
            <v-card-title class="font-weight-bold">
              Tipos de Lentes
            </v-card-title>
            <v-card-text class="d-flex align-center justify-center">
              <VueApexCharts ref="chartDistanciaRef" type="donut" width="100%" height="280" :options="chartDistanciaOptions" :series="chartDistanciaSeries"></VueApexCharts>
            </v-card-text>
          </v-card>
        </v-col>
        <!-- Top Doctores -->
        <v-col cols="12" md="4">
          <v-card class="rounded-lg elevation-2 h-100">
            <v-card-title class="font-weight-bold">
              Top Doctores Prescriptores
            </v-card-title>
            <v-card-text>
              <VueApexCharts ref="chartDoctorRef" type="bar" height="280" :options="chartDoctorOptions" :series="chartDoctorSeries"></VueApexCharts>
            </v-card-text>
          </v-card>
        </v-col>
        <!-- Materiales -->
        <v-col cols="12" md="4">
          <v-card class="rounded-lg elevation-2 h-100">
            <v-card-title class="font-weight-bold">
              Materiales de Cristal
            </v-card-title>
            <v-card-text class="d-flex align-center justify-center">
              <VueApexCharts ref="chartMaterialesRef" type="pie" width="100%" height="280" :options="chartMaterialesOptions" :series="chartMaterialesSeries"></VueApexCharts>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <!-- Tabla de Datos -->
      <v-card class="rounded-lg elevation-2">
        <v-card-title class="font-weight-bold bg-grey-lighten-3 border-b">
          Detalle de Registros
        </v-card-title>
        <v-data-table :headers="tableHeaders" :items="resultadosBusqueda" :items-per-page="10" density="compact" class="elevation-0 text-body-2">
          <template v-slot:item.cliente="{ item }">
            {{ item.clientes?.nombre_cliente }} {{ item.clientes?.apellido_paterno_cliente }}
          </template>
          <template v-slot:item.doctor="{ item }">
            {{ item.doctores?.nombre_doctor }}
          </template>
          <template v-slot:item.proveedor="{ item }">
            {{ item.proveedores ? item.proveedores.nombre_proveedor : '-' }}
          </template>
          <template v-slot:item.armazon="{ item }">
            {{ item.armazon_lente ? item.armazon_lente.nombre_armazon : '-' }}
          </template>
          <template v-slot:item.fecha_prescripcion="{ item }">
            {{ item.fecha_prescripcion ? new Date(item.fecha_prescripcion + 'T00:00:00').toLocaleDateString() : '-' }}
          </template>
          <template v-slot:item.fecha_entrega="{ item }">
            {{ item.fecha_entrega ? new Date(item.fecha_entrega + 'T00:00:00').toLocaleDateString() : '-' }}
          </template>
        </v-data-table>
      </v-card>
    </template>
  </v-container>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { supabase } from '../lib/supabaseClient';
import VueApexCharts from 'vue3-apexcharts';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

const cargando = ref(true);
const cargandoDashboardPdf = ref(false);
const busquedaRealizada = ref(false);
const doctores = ref([]);
const proveedores = ref([]);
const armazones = ref([]);
const materialesDict = ref({});
const resultadosBusqueda = ref([]);

const chartTendenciaRef = ref(null);
const chartTratamientosRef = ref(null);
const chartDistanciaRef = ref(null);
const chartDoctorRef = ref(null);
const chartMaterialesRef = ref(null);

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
  { title: 'F. Prescripción', key: 'fecha_prescripcion', sortable: true },
  { title: 'F. Entrega', key: 'fecha_entrega', sortable: true },
  { title: 'Proveedor', key: 'proveedor', sortable: true },
  { title: 'Armazón', key: 'armazon', sortable: true },
]);

const todosOption = { value: null, label: 'Todos' };

const doctoresOptions = computed(() => [todosOption, ...doctores.value.map(d => ({ value: d.cod_doctor, label: d.nombre_doctor }))]);
const proveedoresOptions = computed(() => [todosOption, ...proveedores.value.map(p => ({ value: p.cod_proveedor, label: p.nombre_proveedor }))]);
const armazonesOptions = computed(() => [todosOption, ...armazones.value.map(a => ({ value: a.cod_armazon, label: a.nombre_armazon }))]);

onMounted(async () => {
  const hoy = new Date();
  const primerDiaMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
  const ultimoDiaMes = new Date(hoy.getFullYear(), hoy.getMonth() + 1, 0);
  
  filtros.value.fechaInicio = primerDiaMes.toISOString().slice(0, 10);
  filtros.value.fechaFin = ultimoDiaMes.toISOString().slice(0, 10);

  await cargarDatosFiltros();
  await aplicarFiltros();
});

const cargarDatosFiltros = async () => {
  try {
    const [doctoresRes, proveedoresRes, armazonesRes, materialesRes] = await Promise.all([
      supabase.from('doctores').select('*').order('nombre_doctor'),
      supabase.from('proveedores').select('*').order('nombre_proveedor'),
      supabase.from('armazon_lente').select('*').order('nombre_armazon'),
      supabase.from('material_cristal').select('cod_material_cristal, nombre_material')
    ]);

    if (doctoresRes.data) doctores.value = doctoresRes.data;
    if (proveedoresRes.data) proveedores.value = proveedoresRes.data;
    if (armazonesRes.data) armazones.value = armazonesRes.data;
    
    if (materialesRes.data) {
      materialesRes.data.forEach(m => {
        materialesDict.value[m.cod_material_cristal] = m.nombre_material;
      });
    }
  } catch (error) {
    console.error("Error cargando filtros:", error);
  }
};

const aplicarFiltros = async () => {
  cargando.value = true;
  busquedaRealizada.value = true;
  try {
    let query = supabase
      .from('prescripcion_clienten')
      .select(`
        cod_prescripcion, cod_receta, fecha_prescripcion, fecha_entrega,
        distancia_lente1, distancia_lente2, l1_material_cristal, l2_material_cristal,
        clientes (nombre_cliente, apellido_paterno_cliente),
        doctores (nombre_doctor),
        proveedores (nombre_proveedor),
        armazon_lente (nombre_armazon)
      `);

    if (filtros.value.fechaInicio) query = query.gte('fecha_prescripcion', filtros.value.fechaInicio);
    if (filtros.value.fechaFin) query = query.lte('fecha_prescripcion', filtros.value.fechaFin);
    if (filtros.value.doctor) query = query.eq('doctor_prescriptor', filtros.value.doctor);
    if (filtros.value.proveedor) query = query.eq('cod_proveedor', filtros.value.proveedor);
    if (filtros.value.armazon) query = query.eq('cod_armazon', filtros.value.armazon);

    const { data, error } = await query.order('fecha_prescripcion', { ascending: true });
    if (error) throw error;

    // Obtener tratamientos por separado debido a falta de foreign key en esquema
    if (data && data.length > 0) {
      const presIds = data.map(p => p.cod_prescripcion);
      const { data: tratData, error: tratError } = await supabase
        .from('prescripcion_tratamiento')
        .select('cod_prescripcion, tratamientos (nombre_tratamiento)')
        .in('cod_prescripcion', presIds);

      if (!tratError && tratData) {
        const tratMap = {};
        tratData.forEach(pt => {
          if (!tratMap[pt.cod_prescripcion]) tratMap[pt.cod_prescripcion] = [];
          tratMap[pt.cod_prescripcion].push(pt);
        });
        data.forEach(p => {
          p.prescripcion_tratamiento = tratMap[p.cod_prescripcion] || [];
        });
      } else {
        data.forEach(p => p.prescripcion_tratamiento = []);
      }
    }

    resultadosBusqueda.value = data || [];
  } catch (error) {
    console.error("Error al buscar:", error);
  } finally {
    cargando.value = false;
  }
};

const totalResultados = computed(() => resultadosBusqueda.value.length);

const kpiDoctorEstrella = computed(() => {
  if (!resultadosBusqueda.value.length) return { nombre: 'N/A', cantidad: 0 };
  const counts = {};
  resultadosBusqueda.value.forEach(p => {
    const doc = p.doctores?.nombre_doctor || 'Desconocido';
    counts[doc] = (counts[doc] || 0) + 1;
  });
  const max = Object.entries(counts).sort((a, b) => b[1] - a[1])[0];
  return { nombre: max[0], cantidad: max[1] };
});

const conteoTratamientos = computed(() => {
  const counts = {};
  resultadosBusqueda.value.forEach(p => {
    if (p.prescripcion_tratamiento) {
      p.prescripcion_tratamiento.forEach(pt => {
        const nombre = pt.tratamientos?.nombre_tratamiento;
        if (nombre) counts[nombre] = (counts[nombre] || 0) + 1;
      });
    }
  });
  return counts;
});

const kpiTratamientoTop = computed(() => {
  const counts = conteoTratamientos.value;
  if (Object.keys(counts).length === 0) return { nombre: 'N/A', cantidad: 0 };
  const max = Object.entries(counts).sort((a, b) => b[1] - a[1])[0];
  return { nombre: max[0], cantidad: max[1] };
});

const kpiPorcentajeProgresivos = computed(() => {
  if (!resultadosBusqueda.value.length) return 0;
  let totalLentes = 0;
  let progresivos = 0;
  resultadosBusqueda.value.forEach(p => {
    if (p.distancia_lente1 && p.distancia_lente1 !== '-') {
      totalLentes++;
      if (p.distancia_lente1.toUpperCase().includes('PROGRESIVO')) progresivos++;
    }
    if (p.distancia_lente2 && p.distancia_lente2 !== '-') {
      totalLentes++;
      if (p.distancia_lente2.toUpperCase().includes('PROGRESIVO')) progresivos++;
    }
  });
  return totalLentes === 0 ? 0 : Math.round((progresivos / totalLentes) * 100);
});

const chartTendenciaOptions = computed(() => ({
  chart: { id: 'area-tendencia', toolbar: { show: false } },
  xaxis: { type: 'datetime' },
  dataLabels: { enabled: false },
  stroke: { curve: 'smooth', width: 3 },
  colors: ['#1867C0'],
  fill: { type: 'gradient', gradient: { shadeIntensity: 1, opacityFrom: 0.7, opacityTo: 0.1 } }
}));

const chartTendenciaSeries = computed(() => {
  const counts = {};
  resultadosBusqueda.value.forEach(p => {
    if (p.fecha_prescripcion) counts[p.fecha_prescripcion] = (counts[p.fecha_prescripcion] || 0) + 1;
  });
  const data = Object.entries(counts)
    .sort((a, b) => new Date(a[0]) - new Date(b[0]))
    .map(([date, count]) => [new Date(date).getTime(), count]);
  return [{ name: 'Ventas', data }];
});

const chartTratamientosOptions = computed(() => ({
  chart: { id: 'bar-tratamientos', toolbar: { show: false } },
  plotOptions: { bar: { horizontal: true, borderRadius: 4 } },
  colors: ['#4CAF50'],
  xaxis: { categories: Object.keys(topTratamientosArray.value) },
  dataLabels: { enabled: true }
}));

const topTratamientosArray = computed(() => {
  const entries = Object.entries(conteoTratamientos.value).sort((a, b) => b[1] - a[1]);
  return Object.fromEntries(entries.slice(0, 5));
});

const chartTratamientosSeries = computed(() => [{
  name: 'Aplicaciones',
  data: Object.values(topTratamientosArray.value)
}]);

const chartDistanciaOptions = computed(() => ({
  chart: { id: 'donut-distancias' },
  labels: Object.keys(conteoDistancias.value),
  colors: ['#2196F3', '#FB8C00', '#9C27B0', '#F44336', '#00BCD4'],
  legend: { position: 'bottom' },
  dataLabels: { enabled: true, formatter: (val) => Math.round(val) + "%" }
}));

const conteoDistancias = computed(() => {
  const counts = {};
  resultadosBusqueda.value.forEach(p => {
    [p.distancia_lente1, p.distancia_lente2].forEach(dist => {
      if (dist && dist !== '-') counts[dist] = (counts[dist] || 0) + 1;
    });
  });
  return counts;
});

const chartDistanciaSeries = computed(() => Object.values(conteoDistancias.value));

const chartMaterialesOptions = computed(() => ({
  chart: { id: 'pie-materiales' },
  labels: Object.keys(conteoMateriales.value),
  legend: { position: 'bottom' }
}));

const conteoMateriales = computed(() => {
  const counts = {};
  resultadosBusqueda.value.forEach(p => {
    [p.l1_material_cristal, p.l2_material_cristal].forEach(matId => {
      if (matId) {
        const nombre = materialesDict.value[matId] || `Material #${matId}`;
        counts[nombre] = (counts[nombre] || 0) + 1;
      }
    });
  });
  return counts;
});

const chartMaterialesSeries = computed(() => Object.values(conteoMateriales.value));

const chartDoctorOptions = computed(() => ({
  chart: { id: 'bar-doctores', toolbar: { show: false } },
  colors: ['#673AB7'],
  xaxis: { categories: Object.keys(topDoctoresArray.value) },
  plotOptions: { bar: { borderRadius: 4, distributed: true } },
  legend: { show: false },
  dataLabels: { enabled: true }
}));

const topDoctoresArray = computed(() => {
  const counts = {};
  resultadosBusqueda.value.forEach(p => {
    const doc = p.doctores?.nombre_doctor || 'Desconocido';
    counts[doc] = (counts[doc] || 0) + 1;
  });
  const entries = Object.entries(counts).sort((a, b) => b[1] - a[1]);
  return Object.fromEntries(entries.slice(0, 5));
});

const chartDoctorSeries = computed(() => [{
  name: 'Prescripciones',
  data: Object.values(topDoctoresArray.value)
}]);

const exportarDashboardPDF = async () => {
  cargandoDashboardPdf.value = true;
  try {
    const doc = new jsPDF();
    doc.setFontSize(18);
    doc.text('Dashboard de Prescripciones', 14, 22);
    doc.setFontSize(10);
    doc.text(`Generado el: ${new Date().toLocaleDateString()} ${new Date().toLocaleTimeString()}`, 14, 30);
    
    // Obtener las imagenes de los gráficos (dataURIs)
    const tendenciaUri = await chartTendenciaRef.value.chart.dataURI();
    const tratamientosUri = await chartTratamientosRef.value.chart.dataURI();
    const distanciaUri = await chartDistanciaRef.value.chart.dataURI();
    const materialesUri = await chartMaterialesRef.value.chart.dataURI();
    const doctorUri = await chartDoctorRef.value.chart.dataURI();
    
    // Agregamos las gráficas al PDF
    doc.addImage(tendenciaUri.imgURI, 'PNG', 14, 40, 180, 60);
    
    doc.setFontSize(12);
    doc.text('Top Tratamientos', 14, 110);
    doc.addImage(tratamientosUri.imgURI, 'PNG', 14, 115, 85, 60);
    
    doc.text('Top Doctores', 110, 110);
    doc.addImage(doctorUri.imgURI, 'PNG', 110, 115, 85, 60);
    
    // Nueva página para gráficos circulares
    doc.addPage();
    doc.setFontSize(18);
    doc.text('Dashboard de Prescripciones (Continuación)', 14, 22);
    
    doc.setFontSize(12);
    doc.text('Tipos de Lentes', 14, 40);
    doc.addImage(distanciaUri.imgURI, 'PNG', 14, 45, 90, 80);
    
    doc.text('Materiales de Cristal', 110, 40);
    doc.addImage(materialesUri.imgURI, 'PNG', 110, 45, 90, 80);
    
    doc.save(`dashboard_graficas_${new Date().toISOString().slice(0, 10)}.pdf`);
  } catch (error) {
    console.error("Error al exportar dashboard", error);
  } finally {
    cargandoDashboardPdf.value = false;
  }
};

const exportarPDF = () => {
  const doc = new jsPDF();
  doc.setFontSize(18);
  doc.text('Reporte de Prescripciones', 14, 22);
  doc.setFontSize(10);
  doc.text(`Generado el: ${new Date().toLocaleDateString()} ${new Date().toLocaleTimeString()}`, 14, 30);
  
  const columns = [
    { header: 'Cód. Receta', dataKey: 'cod_receta' },
    { header: 'Cliente', dataKey: 'cliente' },
    { header: 'Doctor', dataKey: 'doctor' },
    { header: 'F. Entrega', dataKey: 'fecha_entrega' },
    { header: 'Proveedor', dataKey: 'proveedor' }
  ];

  const rows = resultadosBusqueda.value.map(item => ({
    cod_receta: item.cod_receta,
    cliente: `${item.clientes?.nombre_cliente || ''} ${item.clientes?.apellido_paterno_cliente || ''}`,
    doctor: item.doctores?.nombre_doctor || '-',
    fecha_entrega: item.fecha_entrega ? new Date(item.fecha_entrega + 'T00:00:00').toLocaleDateString() : '-',
    proveedor: item.proveedores?.nombre_proveedor || '-'
  }));

  autoTable(doc, {
    startY: 40,
    head: [columns.map(col => col.header)],
    body: rows.map(row => columns.map(col => row[col.dataKey])),
    theme: 'striped',
    headStyles: { fillColor: [25, 118, 210] },
    styles: { fontSize: 8 },
  });

  doc.save(`reporte_prescripciones_${new Date().toISOString().slice(0, 10)}.pdf`);
};

const exportarCSV = () => {
  if (resultadosBusqueda.value.length === 0) return;
  
  const encabezados = ['Cod. Receta', 'Cliente', 'Doctor', 'Fecha Prescripcion', 'Fecha Entrega', 'Proveedor', 'Armazon', 'Distancia 1', 'Distancia 2', 'Material 1', 'Material 2', 'Tratamientos'];
  const lineas = [encabezados.join(';')];
  
  resultadosBusqueda.value.forEach(item => {
    const tratamientosText = item.prescripcion_tratamiento 
      ? item.prescripcion_tratamiento.map(pt => pt.tratamientos?.nombre_tratamiento).filter(Boolean).join(', ')
      : '';
    
    const mat1 = item.l1_material_cristal ? materialesDict.value[item.l1_material_cristal] || '' : '';
    const mat2 = item.l2_material_cristal ? materialesDict.value[item.l2_material_cristal] || '' : '';

    const fila = [
      item.cod_receta || '',
      `${item.clientes?.nombre_cliente || ''} ${item.clientes?.apellido_paterno_cliente || ''}`,
      item.doctores?.nombre_doctor || '',
      item.fecha_prescripcion || '',
      item.fecha_entrega || '',
      item.proveedores?.nombre_proveedor || '',
      item.armazon_lente?.nombre_armazon || '',
      item.distancia_lente1 || '',
      item.distancia_lente2 || '',
      mat1,
      mat2,
      tratamientosText
    ];
    
    const filaEscapada = fila.map(campo => {
      let texto = String(campo);
      if (texto.includes(';') || texto.includes('"')) {
        return `"${texto.replace(/"/g, '""')}"`;
      }
      return texto;
    });

    lineas.push(filaEscapada.join(';'));
  });
  
  const csvData = new Blob(['\uFEFF' + lineas.join('\n')], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(csvData);
  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', `reporte_ventas_${new Date().toISOString().slice(0, 10)}.csv`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};
</script>

<style scoped>
.border-l-primary { border-left: 5px solid #1867C0 !important; }
.border-l-info { border-left: 5px solid #2196F3 !important; }
.border-l-success { border-left: 5px solid #4CAF50 !important; }
.border-l-warning { border-left: 5px solid #FB8C00 !important; }
</style>