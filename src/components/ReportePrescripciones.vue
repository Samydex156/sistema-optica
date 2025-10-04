<template>
  <div class="report-container">
    <header class="report-header">
      <h1>Reporte de Prescripciones</h1>
      <p>Filtra y analiza los registros de prescripciones por fecha de entrega y doctor.</p>
    </header>

    <div class="filters-card">
      <div class="form-group">
        <label for="fecha-inicio">Fecha Inicial</label>
        <input v-model="filtros.fechaInicio" type="date" id="fecha-inicio" class="form-input" />
      </div>
      <div class="form-group">
        <label for="fecha-fin">Fecha Final</label>
        <input v-model="filtros.fechaFin" type="date" id="fecha-fin" class="form-input" />
      </div>
      <div class="form-group doctor-filter">
        <label for="doctor">Doctor</label>
        <select v-model="filtros.doctor" id="doctor" class="form-input">
          <option :value="null">Todos los Doctores</option>
          <option v-for="doc in doctores" :key="doc.cod_doctor" :value="doc.cod_doctor">
            {{ doc.nombre_doctor }}
          </option>
        </select>
      </div>
      <div class="filter-actions">
        <button @click="aplicarFiltros" class="btn btn-primary">🔍 Filtrar</button>
        <button @click="limpiarFiltros" class="btn btn-secondary">✨ Limpiar</button>
      </div>
    </div>

    <div v-if="!cargando && resultadosBusqueda.length > 0" class="results-container">
      <div class="summary-section">
        <h3>Resumen por Doctor</h3>
        <p><strong>Total de prescripciones encontradas:</strong> {{ totalResultados }}</p>
        <ul class="summary-list">
          <li v-for="(count, doctor) in resumenPorDoctor" :key="doctor">
            <strong>{{ doctor }}:</strong> {{ count }} prescripci(ón/ones)
          </li>
        </ul>
      </div>

      <div class="table-container">
        <h3>Detalle de Prescripciones</h3>
        <table class="results-table">
          <thead>
            <tr>
              <th>Cód. Receta</th>
              <th>Cliente</th>
              <th>Doctor</th>
              <th>Fecha Prescripción</th>
              <th>Fecha Entrega</th>
              <th>Proveedor</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="prescripcion in resultadosBusqueda" :key="prescripcion.cod_prescripcion">
              <td>{{ prescripcion.cod_receta }}</td>
              <td>{{ prescripcion.clientes.nombre_cliente }} {{ prescripcion.clientes.apellido_paterno_cliente }}</td>
              <td>{{ prescripcion.doctores.nombre_doctor }}</td>
              <td>{{ prescripcion.fecha_prescripcion }}</td>
              <td>{{ prescripcion.fecha_entrega }}</td>
              <td>{{ prescripcion.proveedores ? prescripcion.proveedores.nombre_proveedor : 'N/A' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    
    <div v-else-if="cargando" class="loading-message">
      <p>Cargando datos...</p>
    </div>

    <div v-else-if="busquedaRealizada && resultadosBusqueda.length === 0" class="no-results-message">
      <p>😕 No se encontraron resultados para los filtros seleccionados.</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { supabase } from '../lib/supabaseClient';

const cargando = ref(false);
const busquedaRealizada = ref(false);
const doctores = ref([]);
const resultadosBusqueda = ref([]);

const filtros = ref({
  fechaInicio: '',
  fechaFin: '',
  doctor: null,
});

// Carga los doctores al montar el componente
onMounted(async () => {
  const { data } = await supabase.from('doctores').select('*').order('nombre_doctor');
  if (data) {
    doctores.value = data;
  }
});

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
        proveedores (nombre_proveedor)
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

    const { data, error } = await query.order('fecha_entrega', { ascending: false });

    if (error) throw error;
    
    resultadosBusqueda.value = data;
  } catch (error) {
    console.error("Error al buscar prescripciones:", error);
    alert('No se pudieron obtener los datos: ' + error.message);
  } finally {
    cargando.value = false;
  }
};

const limpiarFiltros = () => {
  filtros.value = { fechaInicio: '', fechaFin: '', doctor: null };
  resultadosBusqueda.value = [];
  busquedaRealizada.value = false;
};

const totalResultados = computed(() => resultadosBusqueda.value.length);

const resumenPorDoctor = computed(() => {
  if (!resultadosBusqueda.value.length) return {};
  
  return resultadosBusqueda.value.reduce((acc, prescripcion) => {
    const doctorName = prescripcion.doctores?.nombre_doctor || 'Desconocido';
    acc[doctorName] = (acc[doctorName] || 0) + 1;
    return acc;
  }, {});
});

</script>

<style scoped>
.report-container {
  padding: 1rem 2rem;
  max-width: 1400px;
  margin: 0 auto;
}
.report-header {
  text-align: center;
  margin-bottom: 2rem;
}
.report-header h1 {
  font-size: 2.2rem;
}
.filters-card {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  background-color: #f8f9fa;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
  align-items: flex-end;
}
.form-group {
  display: flex;
  flex-direction: column;
}
.form-group label {
  margin-bottom: 0.5rem;
  font-weight: 600;
  font-size: .9rem;
}
.form-input {
  padding: 0.5rem;
  border: 1px solid #ced4da;
  border-radius: 4px;
  width: 100%;
}
.filter-actions {
  display: flex;
  gap: 0.5rem;
  align-items: flex-end;
}
.btn {
  padding: 0.6rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 600;
  color: white;
}
.btn-primary { background-color: #007bff; }
.btn-primary:hover { background-color: #0056b3; }
.btn-secondary { background-color: #6c757d; }
.btn-secondary:hover { background-color: #5a6268; }

.results-container {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 2rem;
  align-items: flex-start;
}
.summary-section {
  background-color: #fff;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  position: sticky;
  top: 20px;
}
.summary-list {
  list-style-type: none;
  padding: 0;
  margin-top: 1rem;
}
.summary-list li {
  padding: 0.5rem;
  border-bottom: 1px solid #eee;
}
.table-container {
  overflow-x: auto;
}
.results-table {
  width: 100%;
  border-collapse: collapse;
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}
.results-table th, .results-table td {
  padding: 0.8rem 1rem;
  border: 1px solid #dee2e6;
  text-align: left;
}
.results-table th {
  background-color: #e9ecef;
  font-weight: 600;
}
.loading-message, .no-results-message {
  text-align: center;
  padding: 2rem;
  background-color: #f8f9fa;
  border-radius: 8px;
  font-size: 1.2rem;
  color: #6c757d;
}
</style>