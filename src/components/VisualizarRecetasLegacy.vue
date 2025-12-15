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

        <v-text-field ref="searchInputRef" v-model="busqueda" label="Buscar por Nro. Receta, Nombres o Apellidos"
            prepend-inner-icon="mdi-magnify" variant="outlined" density="compact" clearable class="mb-4"
            hide-details></v-text-field>

        <v-data-table-server v-model:items-per-page="itemsPerPage" :headers="headers" :items="recetas"
            :items-length="totalRecetas" :loading="cargando" :search="busqueda" item-value="id" class="elevation-1 mt-4"
            @update:options="fetchRecetas" hover density="compact">
            <template v-slot:item.FECHA_RECETA="{ item }">
                {{ formatearFecha(item.FECHA_RECETA) }}
            </template>
            <template v-slot:item.FECHA_ENTREGA="{ item }">
                {{ formatearFecha(item.FECHA_ENTREGA) }}
            </template>
            <template v-slot:item.NOMBRES="{ item }">
                {{ `${item.AP_PATERNO || ''} ${item.AP_MATERNO || ''} ${item.NOMBRES || ''}` }}
            </template>
            <template v-slot:no-data>
                No se encontraron recetas.
            </template>
        </v-data-table-server>

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
const itemsPerPage = ref(10);
const busqueda = ref("");

// --- Filtro por Letra ---
const filtroLetra = ref(null);
const alfabeto = ['A', 'B', 'C', 'CH', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'LL', 'M', 'N', 'Ñ', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

// --- Headers ---
// Adaptados para mostrar la información más relevante primero
const headers = [
    { title: 'Nº Receta', key: 'NRO_RECETA', sortable: true, width: '100px', fixed: true },
    { title: 'Cliente', key: 'NOMBRES', sortable: false, width: '250px' }, // Combinaremos Nombre + Apellidos en el template
    { title: 'Fecha', key: 'FECHA_RECETA', sortable: true, width: '110px' },
    { title: 'Tienda', key: 'TIENDA', width: '120px' },
    //   { title: 'Procedencia', key: 'PROCEDENCIA', width: '120px' },
    //   { title: 'Doctor', key: 'DOCTOR', width: '150px' },

    // OD Lejos
    { title: 'Esf OD (L)', key: 'ESF_OD_LEJ', align: 'end', cellProps: { class: 'text-blue-grey-darken-1' } },
    { title: 'Cil OD (L)', key: 'CIL_OD_LEJ', align: 'end', cellProps: { class: 'text-blue-grey-darken-1' } },
    { title: 'Eje OD (L)', key: 'EJE_OD_LEJ', align: 'end', cellProps: { class: 'text-blue-grey-darken-1' } },

    // OI Lejos
    { title: 'Esf OI (L)', key: 'ESF_OI_LEJ', align: 'end', cellProps: { class: 'text-blue-grey-darken-1' } },
    { title: 'Cil OI (L)', key: 'CIL_OI_LEJ', align: 'end', cellProps: { class: 'text-blue-grey-darken-1' } },
    { title: 'Eje OI (L)', key: 'EJE_OI_LEJ', align: 'end', cellProps: { class: 'text-blue-grey-darken-1' } },

    // OD Cerca
    //   { title: 'Esf OD (C)', key: 'ESF_OD_CER', align: 'end', cellProps: { class: 'text-brown-darken-1' } },
    //   { title: 'Cil OD (C)', key: 'CIL_OD_CER', align: 'end', cellProps: { class: 'text-brown-darken-1' } },
    //   { title: 'Eje OD (C)', key: 'EJE_OD_CER', align: 'end', cellProps: { class: 'text-brown-darken-1' } },

    // OI Cerca
    //   { title: 'Esf OI (C)', key: 'ESF_OI_CER', align: 'end', cellProps: { class: 'text-brown-darken-1' } },
    //   { title: 'Cil OI (C)', key: 'CIL_OI_CER', align: 'end', cellProps: { class: 'text-brown-darken-1' } },
    //   { title: 'Eje OI (C)', key: 'EJE_OI_CER', align: 'end', cellProps: { class: 'text-brown-darken-1' } },

    //   { title: 'Armazón', key: 'ARMAZON', width: '150px' },
    //   { title: 'Cristales 1', key: 'CRISTALES_1', width: '200px' },
    //   { title: 'Cristales 2', key: 'CRISTALES_2', width: '200px' },
    { title: 'F. Entrega', key: 'FECHA_ENTREGA', width: '110px' },
    { title: 'Nº Boleta', key: 'NRO_BOLETA' },
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
    padding: 1rem 2rem;
    background-color: #f8f9fa;
    color: #212529;
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
</style>
