<template>
  <div class="dashboard-container">
    <header class="dashboard-header">
      <h1>Panel Principal</h1>
      <p>Seleccione un módulo para iniciar operaciones.</p>
    </header>
    <div class="modules-grid">
      <!-- Tarjeta para Inventarios -->
      <div class="module-card" @click="navegarA('/productos/registrar')">
        <div class="icon-container">
          📦
        </div>
        <h2>Productos</h2>
        <p>Creación de nuevos productos.</p>
      </div>
      <!--TARJETA PARA INVENTARIO-->
      <div class="module-card" @click="navegarA('/inventario')">
        <div class="icon-container">
          📊
        </div>
        <h2>Inventario</h2>
        <p>Gestión de entradas, salidas o traspasos.</p>
      </div>
      <!--TARJETA PARA CONSULTA DE STOCK-->
      <div class="module-card" @click="navegarA('/stock')">
        <div class="icon-container">
          👀
        </div>
        <h2>Consultar Stock</h2>
        <p>Visualiza cantidades actuales del inventario.</p>
      </div>      
      <!-- Tarjeta para Clientes -->
      <div class="module-card" @click="navegarA('/clientes')">
        <div class="icon-container">
          👥
        </div>
        <h2>Clientes</h2>
        <p>Gestión y registro de Clientes y Recetas médicas.</p>
      </div>
      <!-- Tarjeta para Caja -->
      <div class="module-card" @click="navegarA('/ordenes')">
        <div class="icon-container">
          🛒
        </div>
        <h2>Caja</h2>
        <p>Registro de órdenes de trabajo y pagos.</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
const router = useRouter();
/**
 * Navega a la ruta especificada.
 * @param {string} ruta - La ruta a la que se desea navegar.
 */
const navegarA = (ruta) => {
  router.push(ruta);
};
</script>

<style scoped>
.dashboard-container {
  padding: 2rem;
  background-color: #f9fafb;
  min-height: calc(100vh - 80px); /* Ajusta este valor si la altura de tu navbar es diferente */
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.dashboard-header {
  text-align: center;
  margin-bottom: 3rem;
}

.dashboard-header h1 {
  font-size: 2.5rem;
  font-weight: 700;
  color: #1f2937;
}

.dashboard-header p {
  font-size: 1.1rem;
  color: #6b7280;
  margin-top: 0.5rem;
}

.modules-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  max-width: 1000px;
  margin: 0 auto;
  width: 100%;
}

.module-card {
  background-color: white;
  border-radius: 12px;
  padding: 2.5rem 2rem;
  text-align: center;
  border: 1px solid #e5e7eb;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
  cursor: pointer;
  transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
}

.module-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
}

.icon-container {
  font-size: 3.5rem;
  margin-bottom: 1.5rem;
  line-height: 1;
}

.module-card h2 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #111827;
  margin-bottom: 0.5rem;
}

.module-card p {
  font-size: 1rem;
  color: #4b5563;
  line-height: 1.5;
}
</style>
