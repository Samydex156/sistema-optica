<template>
  <v-container>
    <v-row>
      <!-- Módulo: Productos -->
      <v-col cols="12" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/productos/registrar')" hover
          class="text-left text-sm-center fill-height d-flex flex-row flex-sm-column pt-3 pb-3 px-3 pa-sm-5 align-center" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="56" class="mr-3 mr-sm-0 mb-0 mb-sm-3 flex-shrink-0">
            <v-icon icon="mdi-package-variant-closed-plus" size="28"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold text-sm-h6">
              Productos
            </h3>
            <p class="text-caption text-sm-body-2 text-medium-emphasis mt-0 mt-sm-1">
              Creación de nuevos productos en el sistema.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Características -->
      <v-col cols="12" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/productos/caracteristicas')" hover
          class="text-left text-sm-center fill-height d-flex flex-row flex-sm-column pt-3 pb-3 px-3 pa-sm-5 align-center" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="56" class="mr-3 mr-sm-0 mb-0 mb-sm-3 flex-shrink-0">
            <v-icon icon="mdi-format-list-bulleted-type" size="28"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold text-sm-h6">
              Características
            </h3>
            <p class="text-caption text-sm-body-2 text-medium-emphasis mt-0 mt-sm-1">
              Gestiona categorías, proveedores, materiales y más.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Inventario -->
      <v-col cols="12" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/inventario')" hover
          class="text-left text-sm-center fill-height d-flex flex-row flex-sm-column pt-3 pb-3 px-3 pa-sm-5 align-center" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="56" class="mr-3 mr-sm-0 mb-0 mb-sm-3 flex-shrink-0">
            <v-icon icon="mdi-store-cog" size="28"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold text-sm-h6">
              Inventario
            </h3>
            <p class="text-caption text-sm-body-2 text-medium-emphasis mt-0 mt-sm-1">
              Gestión de entradas, salidas o traspasos de stock.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Consultar Stock -->
      <v-col cols="12" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/stock')" hover
          class="text-left text-sm-center fill-height d-flex flex-row flex-sm-column pt-3 pb-3 px-3 pa-sm-5 align-center" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="56" class="mr-3 mr-sm-0 mb-0 mb-sm-3 flex-shrink-0">
            <v-icon icon="mdi-magnify-scan" size="28"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold text-sm-h6">
              Consultar Stock
            </h3>
            <p class="text-caption text-sm-body-2 text-medium-emphasis mt-0 mt-sm-1">
              Visualiza las cantidades actuales del inventario.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Clientes -->
      <v-col cols="12" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/clientes')" hover
          class="text-left text-sm-center fill-height d-flex flex-row flex-sm-column pt-3 pb-3 px-3 pa-sm-5 align-center" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="56" class="mr-3 mr-sm-0 mb-0 mb-sm-3 flex-shrink-0">
            <v-icon icon="mdi-account-group-outline" size="28"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold text-sm-h6">
              Clientes
            </h3>
            <p class="text-caption text-sm-body-2 text-medium-emphasis mt-0 mt-sm-1">
              Gestión de clientes y registro de prescripciones.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Órdenes de Trabajo -->
      <v-col cols="12" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/ordenes')" hover
          class="text-left text-sm-center fill-height d-flex flex-row flex-sm-column pt-3 pb-3 px-3 pa-sm-5 align-center" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="56" class="mr-3 mr-sm-0 mb-0 mb-sm-3 flex-shrink-0">
            <v-icon icon="mdi-clipboard-text-clock" size="28"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold text-sm-h6">
              Órdenes de Trabajo
            </h3>
            <p class="text-caption text-sm-body-2 text-medium-emphasis mt-0 mt-sm-1">
              Gestión completa de órdenes de trabajo y seguimiento.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Caja -->
      <v-col cols="12" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/ordenes')" hover
          class="text-left text-sm-center fill-height d-flex flex-row flex-sm-column pt-3 pb-3 px-3 pa-sm-5 align-center" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="56" class="mr-3 mr-sm-0 mb-0 mb-sm-3 flex-shrink-0">
            <v-icon icon="mdi-cash-register" size="28"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold text-sm-h6">
              Caja
            </h3>
            <p class="text-caption text-sm-body-2 text-medium-emphasis mt-0 mt-sm-1">
              Registro de órdenes de trabajo y gestión de pagos.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Reportes -->
      <v-col cols="12" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/reportes/prescripciones')" hover
          class="text-left text-sm-center fill-height d-flex flex-row flex-sm-column pt-3 pb-3 px-3 pa-sm-5 align-center" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="56" class="mr-3 mr-sm-0 mb-0 mb-sm-3 flex-shrink-0">
            <v-icon icon="mdi-chart-line" size="28"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold text-sm-h6">
              Reportes
            </h3>
            <p class="text-caption text-sm-body-2 text-medium-emphasis mt-0 mt-sm-1">
              Análisis y reportes de prescripciones médicas.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Sobres -->
      <v-col cols="12" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/sobres/registrar')" hover
          class="text-left text-sm-center fill-height d-flex flex-row flex-sm-column pt-3 pb-3 px-3 pa-sm-5 align-center" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="56" class="mr-3 mr-sm-0 mb-0 mb-sm-3 flex-shrink-0">
            <v-icon icon="mdi-email-outline" size="28"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold text-sm-h6">
              Sobres
            </h3>
            <p class="text-caption text-sm-body-2 text-medium-emphasis mt-0 mt-sm-1">
              Registro de pedidos de sobres.
            </p>
          </div>
        </v-card>
      </v-col>

      <!-- Módulo: Recetas Legacy -->
      <v-col cols="12" sm="6" md="4" lg="4">
        <v-card @click="navegarA('/recetas-legacy')" hover
          class="text-left text-sm-center fill-height d-flex flex-row flex-sm-column pt-3 pb-3 px-3 pa-sm-5 align-center" elevation="4" rounded="xl"
          variant="elevated" color="white">
          <v-avatar color="primary" variant="tonal" size="56" class="mr-3 mr-sm-0 mb-0 mb-sm-3 flex-shrink-0">
            <v-icon icon="mdi-database-clock-outline" size="28"></v-icon>
          </v-avatar>
          <div class="d-flex flex-column flex-grow-1">
            <h3 class="text-subtitle-1 font-weight-bold text-sm-h6">
              Recetas Legacy
            </h3>
            <p class="text-caption text-sm-body-2 text-medium-emphasis mt-0 mt-sm-1">
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
.v-card {
  transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
}

.v-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1) !important;
}
</style>
