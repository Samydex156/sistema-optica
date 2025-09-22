<template>
  <div class="time-banner">
    <div v-if="user" class="user-info-banner">
      <span class="user-name">👤 {{ user.nombre_usuario }}</span>
      <span class="store-name">🏪 Tienda: {{ nombreTienda }}</span>
    </div>
    <p>{{ currentTime }}</p>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, defineProps } from 'vue';

// Definimos las props que este componente espera recibir
const props = defineProps({
  user: {
    type: Object,
    default: null
  },
  nombreTienda: {
    type: String,
    default: 'No asignada'
  }
});

const currentTime = ref('');
let timer = null;

const updateTime = () => {
  const now = new Date();
  currentTime.value = now.toLocaleTimeString();
};

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
  background-color: #333;
  color: white;
  text-align: right;
  padding: 10px 20px; /* Ajustado el padding */
  z-index: 1000;
  font-family: sans-serif;
  display: flex; /* Usamos flexbox para alinear elementos */
  justify-content: space-between; /* Alinea los elementos a los extremos */
  align-items: center;
}

.time-banner p {
  margin: 0;
  font-size: 1.2rem;
  font-weight: 600;
}

/* Estilos para la info del usuario en el banner de la hora */
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
</style>