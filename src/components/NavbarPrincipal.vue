<template>
  <nav class="navbar">
    <router-link to="/panel" class="navbar-brand">
      <h1>Óptica Optalvis</h1>
    </router-link>

    <div class="navbar-menu">
      <!-- Nuevo enlace a la Landing Page -->
      <router-link to="/landing" class="nav-link">Inicio</router-link>
      <router-link to="/clientes" class="nav-link">Clientes</router-link>
      <router-link to="/ordenes" class="nav-link">Órdenes</router-link>
      <router-link to="/productos/registrar" class="nav-link">Productos</router-link>
      <div class="navbar-spacer"></div>
      <button @click="$emit('open-calculator-modal')" class="nav-link-button">
        Calculadora
      </button>

      <button @click="$emit('logout')" class="nav-link-button logout-button">
        Cerrar Sesión
      </button>
    </div>
  </nav>
  <HoraActual :user="user" :nombreTienda="nombreTienda" />
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { RouterLink } from 'vue-router';
import { useAuth } from '../composables/useAuth'; // Importamos el composable de autenticación
import { supabase } from '../lib/supabaseClient'; // Importamos supabase
import HoraActual from './HoraActual.vue';

// Se declaran los eventos que el componente puede emitir
defineEmits(['open-calculator-modal', 'logout']);

// 3. Obtenemos el usuario reactivo del composable
const { user } = useAuth();
const nombreTienda = ref('No asignada');

/**
 * Obtiene el nombre de la tienda asignada al usuario.
 */
const getNombreTienda = async () => {
  if (user.value && user.value.tienda_usuario) {
    try {
      const { data, error } = await supabase
        .from('tiendas')
        .select('nombre_tienda')
        .eq('cod_tienda', user.value.tienda_usuario)
        .single(); // .single() para obtener un solo registro

      if (error) throw error;

      if (data) {
        nombreTienda.value = data.nombre_tienda;
      }
    } catch (error) {
      console.error('Error al obtener el nombre de la tienda:', error.message);
      nombreTienda.value = 'Error';
    }
  }
};

// 4. Observamos cambios en el usuario (por si la carga es asíncrona) y llamamos a la función
watch(user, getNombreTienda, { immediate: true });

</script>

<style scoped>
.navbar {
  width: 100%;
  background-color: #eb2525;
  padding: 0 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 60px;
  color: white;
}

/* Estilo para que la marca se comporte como un enlace limpio */
.navbar-brand {
  text-decoration: none;
  color: white;
  display: flex;
  align-items: center;
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

/* Espaciador para empujar los elementos de la derecha */
.navbar-spacer {
  flex-grow: 1;
}

/* Estilos unificados para botones */
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


/* Responsive */
@media (max-width: 992px) {
  .navbar {
    flex-direction: column;
    padding: 10px 20px;
  }

  .navbar-menu {
    flex-direction: column;
    width: 100%;
    height: auto;
  }
  
  .user-info {
    margin: 10px 0;
  }

  .nav-link, .nav-link-button {
    height: 50px;
    width: 100%;
    justify-content: center;
  }
}
</style>
