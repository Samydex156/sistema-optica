// src/main.js
import { createApp } from 'vue';
import App from './App.vue';

import router from './router';

import 'vuetify/styles'; // Importa los estilos CSS de Vuetify
import { createVuetify } from 'vuetify';
import * as components from 'vuetify/components';
import * as directives from 'vuetify/directives';
import '@mdi/font/css/materialdesignicons.css'; //importa los iconos MDI
// import vuetify from './plugins/vuetify'; // Importa el plugin de Vuetify

const vuetify = createVuetify({
    components,
    directives,
    icons:{
        defaultSet:'mdi',
    },
});

const app = createApp(App);

app.use(router);
app.use(vuetify); // Usa el plugin de Vuetify

app.mount('#app');
