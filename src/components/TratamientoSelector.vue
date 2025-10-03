<template>
  <div class="selector-container">
    <div class="selector-display" @click="openModal">
      <span v-if="modelValue.length === 0" class="placeholder">{{ placeholder }}</span>
      <div v-else class="tags-container">
        <span v-for="value in modelValue" :key="value" class="tag">
          {{ getLabel(value) }}
          <button @click.stop="removeOption(value)" class="remove-tag">&times;</button>
        </span>
      </div>
      <span class="arrow">▦</span>
    </div>

    <BaseModal v-model="isModalOpen" title="Seleccionar Tratamientos" size="md">
      <div class="tratamientos-grid">
        <label v-for="option in options" :key="option.value" class="grid-item">
          <input
            type="checkbox"
            :checked="tempSelected.includes(option.value)"
            @change="toggleSelection(option.value)"
          />
          <span>{{ option.label }}</span>
        </label>
      </div>

      <template #footer>
        <button type="button" @click="cancel" class="btn-cancelar-modal">Cancelar</button>
        <button type="button" @click="confirmSelection" class="btn-aceptar-modal">Aceptar</button>
      </template>
    </BaseModal>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import BaseModal from './BaseModal.vue'; // Asegúrate que la ruta es correcta

const props = defineProps({
  modelValue: { // v-model
    type: Array,
    default: () => []
  },
  options: { // La lista de { value, label } de todos los tratamientos
    type: Array,
    required: true,
  },
  placeholder: {
    type: String,
    default: 'Seleccionar...'
  }
});

const emit = defineEmits(['update:modelValue']);

const isModalOpen = ref(false);
// Usamos una selección temporal para no modificar la original hasta confirmar
const tempSelected = ref([]);

const openModal = () => {
  // Copiamos el valor actual a la selección temporal al abrir el modal
  tempSelected.value = [...props.modelValue];
  isModalOpen.value = true;
};

const toggleSelection = (optionValue) => {
  const index = tempSelected.value.indexOf(optionValue);
  if (index > -1) {
    tempSelected.value.splice(index, 1); // Desmarcar
  } else {
    tempSelected.value.push(optionValue); // Marcar
  }
};

const confirmSelection = () => {
  // Al confirmar, emitimos el evento para actualizar el v-model en el padre
  emit('update:modelValue', tempSelected.value);
  isModalOpen.value = false;
};

const cancel = () => {
  // Simplemente cerramos el modal, los cambios en tempSelected se descartan
  isModalOpen.value = false;
};

const removeOption = (optionValue) => {
  const newValue = props.modelValue.filter(v => v !== optionValue);
  emit('update:modelValue', newValue);
};

const getLabel = (value) => {
  const option = props.options.find(opt => opt.value === value);
  return option ? option.label : value;
};
</script>

<style scoped>
/* Estilos para el campo visible (puedes ajustar o copiar de MultiSelect.vue) */
.selector-container { position: relative; width: 100%; font-size: .8rem; }
.selector-display { display: flex; align-items: center; justify-content: space-between; padding: 6px 12px; border: 1px solid #ced4da; border-radius: 4px; cursor: pointer; background-color: white; min-height: 32px; box-sizing: border-box; }
.placeholder { color: #6c757d; }
.tags-container { display: flex; flex-wrap: wrap; gap: 5px; }
.tag { display: inline-flex; align-items: center; background-color: #007bff; color: white; padding: 2px 8px; border-radius: 12px; font-size: .8rem; }
.remove-tag { background: none; border: none; color: white; cursor: pointer; margin-left: 5px; padding: 0; font-size: 16px; font-weight: bold; }
.arrow { font-size: 1.2rem; color: #6c757d; }

/* Estilos para la cuadrícula dentro del modal */
.tratamientos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 12px;
}
.grid-item {
  display: flex;
  align-items: center;
  padding: 8px;
  border-radius: 4px;
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  cursor: pointer;
  transition: background-color 0.2s, border-color 0.2s;
}
.grid-item:hover {
  background-color: #d6d6d6;
}
.grid-item input[type="checkbox"] {
  margin-right: 10px;
  width: 16px;
  height: 16px;
}

/* Estilos para los botones del modal */
.btn-aceptar-modal, .btn-cancelar-modal { color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px; }
.btn-aceptar-modal { background: #007bff; }
.btn-aceptar-modal:hover { background: #0056b3; }
.btn-cancelar-modal { background: #6c757d; }
.btn-cancelar-modal:hover { background: #5a6268; }
</style>