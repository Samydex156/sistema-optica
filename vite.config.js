import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    host: true, // Esto permite el acceso desde la red local
    port:3000, // Permite modificar el puerto de ejecución
    open:true // Abre el navegador automaticamente con el host y el puerto configurados
  }
})