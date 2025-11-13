// Cargar los módulos incorporados de Node.js
const fs = require('fs').promises; // Módulo File System (con promesas)
const path = require('path');     // Módulo Path para manejar rutas

// --- Configuración ---
const sufijo = " OCT"; // El sufijo que quieres agregar (con el espacio)
const extensionObjetivo = ".pdf";
const directorioActual = '.'; // '.' significa la carpeta actual
// ---------------------

// Creamos una función async para poder usar 'await'
async function agregarSufijo() {
  console.log(`Buscando archivos "${extensionObjetivo}" para agregar el sufijo "${sufijo.trim()}"...`);
  
  try {
    // 1. Leer todos los archivos de la carpeta
    const archivos = await fs.readdir(directorioActual);

    // 2. Iterar sobre la lista de archivos
    for (const archivo of archivos) {
      
      // --- ESTA ES LA LÓGICA DE SUFIJO ---
      const extension = path.extname(archivo); // Obtiene ".pdf"
      const nombreBase = path.basename(archivo, extension); // Obtiene "reporte"

      // 3. Condición: 
      //    SI es un .pdf Y NO termina ya con el sufijo
      if (extension === extensionObjetivo && !nombreBase.endsWith(sufijo)) {
        
        // 4. Definir la ruta antigua
        const rutaAntigua = path.join(directorioActual, archivo);
        
        // 5. Construir el nuevo nombre
        const nombreNuevo = `${nombreBase}${sufijo}${extension}`; // Ej: "reporte OCT.pdf"
        const rutaNueva = path.join(directorioActual, nombreNuevo);
        
        // 6. Renombrar el archivo
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

// 7. Ejecutar la función principal
agregarSufijo();