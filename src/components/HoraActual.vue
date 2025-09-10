<template>
  <div class="time-banner">
    <p>{{ currentTime }}</p>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';

const currentTime = ref('');

let timer = null;

const updateTime = () => {
  const now = new Date();
  currentTime.value = now.toLocaleTimeString();
};

onMounted(() => {
  updateTime();
  timer = setInterval(updateTime, 1000);
});

onUnmounted(() => {
  clearInterval(timer);
});
</script>

<style scoped>
.time-banner {

  width: 100%;
  background-color: #333;
  color: white;
  text-align: right;
  padding: 10px;
  z-index: 1000;
  font-family: sans-serif;
}

.time-banner p {
  margin: 0;
  font-size: 1.2rem;
}
</style>