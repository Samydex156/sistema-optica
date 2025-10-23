<template>
  <v-container fluid class="fill-height" style="background-color: #f0f2f5;">
    <v-row justify="center" align="center">
      <v-col cols="12" sm="10" md="6" lg="4">
        <v-card class="pa-4" elevation="8" rounded="lg">
          
          <v-card-title class="text-center text-h4 font-weight-bold" style="color: #eb2525;">
            Óptica Optalvis
          </v-card-title>
          <v-card-subtitle class="text-center text-h6 mb-6">
            Bienvenido al sistema
          </v-card-subtitle>

          <v-card-text>
            <v-form @submit.prevent="iniciarSesion" ref="form">
              
              <v-alert
                v-if="mensaje"
                :type="esError ? 'error' : 'success'"
                variant="tonal"
                density="compact"
                class="mb-4"
                closable
                @click:close="mensaje = ''"
              >
                {{ mensaje }}
              </v-alert>

              <v-text-field
                v-model="loginData.nombre_usuario"
                label="Nombre de usuario"
                prepend-inner-icon="mdi-account"
                variant="outlined"
                required
                ref="nameUsuario"
                :rules="[v => !!v || 'El nombre de usuario es requerido']"
                autocomplete="username"
              ></v-text-field>

              <v-text-field
                v-model="loginData.password"
                label="Contraseña"
                prepend-inner-icon="mdi-lock"
                :type="passwordVisible ? 'text' : 'password'"
                :append-inner-icon="passwordVisible ? 'mdi-eye-off' : 'mdi-eye'"
                @click:append-inner="togglePasswordVisibility"
                variant="outlined"
                required
                :rules="[v => !!v || 'La contraseña es requerida']"
                class="mt-2"
                autocomplete="current-password"
              ></v-text-field>

              <v-btn
                type="submit"
                block
                color="#eb2525"
                class="mt-6 text-white"
                size="large"
                :loading="loading"
              >
                Entrar
              </v-btn>
            </v-form>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref, onMounted, nextTick } from "vue";
import { useRouter } from 'vue-router';
import { useAuth } from '../composables/useAuth';

const { login } = useAuth();
const router = useRouter();

// Refs para el formulario y su estado
const form = ref(null); // Ref para el v-form
const loading = ref(false); // Estado de carga para el botón
const mensaje = ref("");
const esError = ref(false);
const passwordVisible = ref(false);
const nameUsuario = ref(null); // Ref para el v-text-field de usuario

const loginData = ref({
  nombre_usuario: "",
  password: ""
});

async function iniciarSesion() {
  // 1. Validar el formulario de Vuetify
  const { valid } = await form.value.validate();
  if (!valid) return;

  // 2. Iniciar estado de carga y limpiar mensajes
  loading.value = true;
  mensaje.value = "";
  esError.value = false;

  try {
    // 3. Intentar iniciar sesión
    const usuario = await login(loginData.value.nombre_usuario, loginData.value.password);
    mostrarMensaje(`Bienvenido, ${usuario.nombre_usuario}`, false);
    // Redirige al panel principal
    router.push('/panel');
  } catch (error) {
    // 4. Mostrar error
    mostrarMensaje(error.message, true);
  } finally {
    // 5. Detener estado de carga
    loading.value = false;
  }
}

function mostrarMensaje(texto, esUnError = false) {
  mensaje.value = texto;
  esError.value = esUnError;
}

function togglePasswordVisibility() {
  passwordVisible.value = !passwordVisible.value;
}

onMounted(() => {
  // Enfocar el primer campo (v-text-field) al montar
  nextTick(() => {
    if (nameUsuario.value) {
      nameUsuario.value.focus();
    }
  });
});
</script>