// Cargar los módulos incorporados de Node.js
const fs = require('fs').promises; // Módulo File System (con promesas)
const path = require('path');     // Módulo Path para manejar rutas

// --- Configuración ---
// El error que estamos buscando:
const textoErroneo = ".pdf OCT";
// El texto correcto con el que lo reemplazaremos:
const textoCorregido = " OCT.pdf";

const directorioActual = '.';
// ---------------------

async function repararArchivos() {
  console.log("Iniciando reparación de archivos sin extensión...");
  
  try {
    // 1. Leer todos los archivos de la carpeta
    const archivos = await fs.readdir(directorioActual);

    // 2. Iterar sobre la lista de archivos
    for (const archivo of archivos) {
      
      // Verificamos si es un archivo y no una carpeta
      const rutaCompleta = path.join(directorioActual, archivo);
      const stat = await fs.stat(rutaCompleta);
      if (stat.isDirectory()) {
        continue; // Ignorar carpetas
      }

      // 3. Condición: 
      //    SI el nombre del archivo termina con el texto erróneo
      if (archivo.endsWith(textoErroneo)) {
        
        // 4. Construir el nuevo nombre
        // Reemplazamos la parte mala por la parte buena
        // Ej: "reporte.pdf OCT" -> "reporte OCT.pdf"
        const nombreNuevo = archivo.replace(textoErroneo, textoCorregido);
        
        // 5. Definir la ruta antigua y la nueva
        const rutaNueva = path.join(directorioActual, nombreNuevo);
        
        // 6. Renombrar el archivo
        await fs.rename(rutaCompleta, rutaNueva);
        console.log(`Reparado: ${archivo}  ->  ${nombreNuevo}`);
      }
    }
    
    console.log("\nProceso de reparación completado.");

  } catch (err) {
    // Manejo de errores
    console.error("Ha ocurrido un error:", err.message);
  }
}

// 7. Ejecutar la función principal
repararArchivos();