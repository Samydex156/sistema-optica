<template>
  <div class="auth-page-container">
    <div class="auth-container">
      <div class="auth-brand">
        <h1>Óptica Optalvis</h1>
        <p>Bienvenido al sistema</p>
      </div>

      <div class="auth-toggle">
        <button @click="cambiarModo(true)" :class="{ active: modoLogin }">
          Iniciar Sesión
        </button>
        <button @click="cambiarModo(false)" :class="{ active: !modoLogin }">
          Registrarse
        </button>
      </div>

      <!-- Formulario de Login -->
      <form v-if="modoLogin" class="auth-form" @submit.prevent="iniciarSesion">
        <h3>Iniciar Sesión</h3>
        <input v-model="loginData.nombre_usuario" placeholder="Nombre de usuario" type="text" ref="nameUsuario"
          required />
        <!-- INICIO: Campo de contraseña modificado -->
        <div class="password-container">
          <input v-model="loginData.password" placeholder="Contraseña" :type="passwordVisible ? 'text' : 'password'" required />
          <span class="password-toggle-icon" @click="togglePasswordVisibility">
            {{ passwordVisible ? '🙈' : '👁️' }}
          </span>
        </div>
        <!-- FIN: Campo de contraseña modificado -->
        <button type="submit">Entrar</button>
      </form>

      <!-- Formulario de Registro -->
      <form v-if="!modoLogin" class="auth-form" @submit.prevent="registrarUsuario">
        <h3>Crear una Cuenta</h3>
        <input v-model="registerData.nombre_usuario" placeholder="Nombre de usuario" type="text" ref="nameUsuario"
          required />
        <input v-model="registerData.email_usuario" placeholder="Email" type="email" required />
        <!-- INICIO: Campo de contraseña modificado -->
        <div class="password-container">
          <input v-model="registerData.password_usuario" placeholder="Contraseña" :type="passwordVisible ? 'text' : 'password'" required />
           <span class="password-toggle-icon" @click="togglePasswordVisibility">
            {{ passwordVisible ? '🙈' : '👁️' }}
          </span>
        </div>
        <!-- FIN: Campo de contraseña modificado -->
        <select v-model="registerData.rol_usuario" required>
          <option disabled value="">Seleccionar rol</option>
          <option v-for="rol in roles" :key="rol.cod_rol" :value="rol.cod_rol">
            {{ rol.nombre_rol }}
          </option>
        </select>
        <select v-model="registerData.tienda_usuario">
          <option value="">Seleccionar tienda (opcional)</option>
          <option v-for="tienda in tiendas" :key="tienda.cod_tienda" :value="tienda.cod_tienda">
            {{ tienda.nombre_tienda }}
          </option>
        </select>
        <button type="submit">Registrar</button>
      </form>

      <div v-if="mensaje" class="mensaje" :class="{ error: esError }">
        {{ mensaje }}
      </div>
    </div>
  </div>
</template>

<script setup>

import { ref, onMounted, nextTick } from "vue";
import { useRouter } from 'vue-router';
import { useAuth } from '../composables/useAuth';
import { supabase } from "../lib/supabaseClient.js";

// Lógica de autenticación y enrutamiento
const { login } = useAuth();
const router = useRouter();

// Estados del componente
const modoLogin = ref(true);
const mensaje = ref("");
const esError = ref(false);
const passwordVisible = ref(false); // --- NUEVO: Estado para visibilidad de contraseña

// Datos de los formularios
const loginData = ref({
  nombre_usuario: "",
  password: ""
});

const registerData = ref({
  nombre_usuario: "",
  email_usuario: "",
  password_usuario: "",
  rol_usuario: "",
  tienda_usuario: ""
});

// Datos para los selects del formulario de registro
const roles = ref([]);
const tiendas = ref([]);

// para inicializar el focus
const nameUsuario = ref(null);

/**
 * Inicia sesión usando la función del composable de autenticación.
 */
async function iniciarSesion() {
  try {

    const usuario = await login(loginData.value.nombre_usuario, loginData.value.password);
    mostrarMensaje(`Bienvenido, ${usuario.nombre_usuario}`, false);
    // Redirige al dashboard o página principal tras un login exitoso.
    router.push('/clientes');
  } catch (error) {
    mostrarMensaje(error.message, true);
  }

}

/**
 * Registra un nuevo usuario en la base de datos.
 */
