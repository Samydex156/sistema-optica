<template>
  <v-container>
    <v-row>
      <v-col v-for="modulo in modulos" :key="modulo.titulo" cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA(modulo.ruta)" hover class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2"
          elevation="4" rounded="xl" variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon :icon="modulo.icono" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              {{ modulo.titulo }}
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              {{ modulo.descripcion }}
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { useRouter } from 'vue-router';
import { ref } from 'vue';

const router = useRouter();

// Se define un array con la información de los módulos para hacer el template más limpio
const modulos = ref([
  {
    titulo: 'Productos',
    descripcion: 'Creación de nuevos productos en el sistema.',
    icono: 'mdi-package-variant-closed-plus',
    ruta: '/productos/registrar',
  },
  {
    titulo: 'Características',
    descripcion: 'Gestiona categorías, proveedores, materiales y más.',
    icono: 'mdi-format-list-bulleted-type',
    ruta: '/productos/caracteristicas',
  },
  {
    titulo: 'Inventario',
    descripcion: 'Gestión de entradas, salidas o traspasos de stock.',
    icono: 'mdi-store-cog',
    ruta: '/inventario',
  },
  {
    titulo: 'Consultar Stock',
    descripcion: 'Visualiza las cantidades actuales del inventario.',
    icono: 'mdi-magnify-scan',
    ruta: '/stock',
  },
  {
    titulo: 'Clientes',
    descripcion: 'Gestión de clientes y registro de prescripciones.',
    icono: 'mdi-account-group-outline',
    ruta: '/clientes',
  },
  {
    titulo: 'Órdenes de Trabajo',
    descripcion: 'Gestión completa de órdenes de trabajo y seguimiento.',
    icono: 'mdi-clipboard-text-clock',
    ruta: '/ordenes',
  },
  {
    titulo: 'Caja',
    descripcion: 'Registro de órdenes de trabajo y gestión de pagos.',
    icono: 'mdi-cash-register',
    ruta: '/ordenes',
  },
  {
    titulo: 'Reportes',
    descripcion: 'Análisis y reportes de prescripciones médicas.',
    icono: 'mdi-chart-line',
    ruta: '/reportes/prescripciones',
  },
  {
    titulo: 'Sobres',
    descripcion: 'Registro de pedidos de sobres.',
    icono: 'mdi-email-outline',
    ruta: '/sobres/registrar',
  },
  {
    titulo: 'Recetas Legacy',
    descripcion: 'Consulta histórico de recetas antiguas.',
    icono: 'mdi-database-clock-outline',
    ruta: '/recetas-legacy',
  },
]);

const navegarA = (ruta) => {
  if (ruta) {
    router.push(ruta);
  }
};
</script>

<style scoped>
.v-card {
  transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
}

.v-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1) !important;
}
</style>
