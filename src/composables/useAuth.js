import { ref, readonly, computed } from 'vue';
import { supabase } from '../lib/supabaseClient.js';

// Estado reactivo para el usuario.
const user = ref(null);

// Función interna para guardar el usuario en localStorage
function saveUser(userData) {
  if (userData) {
    localStorage.setItem('user', JSON.stringify(userData));
  } else {
    localStorage.removeItem('user');
  }
}

// Función interna para cargar el usuario desde localStorage
function loadUser() {
  const storedUser = localStorage.getItem('user');
  if (storedUser) {
    try {
      user.value = JSON.parse(storedUser);
    } catch (e) {
      console.error('Error al parsear el usuario del localStorage:', e);
      user.value = null;
      localStorage.removeItem('user');
    }
  }
}

// Cargar el usuario al iniciar la aplicación.
loadUser();

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
    user.value = null;
    saveUser(null); // Borra el usuario del localStorage si falla
    throw new Error('Usuario o contraseña incorrectos.');
  }

  user.value = data;
  saveUser(data); // Guarda el usuario en localStorage
  return user.value;
}

// Función para cerrar sesión
function logout() {
  user.value = null;
  saveUser(null); // Borra el usuario del localStorage
}

// Exportamos las funciones y el estado para ser usados en otros componentes
export function useAuth() {
  return {
    user: readonly(user),
    isAuthenticated: computed(() => !!user.value),
    login,
    logout,
  };
}