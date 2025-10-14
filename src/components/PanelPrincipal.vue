<template>
  <v-container>
    <v-row justify="center" class="text-center my-4">
      <v-col cols="12">
        <h1 class="text-h3 font-weight-bold text-grey-darken-3">Panel Principal</h1>
        <p class="text-subtitle-1 text-grey-darken-1 mt-2">
          Seleccione un módulo para iniciar operaciones.
        </p>
      </v-col>
    </v-row>

    <v-row>
      <v-col
        v-for="modulo in modulos"
        :key="modulo.titulo"
        cols="12"
        sm="6"
        md="4"
        lg="4"
      >
        <v-card
          @click="navegarA(modulo.ruta)"
          hover
          class="text-center pa-4 fill-height d-flex flex-column"
          elevation="4"
          rounded="lg"
        >
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon :icon="modulo.icono" color="primary" size="64"></v-icon>

            <v-card-title class="font-weight-bold mt-4">
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
]);

/**
 * Navega a la ruta especificada.
 * @param {string} ruta - La ruta a la que se desea navegar.
 */
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
