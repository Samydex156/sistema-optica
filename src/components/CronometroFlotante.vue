<template>
  <div>
    <v-btn
      :color="isRunning ? 'red-darken-1' : 'primary'"
      fab
      dark
      size="large"
      class="floating-stopwatch"
      @click="toggle"
      @contextmenu.prevent="openResetMenu"
    >
      <v-icon v-if="!isRunning && displayTime === '00:00'">mdi-timer-outline</v-icon>
      <span v-else class="timer-text">{{ displayTime }}</span>
    </v-btn>

    <v-menu
      v-model="showMenu"
      :style="{ top: `${menuY}px`, left: `${menuX}px` }"
      absolute
      location="top"
    >
      <v-list density="compact">
        <v-list-item @click="resetTimer" prepend-icon="mdi-restart">
          <v-list-item-title>Reiniciar Cronómetro</v-list-item-title>
        </v-list-item>
      </v-list>
    </v-menu>
  </div>
</template>

<script setup>
import { ref } from 'vue';
// Importamos nuestro gestor de estado
import { useCronometro } from '../composables/useCronometro.js';

const { isRunning, displayTime, toggle, reset } = useCronometro();

// Lógica para el menú contextual de reinicio
const showMenu = ref(false);
const menuX = ref(0);
const menuY = ref(0);

function openResetMenu(e) {
  e.preventDefault();
  showMenu.value = false; // Cierra cualquier menú previo
  menuX.value = e.clientX;
  menuY.value = e.clientY;
  // Pequeño truco para asegurar que el menú se renderice correctamente
  setTimeout(() => { showMenu.value = true; }, 50);
}

function resetTimer() {
  reset();
  showMenu.value = false;
}
</script>

<style scoped>
.floating-stopwatch {
  position: fixed !important;
  bottom: 24px;
  right: 24px;
  z-index: 999;
}

.timer-text {
  font-size: 1.2rem;
  font-weight: 500;
  letter-spacing: 0.5px;
}
</style>