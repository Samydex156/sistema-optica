<template>
  <v-container class="max-width-container">
    <v-row dense>
      <!-- Módulo: Productos -->
      <v-col cols="12" sm="6" md="3">
        <v-card @click="navegarA('/productos/registrar')" hover
          class="text-left fill-height d-flex flex-row pa-3 align-center" elevation="2" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="44" class="mr-3 flex-shrink-0">
            <v-icon icon="mdi-package-variant-closed-plus" size="22"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold">
              Productos
            </h3>
            <p class="text-caption text-medium-emphasis mt-0">
              Creación de nuevos productos en el sistema.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Características -->
      <v-col cols="12" sm="6" md="3" >
        <v-card @click="navegarA('/productos/caracteristicas')" hover
          class="text-left fill-height d-flex flex-row pa-3 align-center" elevation="2" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="44" class="mr-3 flex-shrink-0">
            <v-icon icon="mdi-format-list-bulleted-type" size="22"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold">
              Características
            </h3>
            <p class="text-caption text-medium-emphasis mt-0">
              Gestiona categorías, proveedores, materiales and más.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Inventario -->
      <v-col cols="12" sm="6" md="3">
        <v-card @click="navegarA('/inventario')" hover
          class="text-left fill-height d-flex flex-row pa-3 align-center" elevation="2" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="44" class="mr-3 flex-shrink-0">
            <v-icon icon="mdi-store-cog" size="22"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold">
              Inventario
            </h3>
            <p class="text-caption text-medium-emphasis mt-0">
              Gestión de entradas, salidas o traspasos de stock.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Consultar Stock -->
      <v-col cols="12" sm="6" md="3">
        <v-card @click="navegarA('/stock')" hover
          class="text-left fill-height d-flex flex-row pa-3 align-center" elevation="2" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="44" class="mr-3 flex-shrink-0">
            <v-icon icon="mdi-magnify-scan" size="22"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold">
              Consultar Stock
            </h3>
            <p class="text-caption text-medium-emphasis mt-0">
              Visualiza las cantidades actuales del inventario.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Clientes -->
      <v-col cols="12" sm="6" md="3">
        <v-card @click="navegarA('/clientes')" hover
          class="text-left fill-height d-flex flex-row pa-3 align-center" elevation="2" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="44" class="mr-3 flex-shrink-0">
            <v-icon icon="mdi-account-group-outline" size="22"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold">
              Clientes
            </h3>
            <p class="text-caption text-medium-emphasis mt-0">
              Gestión de clientes y registro de prescripciones.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Órdenes de Trabajo -->
      <v-col cols="12" sm="6" md="3">
        <v-card @click="navegarA('/ordenes')" hover
          class="text-left fill-height d-flex flex-row pa-3 align-center" elevation="2" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="44" class="mr-3 flex-shrink-0">
            <v-icon icon="mdi-clipboard-text-clock" size="22"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold">
              Órdenes de Trabajo
            </h3>
            <p class="text-caption text-medium-emphasis mt-0">
              Gestión completa de órdenes de trabajo y seguimiento.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Caja -->
      <v-col cols="12" sm="6" md="3">
        <v-card @click="navegarA('/ordenes')" hover
          class="text-left fill-height d-flex flex-row pa-3 align-center" elevation="2" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="44" class="mr-3 flex-shrink-0">
            <v-icon icon="mdi-cash-register" size="22"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold">
              Caja
            </h3>
            <p class="text-caption text-medium-emphasis mt-0">
              Registro de órdenes de trabajo y gestión de pagos.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Reportes -->
      <v-col cols="12" sm="6" md="3">
        <v-card @click="navegarA('/reportes/prescripciones')" hover
          class="text-left fill-height d-flex flex-row pa-3 align-center" elevation="2" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="44" class="mr-3 flex-shrink-0">
            <v-icon icon="mdi-chart-line" size="22"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold">
              Reportes
            </h3>
            <p class="text-caption text-medium-emphasis mt-0">
              Análisis and reportes de prescripciones médicas.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Sobres -->
      <v-col cols="12" sm="6" md="3">
        <v-card @click="navegarA('/sobres/registrar')" hover
          class="text-left fill-height d-flex flex-row pa-3 align-center" elevation="2" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="44" class="mr-3 flex-shrink-0">
            <v-icon icon="mdi-email-outline" size="22"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold">
              Sobres
            </h3>
            <p class="text-caption text-medium-emphasis mt-0">
              Registro de pedidos de sobres.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Recetas Legacy -->
      <v-col cols="12" sm="6" md="3">
        <v-card @click="navegarA('/recetas-legacy')" hover
          class="text-left fill-height d-flex flex-row pa-3 align-center" elevation="2" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="44" class="mr-3 flex-shrink-0">
            <v-icon icon="mdi-database-clock-outline" size="22"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold">
              Recetas Legacy
            </h3>
            <p class="text-caption text-medium-emphasis mt-0">
              Consulta histórico de recetas antiguas.
            </p>
          </div>
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
.max-width-container {
  max-width: 1280px !important;
}

.v-card {
  min-height: 125px;
  transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
}

.v-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1) !important;
}
</style>
