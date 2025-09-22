import { createRouter, createWebHistory } from "vue-router";
import { useAuth } from "../composables/useAuth"; 

// Importar componentes
import RegistrarCliente from "../components/RegistrarCliente.vue";
import RegistrarOrdenTrabajo from "../components/RegistrarOrdenTrabajo.vue";
import RegistrarPrescripcion from "../components/RegistrarPrescripcion.vue";
import EjerciciosComputed from "../components/EjerciciosComputed.vue";
import RegistrarProducto from "../components/RegistrarProducto.vue";
import RegistrarUsuario from "../components/RegistrarUsuario.vue";
import GestionCaracteristicas from "../components/GestionCaracteristicas.vue";
import PanelCliente from "../components/PanelCliente.vue";
// 1. Importar el nuevo componente del panel principal
import PanelPrincipal from "../components/PanelPrincipal.vue";

// IMPORTAR EL NUEVO COMPONENTE
import GestionInventario from "../components/GestionInventario.vue";

// --- 1. IMPORTAR EL NUEVO COMPONENTE DE CONSULTA ---
import ConsultaStock from "../components/ConsultaStock.vue";

const routes = [
  {
    path: "/",
    // 2. Redirigir a la nueva página principal por defecto
    redirect: "/panel", 
  },
  {
    // 3. Añadir la nueva ruta para el panel
    path: "/panel",
    name: "PanelPrincipal",
    component: PanelPrincipal,
    meta: { requiresAuth: true },
  },
  {
    path: "/login",
    name: "Login",
    component: RegistrarUsuario,
    meta: { requiresAuth: false },
  },
  {
    path: "/clientes",
    name: 'GestionClientes',
    component: RegistrarCliente,
    meta: { requiresAuth: true },
  },
  {
    path: "/cliente/:id",
    name: "PanelCliente",
    component: PanelCliente,
    props: true,
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
    {
    path: "/productos/caracteristicas",
    component: GestionCaracteristicas,
    meta: { requiresAuth: true },
  },
  // --- AÑADIR LA NUEVA RUTA DE INVENTARIO ---
  {
    path: "/inventario",
    name: "GestionInventario",
    component: GestionInventario,
    meta: { requiresAuth: true },
  },
  {
    path: "/practicas",
    component: EjerciciosComputed,
    meta: { requiresAuth: true },
  },
    // --- 2. AÑADIR LA NUEVA RUTA DE CONSULTA DE STOCK ---
  {
    path: "/stock",
    name: "ConsultaStock",
    component: ConsultaStock,
    meta: { requiresAuth: true },
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Guardia de navegación GLOBAL
router.beforeEach((to, from, next) => {
  const { isAuthenticated } = useAuth();
  const requiresAuth = to.meta.requiresAuth;

  // Si la ruta requiere autenticación y el usuario NO está logueado,
  // lo redirigimos a la página de login.
  if (requiresAuth && !isAuthenticated.value) {
    next("/login");
  }
  // Si el usuario está logueado e intenta acceder a /login, lo redirigimos
  // a la página principal (el nuevo panel).
  else if (!requiresAuth && isAuthenticated.value && to.path === "/login") {
    // 4. Cambiar la redirección al panel
    next("/panel");
  }
  // En cualquier otro caso, permitimos la navegación.
  else {
    next();
  }
});

export default router;
