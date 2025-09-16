<template>
  <div class="multiselect-container" ref="containerRef">
    <div class="multiselect-display" @click="toggleDropdown">
      <span v-if="modelValue.length === 0" class="placeholder">{{ placeholder }}</span>
      <div v-else class="tags-container">
        <span v-for="value in modelValue" :key="value" class="tag">
          {{ getLabel(value) }}
          <button @click.stop="removeOption(value)" class="remove-tag">&times;</button>
        </span>
      </div>
      <span class="arrow" :class="{ 'open': isOpen }">▼</span>
    </div>
    <div v-if="isOpen" class="multiselect-dropdown">
      <div
        v-for="option in options"
        :key="option.value"
        class="dropdown-option"
        :class="{ 'selected': isSelected(option.value) }"
        @click="toggleOption(option.value)"
      >
        {{ option.label }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { onClickOutside } from '@vueuse/core';

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  },
  options: {
    type: Array,
    required: true,
    default: () => [] // Debería ser un array de { value, label }
  },
  placeholder: {
    type: String,
    default: 'Seleccionar opciones'
  }
});

const emit = defineEmits(['update:modelValue']);

const isOpen = ref(false);
const containerRef = ref(null);

onClickOutside(containerRef, () => isOpen.value = false);

const toggleDropdown = () => {
  isOpen.value = !isOpen.value;
};

const isSelected = (optionValue) => {
  return props.modelValue.includes(optionValue);
};

const toggleOption = (optionValue) => {
  const newModelValue = [...props.modelValue];
  const index = newModelValue.indexOf(optionValue);
  if (index > -1) {
    newModelValue.splice(index, 1); // Deseleccionar
  } else {
    newModelValue.push(optionValue); // Seleccionar
  }
  emit('update:modelValue', newModelValue);
};

const removeOption = (optionValue) => {
  const newModelValue = props.modelValue.filter(v => v !== optionValue);
  emit('update:modelValue', newModelValue);
};

const getLabel = (value) => {
  const option = props.options.find(opt => opt.value === value);
  return option ? option.label : value;
};
</script>

<style scoped>
.multiselect-container {
  position: relative;
  width: 100%;
}
.multiselect-display {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  cursor: pointer;
  background-color: white;
  min-height: 38px;
}
.placeholder {
  color: #6c757d;
}
.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
}
.tag {
  display: inline-flex;
  align-items: center;
  background-color: #007bff;
  color: white;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
}
.remove-tag {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  margin-left: 5px;
  padding: 0;
  font-size: 14px;
  font-weight: bold;
}
.arrow {
  font-size: 12px;
  transition: transform 0.2s ease;
}
.arrow.open {
  transform: rotate(180deg);
}
.multiselect-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background-color: white;
  border: 1px solid #ced4da;
  border-top: none;
  border-radius: 0 0 4px 4px;
  max-height: 200px;
  overflow-y: auto;
  z-index: 1000;
}
.dropdown-option {
  padding: 8px 12px;
  cursor: pointer;
}
.dropdown-option:hover {
  background-color: #f8f9fa;
}
.dropdown-option.selected {
  background-color: #e9ecef;
  font-weight: bold;
}
</style>