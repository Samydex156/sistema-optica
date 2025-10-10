<template>
  <v-app>
    <div id="app">
      <!-- 1. Renderizado condicional basado en la autenticación -->
      <template v-if="isAuthenticated">
        <NavbarPrincipal @open-calculator-modal="showModal = true" @logout="handleLogout" />

        <v-main>
          <main class="main-content">
            <router-view />
          </main>
        </v-main>
        
        <!-- Este modal debería ser migrado a v-dialog también si es posible -->
        <CalculatorModal v-if="showModal" @close="showModal = false" />
      </template>

      <!-- 2. Si no está autenticado, solo se muestra la vista del router (página de login) -->
      <template v-else>
         <router-view />
      </template>
    </div>
    <CronometroFlotante />
  </v-app>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import NavbarPrincipal from './components/NavbarPrincipal.vue';
import CalculatorModal from './components/CalculatorModal.vue';
import { useAuth } from './composables/useAuth';
import CronometroFlotante from './components/CronometroFlotante.vue';

// Estado para el modal de la calculadora
const showModal = ref(false);

const { isAuthenticated, logout } = useAuth();
const router = useRouter();

const handleLogout = () => {
  logout();
  router.push('/login');
};
</script>

<style>
/* Tus estilos globales se mantienen igual */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background-color: #f9fafb;
}

#app {
  min-height: 100vh;
}

.main-content {
  padding: 1rem;
  margin: 0 auto;
  width: 100%;
}
</style>
