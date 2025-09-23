<template>
  <nav class="navbar" :class="{ 'mobile-menu-open': isMobileMenuOpen }">
    <div class="navbar-header">
      <router-link to="/panel" class="navbar-brand">
        <h1>Óptica Optalvis</h1>
      </router-link>

      <button @click="toggleMobileMenu" class="hamburger-button">
        <div class="hamburger-line"></div>
        <div class="hamburger-line"></div>
        <div class="hamburger-line"></div>
      </button>
    </div>

    <div class="navbar-menu" :class="{ 'is-open': isMobileMenuOpen }">
      <router-link to="/landing" class="nav-link" @click="closeMobileMenu">Inicio</router-link>
      <router-link to="/clientes" class="nav-link" @click="closeMobileMenu">Clientes</router-link>
      <router-link to="/ordenes" class="nav-link" @click="closeMobileMenu">Órdenes</router-link>
      <router-link to="/productos/registrar" class="nav-link" @click="closeMobileMenu">Productos</router-link>
      <div class="navbar-spacer"></div>
      <button @click="openCalculator" class="nav-link-button">
        Calculadora
      </button>

      <button @click="logout" class="nav-link-button logout-button">
        Cerrar Sesión
      </button>
    </div>
  </nav>
  
  <HoraActual 
    :user="user" 
    :nombreTienda="nombreTienda" 
    :loading="isTiendaLoading" 
  />
</template>

<script setup>
import { ref, watch } from 'vue';
import { RouterLink } from 'vue-router';
import { useAuth } from '../composables/useAuth';
import { supabase } from '../lib/supabaseClient';
import HoraActual from './HoraActual.vue';

const emit = defineEmits(['open-calculator-modal', 'logout']);

const { user } = useAuth();
const nombreTienda = ref('No asignada');
const isTiendaLoading = ref(false);

// 3. ESTADO PARA EL MENÚ: Controla si el menú móvil está abierto o cerrado.
const isMobileMenuOpen = ref(false);

// Función para alternar la visibilidad del menú móvil
const toggleMobileMenu = () => {
  isMobileMenuOpen.value = !isMobileMenuOpen.value;
};

// Función para cerrar el menú (útil al hacer clic en un enlace)
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
.navbar {
  width: 100%;
  background-color: #1d5cb9;
  padding: 0 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 60px;
  color: white;
  position: relative; /* Necesario para posicionar el menú desplegable */
  z-index: 1010; /* Asegura que la barra de navegación esté por encima de otros elementos */
}
.navbar-brand {
  text-decoration: none;
  color: white;
}
.navbar-brand h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
}
.navbar-menu {
  display: flex;
  align-items: center;
  height: 100%;
}
.nav-link {
  color: white;
  text-decoration: none;
  padding: 0 20px;
  display: flex;
  align-items: center;
  height: 60px;
  transition: background-color 0.3s;
}
.nav-link:hover {
  background-color: rgba(255, 255, 255, 0.1);
}
.nav-link.router-link-active {
  background-color: rgba(255, 255, 255, 0.2);
  font-weight: 600;
}
.navbar-spacer {
  flex-grow: 1;
}
.nav-link-button {
  color: white;
  text-decoration: none;
  padding: 0 20px;
  height: 60px;
  display: flex;
  align-items: center;
  border: none;
  background: none;
  cursor: pointer;
  font-size: 1rem;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  transition: background-color 0.3s;
}
.nav-link-button:hover {
  background-color: rgba(255, 255, 255, 0.1);
}
.logout-button {
  background-color: rgba(0, 0, 0, 0.15);
}
.logout-button:hover {
  background-color: rgba(0, 0, 0, 0.3);
}

/* 4. ESTILOS PARA EL MENÚ HAMBURGUESA */
.navbar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.hamburger-button {
  display: none; /* Oculto por defecto en pantallas grandes */
  flex-direction: column;
  justify-content: space-around;
  width: 30px;
  height: 25px;
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 0;
  z-index: 10;
}

.hamburger-line {
  width: 30px;
  height: 3px;
  background-color: white;
  border-radius: 5px;
}


/* 5. ESTILOS RESPONSIVE */
@media (max-width: 750px) {
  .navbar {
    flex-direction: column;
    /* Evita que el navbar se estire al abrir el menú */
    align-items: flex-start;
  }
  
  /* Cuando el menú móvil está abierto, la barra principal se mantiene roja */
  .navbar.mobile-menu-open {
    padding-bottom: 10px;
  }

  .navbar-header {
    /* Asegura que el título y el botón ocupen todo el ancho */
    width: 100%;
    min-height: 60px;
  }

  .hamburger-button {
    display: flex; /* Se muestra el botón en móviles */
  }

  .navbar-menu {
    display: none; /* Oculta el menú por defecto en móviles */
    flex-direction: column;
    width: 100%;
    height: auto;
    background-color: #1d5cb9;
  }

  /* Esta clase muestra el menú cuando isMobileMenuOpen es true */
  .navbar-menu.is-open {
    display: flex;
  }

  .navbar-spacer {
    display: none; /* No necesitamos el espaciador en vista de columna */
  }

  .nav-link, .nav-link-button {
    height: 50px;
    width: 100%;
    justify-content: center;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
  }
}
</style>