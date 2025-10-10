import { ref, computed } from 'vue';

// Estado reactivo que será compartido en toda la app
const isRunning = ref(false);
const startTime = ref(0);
const elapsedTime = ref(0);
let timerInterval = null;

/**
 * Formatea el tiempo transcurrido en un string MM:SS.
 */
const displayTime = computed(() => {
    const totalSeconds = Math.floor(elapsedTime.value / 1000);
    const minutes = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
    const seconds = (totalSeconds % 60).toString().padStart(2, '0');
    return `${minutes}:${seconds}`;
});

/**
 * Inicia o reanuda el cronómetro.
 */
function start() {
    if (isRunning.value) return;
    isRunning.value = true;
    // Si se reanuda, resta el tiempo ya transcurrido
    startTime.value = Date.now() - elapsedTime.value; 
    timerInterval = setInterval(() => {
        elapsedTime.value = Date.now() - startTime.value;
    }, 1000);
}

/**
 * Detiene (pausa) el cronómetro.
 */
function stop() {
    if (!isRunning.value) return;
    isRunning.value = false;
    clearInterval(timerInterval);
}

/**
 * Reinicia el cronómetro a cero.
 */
function reset() {
    stop();
    elapsedTime.value = 0;
}

/**
 * La función principal que usarán los componentes para acceder al estado y las funciones del cronómetro.
 */
export function useCronometro() {
    return {
        isRunning,
        displayTime,
        start,
        stop,
        reset,
        // Alterna entre iniciar y detener
        toggle: () => {
            if (isRunning.value) {
                stop();
            } else {
                start();
            }
        }
    };
}