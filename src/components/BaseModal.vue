<template>
  <Transition name="modal-fade">
    <div v-if="modelValue" class="modal-overlay" @mousedown="$emit('update:modelValue', false)">
      <div class="modal-container" :class="`modal-${size}`" @mousedown.stop>
        
        <header class="modal-header">
          <slot name="header">
            <h3 class="modal-title">{{ title }}</h3>
          </slot>
          <button class="modal-close-btn" @click="$emit('update:modelValue', false)">
            &times;
          </button>
        </header>

        <main class="modal-body">
          <slot></slot>
        </main>

        <footer v-if="$slots.footer" class="modal-footer">
          <slot name="footer"></slot>
        </footer>

      </div>
    </div>
  </Transition>
</template>

<script setup>
defineProps({
  modelValue: {
    type: Boolean,
    required: true,
  },
  title: {
    type: String,
    default: "Ventana Modal",
  },
  size: {
    type: String,
    default: 'md', // sm, md, lg
  }
});

defineEmits(['update:modelValue']);
</script>

<style scoped>
/* Transiciones para la aparición del modal */
.modal-fade-enter-active, .modal-fade-leave-active {
  transition: opacity 0.3s ease;
}
.modal-fade-enter-from, .modal-fade-leave-to {
  opacity: 0;
}
.modal-fade-enter-active .modal-container,
.modal-fade-leave-active .modal-container {
  transition: transform 0.3s ease;
}
.modal-fade-enter-from .modal-container,
.modal-fade-leave-to .modal-container {
  transform: translateY(-20px);
}

/* Contenedor principal del modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-container {
  background-color: #ffffff;
  border-radius: 8px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  max-height: 90vh;
  width: 95%;
}

/* Tamaños del Modal */
.modal-md { max-width: 600px; }
.modal-lg { max-width: 1000px; }

/* Cabecera */
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  border-bottom: 1px solid #e0e0e0;
}

.modal-title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
  color: #333;
}

.modal-close-btn {
  background: none;
  border: none;
  font-size: 2rem;
  line-height: 1;
  color: #888;
  cursor: pointer;
  padding: 0;
  transition: color 0.2s ease;
}
.modal-close-btn:hover {
  color: #000;
}

/* Cuerpo */
.modal-body {
  padding: 24px;
  overflow-y: auto;
}

/* Pie de página */
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 24px;
  background-color: #f8f9fa;
  border-top: 1px solid #e0e0e0;
  border-bottom-left-radius: 8px;
  border-bottom-right-radius: 8px;
}
</style>