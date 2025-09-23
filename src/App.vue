<template>
  <div id="app">
    <!-- 1. Renderizado condicional basado en la autenticación -->
    <template v-if="isAuthenticated">
      <NavbarPrincipal @open-calculator-modal="showModal = true" @logout="handleLogout" />

      <main class="main-content">
        <router-view />
      </main>
      
      <CalculatorModal v-if="showModal" @close="showModal = false" />
    </template>

    <!-- 2. Si no está autenticado, solo se muestra la vista del router (página de login) -->
    <template v-else>
       <router-view />
    </template>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import NavbarPrincipal from './components/NavbarPrincipal.vue';
import CalculatorModal from './components/CalculatorModal.vue';
import { useAuth } from './composables/useAuth'; // 3. Importar el composable

// Estado para el modal de la calculadora
const showModal = ref(false);

// 4. Usar el composable para obtener el estado y las funciones de autenticación
const { isAuthenticated, logout } = useAuth();
const router = useRouter();

// 5. Función para manejar el cierre de sesión
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
  padding: 10px;
  max-width: 1300px;
  margin: 10px 10px;
  width: 100%;
}
</style>
