<template>
  <v-app>
    <v-layout>
      <template v-if="isAuthenticated">
        <NavbarPrincipal 
          @open-calculator-modal="showCalculatorDialog = true" 
          @logout="handleLogout" 
        />

        <v-main>
          <v-container fluid class="pa-4">
            <router-view />
          </v-container>
        </v-main>
        
        <CalculatorDialog v-model="showCalculatorDialog" />

      </template>

      <template v-else>
         <router-view />
      </template>
      
      <CronometroFlotante />
    </v-layout>
  </v-app>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import NavbarPrincipal from './components/NavbarPrincipal.vue';
// Renombrado de CalculatorModal a CalculatorDialog para claridad
import CalculatorDialog from './components/CalculatorDialog.vue'; 
import { useAuth } from './composables/useAuth';
import CronometroFlotante from './components/CronometroFlotante.vue';

// Estado para el modal de la calculadora, ahora llamado 'showCalculatorDialog'
const showCalculatorDialog = ref(false);

const { isAuthenticated, logout } = useAuth();
const router = useRouter();

const handleLogout = () => {
  logout();
  router.push('/login');
};
</script>

<style scoped>
/* Opcional: Asegura que v-main tenga un fondo de color 
  consistente con el tema de Vuetify.
*/
.v-main {
  background-color: rgb(var(--v-theme-background));
}
</style>