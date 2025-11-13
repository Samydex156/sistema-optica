<template>
  <v-app-bar color="blue-darken-3" elevation="2" density="compact">
    
    <v-app-bar-nav-icon 
      class="d-md-none" 
      @click.stop="isMobileMenuOpen = !isMobileMenuOpen"
    ></v-app-bar-nav-icon>

    <v-app-bar-title>
      <v-btn to="/panel" variant="text" class="text-none text-h6">
        Óptica Optalvis
      </v-btn>
    </v-app-bar-title>

    <div class="d-none d-md-flex">
      <v-btn to="/landing">Inicio</v-btn>
      <v-btn to="/clientes">Clientes</v-btn>
      <v-btn to="/ordenes">Órdenes</v-btn>
      <v-btn to="/productos/registrar">Productos</v-btn>
      
      <v-spacer></v-spacer>
      
      <v-btn prepend-icon="mdi-calculator" @click="openCalculator">
        Calculadora
      </v-btn>

      <v-btn prepend-icon="mdi-logout" @click="logout">
        Cerrar Sesión
      </v-btn>
    </div>

    <template #extension>
      <HoraActual 
        :user="user" 
        :nombre-tienda="nombreTienda" 
        :loading="isTiendaLoading" 
      />
    </template>

  </v-app-bar>

  <v-navigation-drawer
    v-model="isMobileMenuOpen"
    location="left"
    temporary
  >
    <v-list nav density="compact">
      <v-list-item prepend-icon="mdi-view-dashboard" title="Panel" to="/panel" @click="closeMobileMenu"></v-list-item>
      <v-list-item prepend-icon="mdi-home" title="Inicio" to="/landing" @click="closeMobileMenu"></v-list-item>
      <v-list-item prepend-icon="mdi-account-group" title="Clientes" to="/clientes" @click="closeMobileMenu"></v-list-item>
      <v-list-item prepend-icon="mdi-file-document" title="Órdenes" to="/ordenes" @click="closeMobileMenu"></v-list-item>
      <v-list-item prepend-icon="mdi-package-variant" title="Productos" to="/productos/registrar" @click="closeMobileMenu"></v-list-item>
      
      <v-divider></v-divider>
      
      <v-list-item prepend-icon="mdi-calculator" title="Calculadora" @click="openCalculator"></v-list-item>
      <v-list-item prepend-icon="mdi-logout" title="Cerrar Sesión" @click="logout"></v-list-item>
    </v-list>
  </v-navigation-drawer>
</template>

<script setup>
import { ref, watch } from 'vue';
import { useAuth } from '../composables/useAuth';
import { supabase } from '../lib/supabaseClient';
import HoraActual from './HoraActual.vue';

const emit = defineEmits(['open-calculator-modal', 'logout']);

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
const openCalculator = () => {
  emit('open-calculator-modal');
  closeMobileMenu();
};

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
</script>

<style scoped>

:deep(.v-toolbar__extension) {
  width: 100%;
  padding: 0; /* Opcional, si HoraActual ya tiene su padding */
}

/* Opcional: Si el título (Óptica Optalvis) debe verse como un
  cursor 'pointer' para indicar que es un enlace.
*/
.v-app-bar-title .v-btn {
  cursor: pointer;
}
</style>