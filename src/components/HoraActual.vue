<template>
  <v-toolbar density="compact" color="blue-darken-4">

    <div class="d-flex align-center ga-2 ml-4">
      <v-chip
        v-if="user"
        prepend-icon="mdi-account"
        variant="flat"
        color="blue-darken-2"
        size="small"
      >
        {{ user.nombre_usuario }}
      </v-chip>
      
      <v-chip
        prepend-icon="mdi-store"
        variant="flat"
        color="blue-darken-2"
        size="small"
        :loading="loading"
      >
        Tienda: {{ nombreTienda }}
      </v-chip>
    </div>
    
    <v-spacer></v-spacer>

    <div class="text-caption mr-4">
      <span>{{ currentDate }}, {{ currentTime }}</span>
    </div>

  </v-toolbar>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

// Tu script setup (lógica) es perfecto y no necesita cambios.
// Se mantiene 100% igual.
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

const updateTime = () => {
  const now = new Date();
  
  currentTime.value = now.toLocaleTimeString('es-ES', { hour12: true }); 
  
  currentDate.value = now.toLocaleDateString('es-ES', { 
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });

  currentDate.value = currentDate.value.charAt(0).toUpperCase() + currentDate.value.slice(1);
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
/* ¡No se necesita CSS!
  Vuetify maneja todo el layout y el estilo a través
  de los componentes (v-toolbar, v-chip) y clases (text-caption).
  Esto es mucho más mantenible.
*/
</style>