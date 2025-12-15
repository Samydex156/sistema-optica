<template>
  <v-app class="app-container">
    <div class="background-pattern"></div>

    <NavbarPrincipal v-if="isAuthenticated" @logout="handleLogout" />

    <v-main>
      <v-container fluid class="pa-4">
        <router-view v-slot="{ Component }">
          <transition name="fade-slide" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup>
import { useRouter } from 'vue-router';
import NavbarPrincipal from './components/NavbarPrincipal.vue';
import { useAuth } from './composables/useAuth';

const { isAuthenticated, logout } = useAuth();
const router = useRouter();

const handleLogout = () => {
  logout();
  router.push('/login');
};
</script>

<style>
/* Reset global overflow overrides to allow standard Vuetify scrolling */
html,
body {
  overflow-y: auto !important;
}
</style>

<style scoped>
.app-container {
  background-color: rgb(var(--v-theme-background));
  min-height: 100vh;
}

.background-pattern {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: radial-gradient(circle at 10% 20%, rgba(21, 101, 192, 0.05) 0%, transparent 20%),
    radial-gradient(circle at 90% 80%, rgba(21, 101, 192, 0.05) 0%, transparent 20%);
  pointer-events: none;
  z-index: 0;
}

:deep(.v-main) {
  padding-top: 80px !important;
  transition: padding 0.2s ease;
}

/* Adjust for mobile if needed */
@media (max-width: 600px) {
  :deep(.v-main) {
    padding-top: 110px !important;
  }
}

/* Page Transitions */
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-slide-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}
</style>