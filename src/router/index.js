import { createRouter, createWebHistory } from "vue-router";
import { useAuth } from "../composables/useAuth";

// Importar componentes Principales
import RegistrarUsuario from "../components/RegistrarUsuario.vue";
import PanelPrincipal from "../components/PanelPrincipal.vue";

// Importar componentes de cliente
import RegistrarCliente from "../components/RegistrarCliente.vue";
import PanelCliente from "../components/PanelCliente.vue";

// Importar componente de RegistrarPrescripción
import RegistrarPrescripcion from "../components/RegistrarPrescripcion.vue"; 

// Importar componente de Registrar orden de trabajo
import RegistrarOrdenTrabajo from "../components/RegistrarOrdenTrabajo.vue";

// Importar componentes para inventarios
import GestionCaracteristicas from "../components/GestionCaracteristicas.vue";
import RegistrarProducto from "../components/RegistrarProducto.vue";
import GestionInventario from "../components/GestionInventario.vue";
import ConsultaStock from "../components/ConsultaStock.vue";

// Importar componente de Ejercicios básicos
import EjerciciosComputed from "../components/EjerciciosComputed.vue";

// Importar el nuevo componente de la Landing Page
import LandingPage from "../components/LandingPage.vue";

const routes = [
  {
    // Redirije al panel principal por defecto
    path: "/",
    redirect: "/panel",
  },
  {
    // Redirije al panel principal
    path: "/panel",
    name: "PanelPrincipal",
    component: PanelPrincipal,
    meta: { requiresAuth: true },
  },
  {
    // redirige al login para iniciar sesion
    path: "/login",
    name: "Login",
    component: RegistrarUsuario,
    meta: { requiresAuth: false },
  },
  // Nueva ruta para la Landing Page
  {
    path: "/landing",
    name: "LandingPage",
    component: LandingPage,
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
  // **** NUEVAS RUTAS PARA CREAR Y EDITAR PRESCRIPCIONES ****
  {
    path: '/cliente/:clienteId/prescripcion/nueva',
    name: 'CrearPrescripcion',
    component: RegistrarPrescripcion,
    props: true, // Pasa los params de la ruta como props al componente
    meta: { requiresAuth: true },
  },
  {
    path: '/cliente/:clienteId/prescripcion/:prescripcionId/editar',
    name: 'EditarPrescripcion',
    component: RegistrarPrescripcion,
    props: true, // Pasa los params de la ruta como props
    meta: { requiresAuth: true },
  },
  {
    path: "/ordenes",
    component: RegistrarOrdenTrabajo,
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
  {
    path: "/inventario",
    name: "GestionInventario",
    component: GestionInventario,
    meta: { requiresAuth: true },
  },
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

// Validar si el usuario se encuentra logueado o no
router.beforeEach((to, from, next) => {
  const { isAuthenticated } = useAuth();
  const requiresAuth = to.meta.requiresAuth;

  // Si la ruta requiere autenticación y el usuario NO está logueado,
  // lo redirigimos a la página de login.
  if (requiresAuth && !isAuthenticated.value) {
    next("/login");
  }
  // Si el usuario está logueado e intenta acceder a /login, lo redirigimos
  // al panel principal
  else if (!requiresAuth && isAuthenticated.value && to.path === "/login") {
    next("/panel");
  }
  // En cualquier otro caso, permitimos la navegación.
  else {
    next();
  }
});

export default router;