async function registrarUsuario() {

  if (!registerData.value.password_usuario) {
    mostrarMensaje("La contraseña es obligatoria.", true);
    return;
  }
  try {

    const { error } = await supabase
      .from("usuarios")
      .insert({
        nombre_usuario: registerData.value.nombre_usuario,
        email_usuario: registerData.value.email_usuario,
        password_usuario: registerData.value.password_usuario, // En un proyecto real, esto debería estar hasheado.
        rol_usuario: parseInt(registerData.value.rol_usuario),
        tienda_usuario: registerData.value.tienda_usuario ? parseInt(registerData.value.tienda_usuario) : null
      });

    if (error) {
      throw error;
    }

    mostrarMensaje("Usuario registrado con éxito. Ahora puedes iniciar sesión.", false);
    limpiarFormularioRegistro();
    modoLogin.value = true; // Cambia a la vista de login
  } catch (error) {
    mostrarMensaje(`Error al registrar: ${error.message}`, true);
  }
}

// --- Funciones Auxiliares ---

async function cargarRoles() {
  const { data } = await supabase.from("roles").select("*");
  roles.value = data || [];
}

async function cargarTiendas() {
  const { data } = await supabase.from("tiendas").select("*");
  tiendas.value = data || [];
}

function mostrarMensaje(texto, esUnError = false) {
  mensaje.value = texto;
  esError.value = esUnError;
  setTimeout(() => {
    mensaje.value = "";
  }, 4000);
}

function limpiarFormularioRegistro() {
  registerData.value = {
    nombre_usuario: "",
    email_usuario: "",
    password_usuario: "",
    rol_usuario: "",
    tienda_usuario: ""
  };
}

// --- NUEVO: Función para cambiar la visibilidad de la contraseña ---
function togglePasswordVisibility() {
  passwordVisible.value = !passwordVisible.value;
}

// --- NUEVO: Función para cambiar entre Login/Registro y hacer focus ---
function cambiarModo(esLogin) {
  modoLogin.value = esLogin;
  passwordVisible.value = false; // Resetea la visibilidad al cambiar
  nextTick(() => {
    nameUsuario.value?.focus();
  });
}

// Carga los datos necesarios al montar el componente
onMounted(async () => {
  nextTick(() => {
    nameUsuario.value?.focus();
  });

  await cargarRoles();
  await cargarTiendas();
});
</script>

<style scoped>
.auth-page-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f0f2f5;
}

.auth-container {
  max-width: 400px;
  width: 100%;
  padding: 2.5rem;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.auth-brand h1 {
  color: #eb2525;
  margin-bottom: 0.5rem;
}

.auth-brand p {
  color: #666;
  margin-bottom: 2rem;
}

.auth-toggle {
  display: flex;
  margin-bottom: 1.5rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  overflow: hidden;
}

.auth-toggle button {
  flex: 1;
  padding: 0.75rem;
  border: none;
  background: #f5f5f5;
  cursor: pointer;
  font-size: 1rem;
  color: #555;
  transition: background 0.3s, color 0.3s;
}

.auth-toggle button.active {
  background: #eb2525;
  color: white;
  font-weight: bold;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.auth-form h3 {
  margin-bottom: 0.5rem;
  color: #333;
}

.auth-form input,
.auth-form select {
  padding: 0.8rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  width: 100%;
  box-sizing: border-box; /* Asegura que el padding no afecte el ancho total */
}

/* --- INICIO: NUEVOS ESTILOS PARA EL CAMPO DE CONTRASEÑA --- */
.password-container {
  position: relative;
  display: flex;
  align-items: center;
}

.password-container input {
  padding-right: 2.5rem; /* Espacio para el ícono */
}

.password-toggle-icon {
  position: absolute;
  right: 0.8rem;
  cursor: pointer;
  user-select: none; /* Evita que el texto del ícono se seleccione */
  color: #888;
}
/* --- FIN: NUEVOS ESTILOS --- */


.auth-form button {
  padding: 0.8rem;
  background: #eb2525;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1.1rem;
  font-weight: bold;
  transition: background-color 0.3s;
}

.auth-form button:hover {
  background-color: #c81e1e;
}

.mensaje {
  margin-top: 1.5rem;
  padding: 0.75rem;
  border-radius: 4px;
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.mensaje.error {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}
</style>
