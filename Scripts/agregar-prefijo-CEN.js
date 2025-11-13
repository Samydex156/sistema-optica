// Cargar los módulos incorporados de Node.js
const fs = require('fs').promises; // Módulo File System (con promesas)
const path = require('path');     // Módulo Path para manejar rutas

// --- Configuración ---
const prefijo = "CEN "; // El prefijo que quieres agregar (con el espacio)
const extensionObjetivo = ".pdf";
const directorioActual = '.'; // '.' significa la carpeta actual
// ---------------------

// Creamos una función async para poder usar 'await'
async function agregarPrefijo() {
  console.log(`Buscando archivos "${extensionObjetivo}" para agregar el prefijo "${prefijo.trim()}"...`);
  
  try {
    // 1. Leer todos los archivos de la carpeta
    const archivos = await fs.readdir(directorioActual);

    // 2. Iterar sobre la lista de archivos
    for (const archivo of archivos) {
      
      // 3. Condición: 
      //    SI es un .pdf Y NO comienza ya con el prefijo
      if (archivo.endsWith(extensionObjetivo) && !archivo.startsWith(prefijo)) {
        
        // 4. Definir la ruta antigua y la nueva
        const rutaAntigua = path.join(directorioActual, archivo);
        const nombreNuevo = `${prefijo}${archivo}`;
        const rutaNueva = path.join(directorioActual, nombreNuevo);
        
        // 5. Renombrar el archivo
        await fs.rename(rutaAntigua, rutaNueva);
        console.log(`Renombrado: ${archivo}  ->  ${nombreNuevo}`);
      }
    }
    
    console.log("\nProceso completado.");

  } catch (err) {
    // Manejo de errores
    console.error("Ha ocurrido un error:", err.message);
  }
}

// 6. Ejecutar la función principal
agregarPrefijo();