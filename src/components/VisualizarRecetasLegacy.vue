<template>
    <div class="page-container">
        <header class="page-header">
            <div class="d-flex align-center">
                <v-btn icon="mdi-arrow-left" variant="text" @click="$router.push('/panel')" class="mr-2"></v-btn>
                <h1>Recetas Legacy</h1>
            </div>
        </header>

        <!-- Filtro por Letra -->
        <div class="d-flex flex-wrap gap-1 mb-4 justify-center">
            <v-chip v-for="letra in alfabeto" :key="letra" :color="filtroLetra === letra ? 'primary' : 'default'"
                :variant="filtroLetra === letra ? 'flat' : 'outlined'" class="ma-1 cursor-pointer" size="small"
                @click="seleccionarLetra(letra)">
                {{ letra }}
            </v-chip>
            <v-chip v-if="filtroLetra" color="error" variant="text" class="ma-1 cursor-pointer" size="small"
                prepend-icon="mdi-close" @click="seleccionarLetra(null)">
                Limpiar Filtro
            </v-chip>
        </div>

        <v-text-field ref="searchInputRef" v-model="busqueda" label="Buscar receta..."
            placeholder="Por número de receta, nombre o apellido" prepend-inner-icon="mdi-magnify"
            variant="outlined" density="compact" clearable class="mb-4" hide-details></v-text-field>

        <v-data-table-server v-model:items-per-page="itemsPerPage" :headers="headers" :items="recetas"
            :items-length="totalRecetas" :loading="cargando" :search="busqueda" item-value="id" class="elevation-1 mt-4 cursor-pointer"
            @update:options="fetchRecetas" hover density="compact" @click:row="(event, { item }) => verDetalles(item)">
            <template v-slot:item.FECHA_RECETA="{ item }">
                {{ formatearFecha(item.FECHA_RECETA) }}
            </template>
            <template v-slot:item.FECHA_ENTREGA="{ item }">
                {{ formatearFecha(item.FECHA_ENTREGA) }}
            </template>
            <template v-slot:item.NOMBRES="{ item }">
                {{ `${item.AP_PATERNO || ''} ${item.AP_MATERNO || ''} ${item.NOMBRES || ''}` }}
            </template>
            <template v-slot:item.acciones="{ item }">
                <v-tooltip location="top" text="Ver Detalles Completos">
                    <template v-slot:activator="{ props }">
                        <v-btn v-bind="props" icon size="small" variant="text" color="primary"
                            @click.stop="verDetalles(item)">
                            <v-icon>mdi-eye</v-icon>
                        </v-btn>
                    </template>
                </v-tooltip>
            </template>
            <template v-slot:no-data>
                No se encontraron recetas.
            </template>
        </v-data-table-server>

        <v-dialog v-model="dialogDetalles" max-width="850px" scrollable>
            <v-card v-if="recetaSeleccionada">
                <v-toolbar color="primary" density="compact">
                    <v-toolbar-title class="text-subtitle-1 font-weight-bold">
                        Detalles de Receta: {{ recetaSeleccionada.NRO_RECETA }}
                    </v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-btn icon="mdi-close" variant="text" @click="dialogDetalles = false"></v-btn>
                </v-toolbar>
                <v-card-text class="pa-4 bg-grey-lighten-4">
                    <v-row>
                        <!-- Información del Cliente -->
                        <v-col cols="12" md="6">
                            <v-card variant="outlined" class="bg-white h-100">
                                <v-card-title class="text-subtitle-2 font-weight-bold border-b py-2">Datos del
                                    Cliente</v-card-title>
                                <v-card-text class="pt-3">
                                    <div class="mb-1"><strong>Nombre:</strong> {{ `${recetaSeleccionada.AP_PATERNO ||
                                        ''}
                                        ${recetaSeleccionada.AP_MATERNO || ''} ${recetaSeleccionada.NOMBRES || ''}` }}
                                    </div>
                                    <div class="mb-1"><strong>Teléfono / Dir:</strong> {{ recetaSeleccionada.DIR_TEL ||
                                        '-' }}
                                    </div>
                                    <div class="mb-1"><strong>Procedencia:</strong> {{ recetaSeleccionada.PROCEDENCIA ||
                                        '-' }}
                                    </div>
                                    <div class="mb-1"><strong>Tienda:</strong> {{ recetaSeleccionada.TIENDA || '-' }}
                                    </div>
                                </v-card-text>
                            </v-card>
                        </v-col>

                        <!-- Información General -->
                        <v-col cols="12" md="6">
                            <v-card variant="outlined" class="bg-white h-100">
                                <v-card-title class="text-subtitle-2 font-weight-bold border-b py-2">Datos
                                    Generales</v-card-title>
                                <v-card-text class="pt-3">
                                    <div class="mb-1"><strong>Fecha Receta:</strong> {{
                                        formatearFecha(recetaSeleccionada.FECHA_RECETA) }}</div>
                                    <div class="mb-1"><strong>Fecha Entrega:</strong> {{
                                        formatearFecha(recetaSeleccionada.FECHA_ENTREGA) }}</div>
                                    <div class="mb-1"><strong>Doctor:</strong> {{ recetaSeleccionada.DOCTOR || '-' }}
                                    </div>
                                    <div class="mb-1"><strong>Nº Boleta:</strong> {{ recetaSeleccionada.NRO_BOLETA ||
                                        '-' }} |
                                        <strong>Nº Sobre:</strong> {{ recetaSeleccionada.NRO_SOBRE || '-' }}
                                    </div>
                                </v-card-text>
                            </v-card>
                        </v-col>

                        <!-- Especificaciones de Lentes -->
                        <v-col cols="12">
                            <v-card variant="outlined" class="bg-white">
                                <v-card-title class="text-subtitle-2 font-weight-bold border-b py-2">Especificaciones
                                    Ópticas</v-card-title>
                                <v-card-text class="pt-3">
                                    <v-table density="compact" class="text-caption mb-3">
                                        <thead>
                                            <tr>
                                                <th></th>
                                                <th class="text-center font-weight-bold">ESF</th>
                                                <th class="text-center font-weight-bold">CIL</th>
                                                <th class="text-center font-weight-bold">EJE</th>
                                                <th class="text-center font-weight-bold">DIP</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td class="font-weight-bold">OD (Lejos)</td>
                                                <td class="text-center">{{ recetaSeleccionada.ESF_OD_LEJ || '-' }}</td>
                                                <td class="text-center">{{ recetaSeleccionada.CIL_OD_LEJ || '-' }}</td>
                                                <td class="text-center">{{ recetaSeleccionada.EJE_OD_LEJ || '-' }}</td>
                                                <td class="text-center" rowspan="2" style="vertical-align: middle;">{{
                                                    recetaSeleccionada.DIP_LEJOS || '-' }}</td>
                                            </tr>
                                            <tr>
                                                <td class="font-weight-bold">OI (Lejos)</td>
                                                <td class="text-center">{{ recetaSeleccionada.ESF_OI_LEJ || '-' }}</td>
                                                <td class="text-center">{{ recetaSeleccionada.CIL_OI_LEJ || '-' }}</td>
                                                <td class="text-center">{{ recetaSeleccionada.EJE_OI_LEJ || '-' }}</td>
                                            </tr>
                                            <tr class="bg-grey-lighten-4">
                                                <td class="font-weight-bold">OD (Cerca)</td>
                                                <td class="text-center">{{ recetaSeleccionada.ESF_OD_CER || '-' }}</td>
                                                <td class="text-center">{{ recetaSeleccionada.CIL_OD_CER || '-' }}</td>
                                                <td class="text-center">{{ recetaSeleccionada.EJE_OD_CER || '-' }}</td>
                                                <td class="text-center" rowspan="2" style="vertical-align: middle;">{{
                                                    recetaSeleccionada.DIP_CERCA || '-' }}</td>
                                            </tr>
                                            <tr class="bg-grey-lighten-4">
                                                <td class="font-weight-bold">OI (Cerca)</td>
                                                <td class="text-center">{{ recetaSeleccionada.ESF_OI_CER || '-' }}</td>
                                                <td class="text-center">{{ recetaSeleccionada.CIL_OI_CER || '-' }}</td>
                                                <td class="text-center">{{ recetaSeleccionada.EJE_OI_CER || '-' }}</td>
                                            </tr>
                                        </tbody>
                                    </v-table>

                                    <!-- Otras Medidas -->
                                    <div class="d-flex flex-wrap gap-4 text-caption mt-2">
                                        <div><strong>DIP OD:</strong> {{ recetaSeleccionada.DIP_OD || '-' }}</div>
                                        <div><strong>DIP OI:</strong> {{ recetaSeleccionada.DIP_OI || '-' }}</div>
                                        <div><strong>Base:</strong> {{ recetaSeleccionada.BASE || '-' }}</div>
                                        <div><strong>Altura:</strong> {{ recetaSeleccionada.ALTURA || '-' }}</div>
                                    </div>
                                </v-card-text>
                            </v-card>
                        </v-col>

                        <!-- Materiales y Armazón -->
                        <v-col cols="12">
                            <v-card variant="outlined" class="bg-white">
                                <v-card-title class="text-subtitle-2 font-weight-bold border-b py-2">Materiales y
                                    Trabajo</v-card-title>
                                <v-card-text class="pt-3">
                                    <v-row dense class="text-body-2">
                                        <v-col cols="12" sm="6">
                                            <div class="mb-1"><strong>Cristales 1:</strong> {{
                                                recetaSeleccionada.CRISTALES_1 ||
                                                '-' }}</div>
                                            <div class="mb-1"><strong>Cristales 2:</strong> {{
                                                recetaSeleccionada.CRISTALES_2 ||
                                                '-' }}</div>
                                        </v-col>
                                        <v-col cols="12" sm="6">
                                            <div class="mb-1"><strong>Armazón:</strong> {{ recetaSeleccionada.ARMAZON ||
                                                '-' }}
                                            </div>
                                            <div class="mb-1"><strong>Proveedor:</strong> {{
                                                recetaSeleccionada.PROVEEDOR || '-'
                                            }}</div>
                                            <div class="mb-1"><strong>Armador:</strong> {{ recetaSeleccionada.ARMADOR ||
                                                '-' }}
                                            </div>
                                        </v-col>
                                    </v-row>
                                </v-card-text>
                            </v-card>
                        </v-col>
                    </v-row>
                </v-card-text>
            </v-card>
        </v-dialog>
    </div>
