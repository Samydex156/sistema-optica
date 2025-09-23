<template>
  <div class="time-banner">
    <div v-if="user" class="user-info-banner">
      <span class="user-name">👤 {{ user.nombre_usuario }}</span>
      
      <span v-if="loading" class="store-name loading-state">Cargando tienda...</span>
      <span v-else class="store-name">🏪 Tienda: {{ nombreTienda }}</span>
    </div>

    <p>{{ currentTime }}</p>
  </div>
</template>

<script setup>
// 1. CORRECCIÓN: Se elimina 'defineProps' de los imports
import { ref, onMounted, onUnmounted } from 'vue';

// Se definen las props que el componente espera recibir
// 'defineProps' es un macro y no necesita ser importado
const props = defineProps({
  user: {
    type: Object,
    default: null
  },
  nombreTienda: {
    type: String,
    default: 'No asignada'
  },
  // 2. MEJORA: Prop para gestionar el estado de carga desde el padre
  loading: {
    type: Boolean,
    default: false
  }
});

const currentTime = ref('');
let timer = null;

// Función para actualizar la hora
const updateTime = () => {
  const now = new Date();
  // Formato de hora localizado para mejor presentación
  currentTime.value = now.toLocaleTimeString('es-ES'); 
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
  /* 3. MEJORA VISUAL: Color más integrado con la barra de navegación */
  background-color: rgba(0, 0, 0, .7); 
  color: white;
  text-align: right;
  padding: 10px 20px;
  z-index: 1000;
  font-family: sans-serif;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.time-banner p {
  margin: 0;
  font-size: 1.2rem;
  font-weight: 600;
}

.user-info-banner {
  display: flex;
  align-items: center;
  gap: 1rem;
  font-size: 0.9rem;
  background-color: rgba(255, 255, 255, 0.1);
  padding: 5px 15px;
  border-radius: 20px;
}

.user-name {
  font-weight: 500;
}

.store-name {
  opacity: 0.8;
}

/* Estilo para el estado de carga, da feedback visual al usuario */
.loading-state {
  opacity: 0.6;
  font-style: italic;
}
</style>