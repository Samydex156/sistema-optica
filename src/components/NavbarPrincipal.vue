<template>
  <nav class="navbar">
    <div class="navbar-brand">
      <h1>Sistema Óptica Optalvis</h1>
    </div>

    <div class="navbar-menu">
      <router-link to="/clientes" class="nav-link">
        Clientes
      </router-link>

      <router-link to="/ordenes" class="nav-link">
        Órdenes
      </router-link>

      <router-link to="/prescripciones/registrar" class="nav-link">
        Prescripciones
      </router-link>

      <router-link to="/movimientos/registrar" class="nav-link">
        Movimientos
      </router-link>

      <router-link to="/productos/registrar" class="nav-link">
        Productos
      </router-link>

      <router-link to="/productos/caracteristicas" class="nav-link">
        Componentes Producto
      </router-link>

      <router-link to="/practicas" class="nav-link">
        Prácticas
      </router-link>

      <button @click="$emit('open-calculator-modal')" class="nav-link">
        Calculadora
      </button>

      <button @click="$emit('logout')" class="nav-link">
        Cerrar Sesión
      </button>
    </div>
  </nav>
  <HoraActual />
</template>

<script setup>
import { RouterLink } from 'vue-router';
import HoraActual from './HoraActual.vue';

// Se declara el nuevo evento 'logout' para que el componente padre pueda escucharlo
defineEmits(['open-calculator-modal', 'logout']);
</script>

<style scoped>
/* Los estilos existentes se mantienen igual */
.navbar {
  width: 100%;
  background-color: #eb2525;
  padding: 0;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 60px;
}

.navbar-brand {
  padding: 0 20px;
}

.navbar-brand h1 {
  color: white;
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
}

.navbar-menu {
  display: flex;
  align-items: center;
  height: 60px;
}

.nav-link {
  color: white;
  text-decoration: none;
  padding: 20px 20px;
  display: block;
  transition: background-color 0.3s;
  height: 60px;
  display: flex;
  align-items: center;
  border: none;
  background: none;
  cursor: pointer;
  font-size: 1rem;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.nav-link:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

.nav-link.router-link-active {
  background-color: rgba(255, 255, 255, 0.2);
  font-weight: 600;
}


/* Responsive */
@media (max-width: 768px) {
  .navbar {
    flex-direction: column;
    min-height: auto;
  }

  .navbar-menu {
    width: 100%;
    height: auto;
    flex-wrap: wrap;
  }

  .nav-link {
    height: 50px;
    padding: 15px 20px;
  }
}
</style>