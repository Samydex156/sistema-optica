<template>
  <div class="modal-backdrop" @click.self="$emit('close')">
    <div class="modal-content">
      <header class="modal-header">
        <h2>Calculadora</h2>
        <button class="close-btn" @click="$emit('close')">&times;</button>
      </header>
      <section class="modal-body">
        <Calculator />
      </section>
    </div>
  </div>
</template>

<script setup>
import Calculator from './Calculator.vue';

// Define el evento que el componente puede emitir.
defineEmits(['close']);
</script>

<style scoped>
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2000; /* Asegura que esté por encima de todo */
}

.modal-content {
  background-color: white;
  border-radius: 1rem;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
  width: auto;
  max-width: 500px;
  /* El contenido determinará la altura */
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #eee;
  color: #70718d;
}

.modal-header h2 {
    margin: 0;
}

.close-btn {
  border: none;
  background: none;
  font-size: 2rem;
  font-weight: bold;
  cursor: pointer;
  color: #aaa;
}
.close-btn:hover {
    color: #333;
}

.modal-body {
  padding: 1.5rem;
}
</style>