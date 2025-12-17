<template>
  <v-container>
    <v-row>
      <!-- Módulo: Productos -->
      <v-col cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/productos/registrar')" hover
          class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon icon="mdi-package-variant-closed-plus" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              Productos
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              Creación de nuevos productos en el sistema.
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- Módulo: Características -->
      <v-col cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/productos/caracteristicas')" hover
          class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon icon="mdi-format-list-bulleted-type" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              Características
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              Gestiona categorías, proveedores, materiales y más.
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- Módulo: Inventario -->
      <v-col cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/inventario')" hover class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2"
          elevation="4" rounded="xl" variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon icon="mdi-store-cog" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              Inventario
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              Gestión de entradas, salidas o traspasos de stock.
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- Módulo: Consultar Stock -->
      <v-col cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/stock')" hover class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2"
          elevation="4" rounded="xl" variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon icon="mdi-magnify-scan" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              Consultar Stock
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              Visualiza las cantidades actuales del inventario.
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- Módulo: Clientes -->
      <v-col cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/clientes')" hover class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2"
          elevation="4" rounded="xl" variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon icon="mdi-account-group-outline" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              Clientes
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              Gestión de clientes y registro de prescripciones.
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- Módulo: Órdenes de Trabajo -->
      <v-col cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/ordenes')" hover class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2"
          elevation="4" rounded="xl" variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon icon="mdi-clipboard-text-clock" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              Órdenes de Trabajo
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              Gestión completa de órdenes de trabajo y seguimiento.
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- Módulo: Caja -->
      <v-col cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/ordenes')" hover class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2"
          elevation="4" rounded="xl" variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon icon="mdi-cash-register" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              Caja
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              Registro de órdenes de trabajo y gestión de pagos.
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- Módulo: Reportes -->
      <v-col cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/reportes/prescripciones')" hover
          class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon icon="mdi-chart-line" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              Reportes
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              Análisis y reportes de prescripciones médicas.
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- Módulo: Sobres -->
      <v-col cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/sobres/registrar')" hover
          class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon icon="mdi-email-outline" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              Sobres
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              Registro de pedidos de sobres.
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>

      <!-- Módulo: Recetas Legacy -->
      <v-col cols="6" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/recetas-legacy')" hover
          class="text-center fill-height d-flex flex-column pt-4 pb-2 px-2" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-card-item class="d-flex flex-column justify-center align-center">
            <v-icon icon="mdi-database-clock-outline" color="primary" size="50"></v-icon>

            <v-card-title class="font-weight-bold mt-1">
              Recetas Legacy
            </v-card-title>

            <v-card-text class="text-medium-emphasis">
              Consulta histórico de recetas antiguas.
            </v-card-text>
          </v-card-item>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

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