</template>

<script setup>
import { ref, nextTick, watch, onMounted } from "vue";
import { useRouter } from 'vue-router';
import { supabase } from "../lib/supabaseClient.js";
import { debounce } from 'lodash-es';

const router = useRouter();

// --- Referencias DOM ---
const searchInputRef = ref(null);

// --- Estado de la Tabla Principal ---
const cargando = ref(true);
const recetas = ref([]);
const totalRecetas = ref(0);
const itemsPerPage = ref(50);
const busqueda = ref("");

// --- Modal de Detalles ---
const dialogDetalles = ref(false);
const recetaSeleccionada = ref(null);

function verDetalles(item) {
    recetaSeleccionada.value = item;
    dialogDetalles.value = true;
}

// --- Filtro por Letra ---
const filtroLetra = ref(null);
const alfabeto = ['A', 'B', 'C', 'CH', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'LL', 'M', 'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

// --- Headers ---
// Adaptados para mostrar la información más relevante primero
const headers = [
    { title: 'Nº Receta', key: 'NRO_RECETA', sortable: true, width: '100px' },
    { title: 'Cliente', key: 'NOMBRES', sortable: false, width: '250px' },
    { title: 'Fecha Receta', key: 'FECHA_RECETA', sortable: true, width: '110px' },
    { title: 'Tienda', key: 'TIENDA', width: '120px' },
    { title: 'F. Entrega', key: 'FECHA_ENTREGA', width: '110px' },
    { title: 'Acciones', key: 'acciones', sortable: false, align: 'center', width: '100px' },
];


// --- Lifecycle Hooks ---
onMounted(() => {
    nextTick(() => {
        searchInputRef.value?.focus();
    });
});

// --- Funciones de Datos ---

function seleccionarLetra(letra) {
    if (filtroLetra.value === letra) {
        filtroLetra.value = null;
    } else {
        filtroLetra.value = letra;
        busqueda.value = "";
    }
    // Resetear a pag 1 se hace indirectamente al cambiar params o se fuerza, 
    // pero v-data-table-server maneja el trigger con fetchRecetas
}

async function fetchRecetas({ page, itemsPerPage, sortBy }) {
    cargando.value = true;
    try {
        const limite = itemsPerPage;
        const desplazamiento = (page - 1) * limite;

        let query = supabase
            .from('recetas_legacy')
            .select('*', { count: 'exact' });

        // 1. Busqueda Global Inteligente
        if (busqueda.value) {
            const terminos = busqueda.value.trim().split(/\s+/);

            // Para cada término, agregamos una condición OR que busque en cualquiera de los campos.
            // Al encadenar estos ORs, Supabase los trata como AND entre grupos.
            // Es decir: (match_term1) AND (match_term2) AND ...
            terminos.forEach(term => {
                query = query.or(`NRO_RECETA.ilike.%${term}%,NOMBRES.ilike.%${term}%,AP_PATERNO.ilike.%${term}%,AP_MATERNO.ilike.%${term}%`);
            });
        }
        // 2. Filtro por Letra
        else if (filtroLetra.value) {
            if (filtroLetra.value === 'CH') {
                query = query.ilike('AP_PATERNO', 'CH%');
            } else if (filtroLetra.value === 'LL') {
                query = query.ilike('AP_PATERNO', 'LL%');
            } else {
                query = query.ilike('AP_PATERNO', `${filtroLetra.value}%`);
            }
            // Orden alfabético si hay filtro
            query = query.order('AP_PATERNO', { ascending: true })
                .order('AP_MATERNO', { ascending: true })
                .order('NOMBRES', { ascending: true });
        }

        // Ordenamiento por defecto si no viene de la tabla
        if (!sortBy || sortBy.length === 0) {
            if (!filtroLetra.value) {
                query = query.order('FECHA_ENTREGA', { ascending: false });
            }
        } else {
            // Ordenamiento desde la tabla
            for (const sort of sortBy) {
                query = query.order(sort.key, { ascending: sort.order === 'asc' });
            }
        }

        // Paginación
        query = query.range(desplazamiento, desplazamiento + limite - 1);

        const { data, error, count } = await query;

        if (error) throw error;

        recetas.value = data || [];
        totalRecetas.value = count || 0;

    } catch (error) {
        console.error("Error al obtener recetas legacy:", error);
    } finally {
        cargando.value = false;
    }
}

watch(busqueda, debounce(() => {
    if (busqueda.value) {
        filtroLetra.value = null;
    }
    // Al cambiar busqueda, v-data-table-server detecta el cambio en 'search' prop 
    // pero necesitamos resetear a página 1 manualmente si queremos "búsqueda fresca",
    // sin embargo, el watcher de 'search' interno de v-data-table-server suele manejarlo.
    // Aquí, como pasamos 'fetchRecetas' a @update:options, se llamará automáticamente.
}, 500));

watch(filtroLetra, () => {
    // Al cambiar filtro, trigger manual si es necesario, 
    // pero idealmente deberíamos modificar una ref que fuerce reload.
    // v-data-table-server no observa variables externas automáticamente salvo search.
    // Lo más fácil es resetear itemsPerPage o similar, pero mejor llamar fetchRecetas directamente
    // O mejor aún, dejar que el usuario interactúe, pero aquí queremos inmediatez.
    // Haremos un ref "version" o simplemente llamamos fetchRecetas con los valores actuales.
    // NOTA: v-data-table-server no expone un método "refresh" facil.
    // Truco: cambiar page a 1 suele disparar.
    fetchRecetas({ page: 1, itemsPerPage: itemsPerPage.value, sortBy: [] });
});

const formatearFecha = (fecha) => {
    if (!fecha) return '-';
    // Si la fecha viene como string YYYY-MM-DD
    return new Date(fecha).toLocaleDateString('es-ES', { timeZone: 'UTC' });
};
</script>

<style scoped>
.page-container {
    font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    padding: 1rem 0.75rem;
    background-color: #f8f9fa;
    color: #212529;
}

@media (min-width: 600px) {
    .page-container {
        padding: 1rem 2rem;
    }
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
    padding-bottom: .5rem;
    border-bottom: 1px solid #dee2e6;
}

.page-header h1 {
    margin: 0;
    font-size: 1.75rem;
    font-weight: 600;
}

:deep(.v-data-table tbody tr) {
    cursor: pointer;
}

/* Control de altura de filas */
:deep(.v-data-table__td) {
    height: 30px !important;
    padding-top: 0 !important;
    padding-bottom: 0 !important;
    font-size: 0.85rem;
    white-space: nowrap;
    /* Evitar que se rompan líneas en celdas pequeñas */
}

/* Estilos para el encabezado de la tabla */
:deep(.v-data-table__th) {
    background-color: #2c3e50 !important;
    color: #ffffff !important;
    font-weight: 600 !important;
    text-transform: uppercase;
    font-size: 0.85rem;
}

:deep(.v-data-table__th:hover) {
    background-color: #34495e !important;
}

:deep(.v-data-table-header__sort-icon) {
    color: rgba(255, 255, 255, 0.7) !important;
}

@media (max-width: 600px) {
    .page-header h1 {
        font-size: 1.4rem;
    }

    :deep(.v-table .v-table__wrapper table th),
    :deep(.v-table .v-table__wrapper table td) {
        padding: 0 4px !important;
        font-size: 0.75rem !important;
    }
}
</style>
