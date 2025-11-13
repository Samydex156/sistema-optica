<template>
  <v-dialog
    :model-value="modelValue"
    @update:model-value="$emit('update:modelValue', $event)"
    persistent
    max-width="370px"
  >
    <v-card>
      <v-toolbar density="compact" color="blue-grey-darken-1">
        <v-toolbar-title>Calculadora</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn 
          icon="mdi-close" 
          @click="$emit('update:modelValue', false)"
        ></v-btn>
      </v-toolbar>

      <Calculator ref="calculatorComponentRef" />

    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, watch, nextTick } from 'vue';
import Calculator from './Calculator.vue';

// 1. Definimos las props y emits para el v-model
// El padre (App.vue) pasa 'modelValue' (true/false)
const props = defineProps({
  modelValue: Boolean
});
// El hijo emite 'update:modelValue' para cambiar el estado en el padre
const emit = defineEmits(['update:modelValue']);

// 2. Ref para el componente Calculator
const calculatorComponentRef = ref(null);

// 3. Lógica de Foco (MUY IMPORTANTE)
// Observamos cuando el 'modelValue' (nuestro prop) cambia.
watch(() => props.modelValue, async (newValue) => {
  // Cuando el diálogo se abre (newValue es true)
  if (newValue) {
    // Esperamos a que Vue actualice el DOM
    await nextTick();
    // Llamamos al método 'focus' que expondremos en Calculator.vue
    if (calculatorComponentRef.value) {
      calculatorComponentRef.value.focus();
    }
  }
});
</script>