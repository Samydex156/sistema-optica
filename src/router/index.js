import { createRouter, createWebHistory } from "vue-router";
import { useAuth } from "../composables/useAuth";

import RegistrarUsuario from "../components/RegistrarUsuario.vue";
import PanelPrincipal from "../components/PanelPrincipal.vue";
import RegistrarCliente from "../components/RegistrarCliente.vue";
import PanelCliente from "../components/PanelCliente.vue";
import RegistrarPrescripcion from "../components/RegistrarPrescripcion.vue";
import GestionOrdenesTrabajo from "../components/GestionOrdenesTrabajo.vue";
import GestionCaracteristicas from "../components/GestionCaracteristicas.vue";
import RegistrarProducto from "../components/RegistrarProducto.vue";
import GestionInventario from "../components/GestionInventario.vue";
import ConsultaStock from "../components/ConsultaStock.vue";
import ReportePrescripciones from "../components/ReportePrescripciones.vue";

import EjerciciosComputed from "../components/EjerciciosComputed.vue";

const routes = [
  {
    path: "/",
    redirect: "/panel",
  },
  {
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
    path: '/cliente/:clienteId/prescripcion/nueva',
    name: 'CrearPrescripcion',
    component: RegistrarPrescripcion,
    props: true,
    meta: { requiresAuth: true },
  },
  {
    path: '/cliente/:clienteId/prescripcion/:prescripcionId/editar',
    name: 'EditarPrescripcion',
    component: RegistrarPrescripcion,
    props: true,
    meta: { requiresAuth: true },
  },
  {
    path: '/reportes/prescripciones',
    name: 'ReportePrescripciones',
    component: ReportePrescripciones,
    meta: { requiresAuth: true },
  },
  {
    path: "/ordenes",
    name: "GestionOrdenesTrabajo",
    component: GestionOrdenesTrabajo,
    meta: { requiresAuth: true },
  },
  {
    path: "/productos/registrar",
    component: RegistrarProducto,
    meta: { requiresAuth: true },
  },
  {
    path: "/productos/caracteristicas",
    name: "GestionCaracteristicas",
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

// Guardia de navegación
router.beforeEach((to, from, next) => {
  const { isAuthenticated } = useAuth();
  const requiresAuth = to.meta.requiresAuth;

  if (requiresAuth && !isAuthenticated.value) {
    next("/login");
  } else if (!requiresAuth && isAuthenticated.value && to.path === "/login") {
    next("/panel");
  } else {
    next();
  }
});

export default router;
