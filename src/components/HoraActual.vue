<template>
  <div class="time-banner">
    <div v-if="user" class="user-info-banner">
      <span class="user-name">👤 {{ user.nombre_usuario }}</span>      
      <span v-if="loading" class="store-name loading-state">Cargando tienda...</span>
      <span v-else class="store-name">🏪 Tienda: {{ nombreTienda }}</span>
    </div>

    <p>{{ currentDate }},  {{ currentTime }}</p>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  user: {
    type: Object,
    default: null
  },
  nombreTienda: {
    type: String,
    default: 'No asignada'
  },
  loading: {
    type: Boolean,
    default: false
  }
});

const currentTime = ref('');
const currentDate = ref(''); 
let timer = null;

// Función para actualizar la hora y la fecha
const updateTime = () => {
  const now = new Date();
  
  // Esto convierte la hora a formato 12 horas con indicador AM/PM.
  currentTime.value = now.toLocaleTimeString('es-ES', { hour12: true }); 
  
  currentDate.value = now.toLocaleDateString('es-ES', { 
    weekday: 'long', // Nombre completo del día de la semana (e.g., 'viernes')
    year: 'numeric', // Año completo (e.g., '2025')
    month: 'long',   // Nombre completo del mes (e.g., 'octubre')
    day: 'numeric'   // Número del día (e.g., '3')
  });

  // Capitalizar el Dia a menudo devuelve el día de la semana en minúsculas.
  currentDate.value = currentDate.value.charAt(0).toUpperCase() + currentDate.value.slice(1);
};

// Hooks del ciclo de vida para iniciar y detener el temporizador
onMounted(() => {
  updateTime();
  timer = setInterval(updateTime, 1000);
});

onUnmounted(() => {
  clearInterval(timer);
});
</script>

<style scoped>
.time-banner {
  width: 100%;
  background-color: rgba(0, 109, 136, 0.7); 
  color: white;
  text-align: right;
  padding: 2px 20px;
  position: sticky;
  top: 50px;
  z-index: 1000;
  font-family: sans-serif;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.time-banner p {
  margin: 0;
  font-size: 1rem;
  letter-spacing: 0.5px; 
}

.user-info-banner {
  display: flex;
  align-items: center;
  gap: 1rem;
  font-size: 0.8rem;
  background-color: rgba(255, 255, 255, 0.171);
  padding: 5px 15px;
  border-radius: 20px;
}

.user-name {
  font-weight: 500;
}

.store-name {
  opacity: 0.8;
}

.loading-state {
  opacity: 0.6;
  font-style: italic;
}
</style>