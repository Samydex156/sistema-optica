import { ref, readonly, computed } from 'vue';
import { supabase } from '../lib/supabaseClient.js';

// Estado reactivo para el usuario. Es null si nadie ha iniciado sesión.
const user = ref(null);

// Función para iniciar sesión
async function login(nombre_usuario, password) {
  const { data, error } = await supabase
    .from('usuarios')
    .select('*')
    .eq('nombre_usuario', nombre_usuario)
    .eq('password_usuario', password)
    .eq('activo', true)
    .single();

  if (error || !data) {
    user.value = null; // Aseguramos que el usuario es null si falla
    throw new Error('Usuario o contraseña incorrectos.');
  }

  // Si el login es exitoso, actualizamos el estado global
  user.value = data;
  return user.value;
}

// Función para cerrar sesión
function logout() {
  user.value = null;
}

// Exportamos las funciones y el estado para ser usados en otros componentes
export function useAuth() {
  return {
    user: readonly(user), // Se expone como readonly para evitar modificaciones accidentales
    isAuthenticated: computed(() => !!user.value), // Una propiedad computada para saber fácilmente si está autenticado
    login,
    logout,
  };
}