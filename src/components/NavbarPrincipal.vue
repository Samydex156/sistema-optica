<template>
  <v-app-bar color="transparent" elevation="0" class="glass-nav border-b" density="comfortable" floating>
    <v-app-bar-nav-icon class="d-md-none text-white" variant="text"
      @click.stop="isMobileMenuOpen = !isMobileMenuOpen"></v-app-bar-nav-icon>

    <v-app-bar-title class="ml-2">
      <v-btn to="/panel" variant="text" class="text-none text-h6 font-weight-bold text-white px-2"
        prepend-icon="mdi-glasses">
        <span class="tracking-wide">Óptica Optalvis</span>
      </v-btn>
    </v-app-bar-title>

    <div class="d-none d-md-flex align-center ga-2 mr-4">
      <!-- Navigation items -->
      <v-btn to="/clientes" variant="text" class="text-caption font-weight-medium text-white nav-btn" rounded="lg">
        Clientes
      </v-btn>
      <v-btn to="/ordenes" variant="text" class="text-caption font-weight-medium text-white nav-btn" rounded="lg">
        Órdenes
      </v-btn>
      <v-btn to="/productos/registrar" variant="text" class="text-caption font-weight-medium text-white nav-btn"
        rounded="lg">
        Productos
      </v-btn>

      <v-divider vertical class="mx-2 border-opacity-25" style="height: 20px; color: white"></v-divider>

      <!-- Info Items -->
      <div v-if="user" class="d-flex align-center text-white px-2 py-1 rounded-pill glass-chip" title="Usuario">
        <v-icon icon="mdi-account" size="small" class="mr-1 text-blue-lighten-3"></v-icon>
        <span class="text-caption font-weight-bold">{{ user.nombre_usuario }}</span>
      </div>

      <div class="d-flex align-center text-white px-2 py-1 rounded-pill glass-chip" title="Tienda">
        <v-progress-circular v-if="isTiendaLoading" indeterminate size="10" width="1" color="white"
          class="mr-1"></v-progress-circular>
        <v-icon v-else icon="mdi-store" size="small" class="mr-1 text-blue-lighten-3"></v-icon>
        <span class="text-caption">{{ nombreTienda }}</span>
      </div>

      <div class="d-flex align-center glass-chip px-2 py-1 rounded-pill" title="Fecha">
        <span class="text-blue-lighten-4 font-weight-medium text-caption mr-1">{{ currentDate }}</span>
        <span class="text-white font-weight-bold font-mono text-caption">{{ currentTime }}</span>
      </div>

      <v-divider vertical class="mx-2 border-opacity-25" style="height: 20px; color: white"></v-divider>

      <v-btn icon="mdi-logout" variant="text" color="red-lighten-4" density="compact" class="nav-btn" @click="logout"
        title="Cerrar Sesión"></v-btn>
    </div>
  </v-app-bar>

  <v-navigation-drawer v-model="isMobileMenuOpen" location="left" temporary>
    <v-list nav density="compact">
      <v-list-item prepend-icon="mdi-view-dashboard" title="Panel" to="/panel" @click="closeMobileMenu"></v-list-item>

      <v-list-item prepend-icon="mdi-account-group" title="Clientes" to="/clientes"
        @click="closeMobileMenu"></v-list-item>
      <v-list-item prepend-icon="mdi-file-document" title="Órdenes" to="/ordenes"
        @click="closeMobileMenu"></v-list-item>
      <v-list-item prepend-icon="mdi-package-variant" title="Productos" to="/productos/registrar"
        @click="closeMobileMenu"></v-list-item>

      <v-divider></v-divider>

      <v-list-item prepend-icon="mdi-logout" title="Cerrar Sesión" @click="logout"></v-list-item>
    </v-list>
  </v-navigation-drawer>

</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue';
import { useAuth } from '../composables/useAuth';
import { supabase } from '../lib/supabaseClient';

const emit = defineEmits(['logout']);
const { user } = useAuth();
const nombreTienda = ref('No asignada');
const isTiendaLoading = ref(false);

// Este 'ref' ahora controla el v-navigation-drawer
const isMobileMenuOpen = ref(false);

// Función para cerrar el menú (¡sigue siendo necesaria!)
const closeMobileMenu = () => {
  isMobileMenuOpen.value = false;
};

// Envolvemos los emits en funciones para poder cerrar el menú también
const logout = () => {
  emit('logout');
  closeMobileMenu();
};

const getNombreTienda = async () => {
  if (user.value && user.value.tienda_usuario) {
    isTiendaLoading.value = true;
    try {
      const { data, error } = await supabase
        .from('tiendas')
        .select('nombre_tienda')
        .eq('cod_tienda', user.value.tienda_usuario)
        .single();

      if (error) throw error;
      if (data) {
        nombreTienda.value = data.nombre_tienda;
      }
    } catch (error) {
      console.error('Error al obtener el nombre de la tienda:', error.message);
      nombreTienda.value = 'No asignada';
    } finally {
      isTiendaLoading.value = false;
    }
  } else {
    nombreTienda.value = 'No asignada';
  }
};

watch(user, getNombreTienda, { immediate: true });

// Lógica de tiempo integrada directamente (anteriormente en HoraActual.vue)
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
.glass-nav {
  background: linear-gradient(135deg, #1565C0 0%, #0D47A1 100%) !important;
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
  position: fixed !important;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
}

.glass-extension {
  background: transparent;
  backdrop-filter: blur(5px);
}

.tracking-wide {
  letter-spacing: 0.5px;
}

.nav-btn {
  transition: all 0.2s ease;
  text-transform: none !important;
  letter-spacing: 0.3px;
}

.nav-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateY(-1px);
}

:deep(.v-toolbar__extension) {
  padding: 0;
  height: auto !important;
}

.font-mono {
  font-family: 'Roboto Mono', monospace;
  letter-spacing: 1px;
}

.glass-chip {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.1);
  transition: all 0.2s ease;
}

.glass-chip:hover {
  background: rgba(255, 255, 255, 0.15);
  border-color: rgba(255, 255, 255, 0.2);
}
</style>
