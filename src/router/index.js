import { createRouter, createWebHistory } from "vue-router";
import { useAuth } from "../composables/useAuth"; // 1. Importar el composable

import RegistrarCliente from "../components/RegistrarCliente.vue";
import RegistrarOrdenTrabajo from "../components/RegistrarOrdenTrabajo.vue";
import RegistrarPrescripcion from "../components/RegistrarPrescripcion.vue";
import EjerciciosComputed from "../components/EjerciciosComputed.vue";
import RegistrarProducto from "../components/RegistrarProducto.vue";
import RegistrarUsuario from "../components/RegistrarUsuario.vue";
import GestionCaracteristicas from "../components/GestionCaracteristicas.vue";
import PanelCliente from "../components/PanelCliente.vue";

const routes = [
  {
    path: "/",
    redirect: "/clientes", // Redirige a una página interna por defecto si ya estás logueado
  },
  {
    path: "/login",
    name: "Login",
    component: RegistrarUsuario,
    meta: { requiresAuth: false }, // 2. Esta ruta NO requiere autenticación
  },
  {
    path: "/clientes",
    name: 'GestionClientes',
    component: RegistrarCliente,
    meta: { requiresAuth: true }, // 3. Esta y las siguientes SÍ requieren autenticación
  },
  {
    path: "/cliente/:id", // <-- Esta es la nueva ruta dinámica
    name: "PanelCliente",
    component: PanelCliente,
    props: true, // <-- Esto pasa los params de la ruta (como :id) como props al componente
  },
  {
    path: "/ordenes",
    component: RegistrarOrdenTrabajo,
    meta: { requiresAuth: true },
  },
  {
    path: "/prescripciones/registrar",
    component: RegistrarPrescripcion,
    meta: { requiresAuth: true },
  },
  {
    path: "/productos/registrar",
    component: RegistrarProducto,
    meta: { requiresAuth: true },
  },
  {
    path: "/productos/caracteristicas",
    component: GestionCaracteristicas,
    meta: { requiresAuth: true },
  },

  {
    path: "/practicas",
    component: EjerciciosComputed,
    meta: { requiresAuth: true },
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// 4. Guardia de navegación GLOBAL
router.beforeEach((to, from, next) => {
  const { isAuthenticated } = useAuth();
  const requiresAuth = to.meta.requiresAuth;

  // Si la ruta requiere autenticación y el usuario NO está logueado,
  // lo redirigimos a la página de login.
  if (requiresAuth && !isAuthenticated.value) {
    next("/login");
  }
  // Si el usuario está logueado e intenta acceder a /login, lo redirigimos
  // a la página principal.
  else if (!requiresAuth && isAuthenticated.value && to.path === "/login") {
    next("/clientes");
  }
  // En cualquier otro caso, permitimos la navegación.
  else {
    next();
  }
});

export default router;
