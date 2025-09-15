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
        <div class="password-container">
          <input v-model="loginData.password" placeholder="Contraseña" :type="passwordVisible ? 'text' : 'password'" required />
          <span class="password-toggle-icon" @click="togglePasswordVisibility">
            {{ passwordVisible ? '🙈' : '👁️' }}
          </span>
        </div>
        <button type="submit">Entrar</button>
      </form>

      <!-- Formulario de Registro -->
      <form v-if="!modoLogin" class="auth-form" @submit.prevent="registrarUsuario">
        <h3>Crear una Cuenta</h3>
        <input v-model="registerData.nombre_usuario" placeholder="Nombre de usuario" type="text" ref="nameUsuario"
          required />
        <input v-model="registerData.email_usuario" placeholder="Email" type="email" required />
        <div class="password-container">
          <input v-model="registerData.password_usuario" placeholder="Contraseña" :type="passwordVisible ? 'text' : 'password'" required />
           <span class="password-toggle-icon" @click="togglePasswordVisibility">
            {{ passwordVisible ? '🙈' : '👁️' }}
          </span>
        </div>
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

const { login } = useAuth();
const router = useRouter();

const modoLogin = ref(true);
const mensaje = ref("");
const esError = ref(false);
const passwordVisible = ref(false);

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

const roles = ref([]);
const tiendas = ref([]);
const nameUsuario = ref(null);

async function iniciarSesion() {
  try {
    const usuario = await login(loginData.value.nombre_usuario, loginData.value.password);
    mostrarMensaje(`Bienvenido, ${usuario.nombre_usuario}`, false);
    // Redirige al panel principal tras un login exitoso.
    router.push('/panel'); // <-- ¡CAMBIO IMPORTANTE AQUÍ!
  } catch (error) {
    mostrarMensaje(error.message, true);
  }
}

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
        password_usuario: registerData.value.password_usuario,
        rol_usuario: parseInt(registerData.value.rol_usuario),
        tienda_usuario: registerData.value.tienda_usuario ? parseInt(registerData.value.tienda_usuario) : null
      });

    if (error) {
      throw error;
    }

    mostrarMensaje("Usuario registrado con éxito. Ahora puedes iniciar sesión.", false);
    limpiarFormularioRegistro();
    modoLogin.value = true;
  } catch (error) {
    mostrarMensaje(`Error al registrar: ${error.message}`, true);
  }
}

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

function togglePasswordVisibility() {
  passwordVisible.value = !passwordVisible.value;
}

function cambiarModo(esLogin) {
  modoLogin.value = esLogin;
  passwordVisible.value = false;
  nextTick(() => {
    nameUsuario.value?.focus();
  });
}

onMounted(async () => {
  nextTick(() => {
    nameUsuario.value?.focus();
  });

  await cargarRoles();
  await cargarTiendas();
});
</script>

<style scoped>
/* Los estilos se mantienen igual que en tu archivo original */
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
  box-sizing: border-box;
}

.password-container {
  position: relative;
  display: flex;
  align-items: center;
}

.password-container input {
  padding-right: 2.5rem;
}

.password-toggle-icon {
  position: absolute;
  right: 0.8rem;
  cursor: pointer;
  user-select: none;
  color: #888;
}

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
