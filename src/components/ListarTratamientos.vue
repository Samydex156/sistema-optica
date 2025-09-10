<template>
  <div>
    <h3>Lista de Tratamientos</h3>
    <button @click="abrirModalCrear">Nuevo Tratamiento</button>
    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Nombre</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(tratamiento, index) in tratamientos" :key="tratamiento.cod_tratamiento_cristal">
          <td>{{ index + 1 }}</td>
          <td>{{ tratamiento.nombre_tratamiento }}</td>
          <td>
            <button @click="editarTratamiento(tratamiento)">Editar</button>
            <button @click="eliminarTratamiento(tratamiento.cod_tratamiento_cristal)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal">
        <h3>{{ editId ? 'Editar' : 'Nuevo' }} Tratamiento</h3>
        <input v-model="nombreTratamiento" placeholder="Nombre del tratamiento" />
        <div class="modal-actions">
          <button @click="guardarTratamiento">Guardar</button>
          <button @click="showModal = false">Cancelar</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from "vue";
import { supabase } from "../lib/supabaseClient.js";

const tratamientos = ref([]);
const showModal = ref(false);
const nombreTratamiento = ref("");
const editId = ref(null);

async function getTratamientos() {
  const { data } = await supabase.from("tratamientos").select();
  tratamientos.value = data || [];
}

async function guardarTratamiento() {
  if (editId.value) {
    // Update existing
    await supabase
      .from("tratamientos")
      .update({ nombre_tratamiento: nombreTratamiento.value })
      .eq("cod_tratamiento_cristal", editId.value);
  } else {
    // Create new
    await supabase
      .from("tratamientos")
      .insert({ nombre_tratamiento: nombreTratamiento.value });
  }
  nombreTratamiento.value = "";
  showModal.value = false;
  editId.value = null;
}

async function eliminarTratamiento(id) {
  await supabase.from("tratamientos").delete().eq("cod_tratamiento_cristal", id);
}

function editarTratamiento(tratamiento) {
  editId.value = tratamiento.cod_tratamiento_cristal;
  nombreTratamiento.value = tratamiento.nombre_tratamiento;
  showModal.value = true;
}

function abrirModalCrear() {
  editId.value = null;
  nombreTratamiento.value = "";
  showModal.value = true;
}

function subscribeToTratamientos() {
  const channel = supabase
    .channel("tratamientos")
    .on(
      "postgres_changes",
      { event: "*", schema: "public", table: "tratamientos" },
      (payload) => {
        if (payload.eventType === "INSERT") {
          tratamientos.value.push(payload.new);
        } else if (payload.eventType === "UPDATE") {
          tratamientos.value = tratamientos.value.map((t) =>
            t.cod_tratamiento_cristal === payload.new.cod_tratamiento_cristal ? payload.new : t
          );
        } else if (payload.eventType === "DELETE") {
          tratamientos.value = tratamientos.value.filter(
            (t) => t.cod_tratamiento_cristal !== payload.old.cod_tratamiento_cristal
          );
        }
      }
    )
    .subscribe();

  return () => supabase.removeChannel(channel);
}

onMounted(() => {
  getTratamientos();
  const unsubscribe = subscribeToTratamientos();
  onUnmounted(unsubscribe);
});
</script>



<style scoped>
table {
  width: 100%;
  max-width: 600px;
  border-collapse: collapse;
  margin: 1rem 0;
}

th, td {
  padding: 0.5rem;
  border: 1px solid #ddd;
  text-align: left;
}

th {
  background-color: #f5f5f5;
}

button {
  padding: 0.3rem 0.6rem;
  margin: 0 0.2rem;
  cursor: pointer;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal {
  background: white;
  padding: 1rem;
  border-radius: 5px;
  width: 300px;
}

input {
  width: 100%;
  padding: 0.5rem;
  margin-bottom: 1rem;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}
</style>