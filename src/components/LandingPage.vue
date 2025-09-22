<script setup>
import { ref, onMounted } from 'vue';

// Datos de ejemplo para la galería de productos
const products = ref([
  { id: 1, name: 'Lentes de sol', image: 'https://placehold.co/600x400/293d5c/FFFFFF?text=Lentes+de+Sol' },
  { id: 2, name: 'Lentes de contacto', image: 'https://placehold.co/600x400/293d5c/FFFFFF?text=Lentes+de+Contacto' },
  { id: 3, name: 'Armazones de diseñador', image: 'https://placehold.co/600x400/293d5c/FFFFFF?text=Armazones' },
  { id: 4, name: 'Lentes para niños', image: 'https://placehold.co/600x400/293d5c/FFFFFF?text=Lentes+para+Niños' },
]);

// Datos de ejemplo para los servicios
const services = ref([
  {
    icon: `<svg class="service-icon" fill="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 15.5V11h-2v6.5h2zm-1.5-8h3.5v-3.5h-3.5v3.5z"></path>
            </svg>`,
    title: 'Examen de la Vista',
    description: 'Realizamos exámenes completos para asegurar la salud de tus ojos.'
  },
  {
    icon: `<svg class="service-icon" fill="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1.5 15h3v-3h-3v3zm0-4h3v-3h-3v3zm-1-8h5v3h-5v-3z"></path>
            </svg>`,
    title: 'Lentes y Armazones',
    description: 'Gran variedad de lentes y armazones para todos los estilos y necesidades.'
  },
  {
    icon: `<svg class="service-icon" fill="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1.5 15h3v-3h-3v3zm-1.5-4h5v-3h-5v3zm0-4h5v-3h-5v3z"></path>
            </svg>`,
    title: 'Lentes de Contacto',
    description: 'Adaptación y venta de lentes de contacto de las mejores marcas.'
  }
]);

// Lógica para cargar los datos desde Supabase
// onMounted(async () => {
//   try {
//     const { data, error } = await supabase.from('products').select('*');
//     if (error) throw error;
//     products.value = data;
//   } catch (error) {
//     console.error('Error fetching products:', error.message);
//   }
// });
</script>

<template>
  <div class="landing-page">
    <header class="main-header">
      <nav class="container nav-bar">
        <a href="#" class="logo">Optalvis</a>
        <div class="nav-links">
          <a href="#services" class="nav-link">Servicios</a>
          <a href="#gallery" class="nav-link">Productos</a>
          <a href="#about" class="nav-link">Nosotros</a>
          <a href="#contact" class="nav-link">Contacto</a>
        </div>
        <a href="#contact" class="cta-button">
          Agenda tu Cita
        </a>
        <button class="mobile-menu-button">
          <svg class="hamburger-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </button>
      </nav>
    </header>

    <main>
      <section class="hero-section">
        <div class="container hero-content">
          <h1 class="hero-title animate-fade-in-up">
            Cuidado Visual de Calidad para Toda la Familia
          </h1>
          <p class="hero-subtitle animate-fade-in-up animation-delay-500">
            Descubre la diferencia con nuestros servicios ópticos profesionales y la más amplia selección de productos.
          </p>
          <a href="#contact" class="hero-cta-button animate-fade-in-up animation-delay-1000">
            Agenda tu Examen de la Vista
          </a>
        </div>
      </section>

      <section id="services" class="services-section">
        <div class="container text-center">
          <h2 class="section-title">Nuestros Servicios</h2>
          <p class="section-subtitle">
            Ofrecemos una gama completa de servicios para mantener tus ojos sanos y tu visión perfecta.
          </p>
          <div class="services-grid">
            <div v-for="service in services" :key="service.title" class="service-card">
              <div v-html="service.icon"></div>
              <h3 class="card-title">{{ service.title }}</h3>
              <p class="card-description">{{ service.description }}</p>
            </div>
          </div>
        </div>
      </section>

      <section id="gallery" class="gallery-section">
        <div class="container">
          <div class="text-center mb-16">
            <h2 class="section-title">Nuestros Productos</h2>
            <p class="section-subtitle">
              Explora nuestra selección de lentes de sol, armazones y más.
            </p>
          </div>
          <div class="product-grid">
            <div v-for="product in products" :key="product.id" class="product-card">
              <img :src="product.image" :alt="product.name" class="product-image">
              <div class="product-info">
                <h3 class="product-name">{{ product.name }}</h3>
                <a href="#" class="product-link">Ver detalles &rarr;</a>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="about" class="about-section">
        <div class="container about-content">
          <div class="about-text">
            <h2 class="section-title">
              Quiénes Somos
            </h2>
            <p class="about-paragraph">
              En **Optalvis**, nos dedicamos a ofrecer soluciones visuales personalizadas. Con años de experiencia, un equipo de especialistas calificados y tecnología de punta, garantizamos la mejor atención y los productos más innovadores para el cuidado de tus ojos. Nuestra misión es mejorar tu calidad de vida a través de una visión clara y saludable.
            </p>
            <p class="about-paragraph">
              Estamos comprometidos con la excelencia y la satisfacción total de nuestros clientes, brindando un servicio cálido y profesional en cada visita.
            </p>
          </div>
          <div class="about-image-container">
            <img src="https://placehold.co/800x600/b0bec5/FFFFFF?text=Equipo+Optalvis" alt="Equipo de la óptica Optalvis" class="about-image">
          </div>
        </div>
      </section>

      <section id="contact" class="cta-section">
        <div class="container text-center cta-content">
          <h2 class="cta-title">
            ¡Agenda tu Cita Hoy Mismo!
          </h2>
          <p class="cta-subtitle">
            Déjanos cuidar de tu visión. Llámanos o llena nuestro formulario de contacto para agendar una consulta con nuestros especialistas.
          </p>
          <a href="#" class="cta-button-contact">
            Contactar Ahora
          </a>
        </div>
      </section>
    </main>

    <footer class="main-footer">
      <div class="container footer-grid">
        <div class="footer-column">
          <h4 class="footer-title">Optalvis</h4>
          <p>
            Cuidado visual con la mejor tecnología y calidez humana.
          </p>
        </div>
        <div class="footer-column footer-contact">
          <h4 class="footer-title">Contacto</h4>
          <ul>
            <li><a href="#" class="footer-link">Teléfono: +52 55 1234 5678</a></li>
            <li><a href="#" class="footer-link">Email: info@optalvis.com</a></li>
            <li>Dirección: Calle Falsa 123, Ciudad de México</li>
          </ul>
        </div>
        <div class="footer-column footer-social">
          <h4 class="footer-title">Redes Sociales</h4>
          <div class="social-links">
            <a href="#" class="footer-link">Facebook</a>
            <a href="#" class="footer-link">Instagram</a>
            <a href="#" class="footer-link">Twitter</a>
          </div>
        </div>
      </div>
      <div class="copyright">
        © {{ new Date().getFullYear() }} Optalvis. Todos los derechos reservados.
      </div>
    </footer>
  </div>
</template>

<style scoped>
/* Estilos Globales y de Layout */
.landing-page {
  font-family: sans-serif;
  color: #333;
  background-color: #f9fafb;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.container {
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
  padding-left: 1.5rem;
  padding-right: 1.5rem;
}

.text-center {
  text-align: center;
}

/* Encabezado */
.main-header {
  background-color: white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
  z-index: 50;
  transition: box-shadow 0.3s ease;
}

.nav-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  padding-bottom: 1rem;
}

.logo {
  font-size: 1.875rem;
  font-weight: 800;
  color: #0ea5e9;
}

.nav-links {
  display: none;
  gap: 2rem;
}

.nav-link {
  color: #4b5563;
  font-weight: 500;
  transition: color 0.3s ease;
}

.nav-link:hover {
  color: #0ea5e9;
}

.cta-button {
  background-color: #0ea5e9;
  color: white;
  font-weight: 600;
  padding: 0.75rem 1.5rem;
  border-radius: 9999px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  transition: transform 0.3s ease, background-color 0.3s ease;
  display: none;
}

.cta-button:hover {
  background-color: #0284c7;
  transform: scale(1.05);
}

.mobile-menu-button {
  background: none;
  border: none;
  color: #4b5563;
  cursor: pointer;
  padding: 0;
  display: block;
}

.mobile-menu-button:hover {
  color: #0ea5e9;
}

.hamburger-icon {
  width: 2rem;
  height: 2rem;
}

@media (min-width: 768px) {
  .nav-links,
  .cta-button {
    display: flex;
  }
  .mobile-menu-button {
    display: none;
  }
}

/* Sección Hero */
.hero-section {
  background: linear-gradient(to right, #0ea5e9, #0ea5e9);
  color: white;
  padding: 8rem 1.5rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.hero-content {
  max-width: 960px;
}

.hero-title {
  font-size: 2.25rem;
  font-weight: 800;
  line-height: 1.25;
  margin-bottom: 1rem;
}

.hero-subtitle {
  font-size: 1.125rem;
  font-weight: 300;
  margin-bottom: 2rem;
  max-width: 48rem;
  margin-left: auto;
  margin-right: auto;
  opacity: 0;
}

.hero-cta-button {
  background-color: white;
  color: #0ea5e9;
  font-weight: 700;
  padding: 1rem 2.5rem;
  border-radius: 9999px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s ease;
  transform: scale(1);
  opacity: 0;
}

.hero-cta-button:hover {
  transform: scale(1.05);
  background-color: #f3f4f6;
}

@media (min-width: 768px) {
  .hero-section {
    padding-top: 10rem;
    padding-bottom: 10rem;
  }
  .hero-title {
    font-size: 4rem;
  }
  .hero-subtitle {
    font-size: 1.5rem;
  }
}

/* Sección de Servicios */
.services-section {
  padding-top: 5rem;
  padding-bottom: 8rem;
  background-color: white;
}

.section-title {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: #111827;
}

.section-subtitle {
  color: #6b7280;
  margin-bottom: 3rem;
  max-width: 42rem;
  margin-left: auto;
  margin-right: auto;
}

.services-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2.5rem;
}

.service-card {
  background-color: #f9fafb;
  border-radius: 1rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  padding: 2.5rem;
  transition: transform 0.3s ease, box-shadow 0.3s ease, background-color 0.3s ease;
  border: 1px solid #f3f4f6;
}

.service-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  background-color: white;
}

.service-icon {
  width: 4rem;
  height: 4rem;
  margin-left: auto;
  margin-right: auto;
  margin-bottom: 1rem;
  color: #0ea5e9;
}

.card-title {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  color: #1f2937;
}

.card-description {
  color: #4b5563;
  line-height: 1.6;
}

@media (min-width: 768px) {
  .services-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  .section-title {
    font-size: 3rem;
  }
}

/* Sección de Galería de Productos */
.gallery-section {
  background-color: #f3f4f6;
  padding-top: 5rem;
  padding-bottom: 8rem;
}

.product-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
}

.product-card {
  background-color: white;
  border-radius: 1rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  overflow: hidden;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.product-card:hover {
  transform: scale(1.05);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

.product-image {
  width: 100%;
  height: 16rem;
  object-fit: cover;
}

.product-info {
  padding: 1.5rem;
  text-align: center;
}

.product-name {
  font-weight: 700;
  font-size: 1.125rem;
  margin-bottom: 0.5rem;
}

.product-link {
  color: #0ea5e9;
  font-weight: 600;
  transition: color 0.3s ease;
}

.product-link:hover {
  color: #0284c7;
}

@media (min-width: 640px) {
  .product-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .product-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}

/* Sección "Quiénes Somos" */
.about-section {
  padding-top: 5rem;
  padding-bottom: 8rem;
  background-color: white;
}

.about-content {
  display: grid;
  grid-template-columns: 1fr;
  gap: 3rem;
  align-items: center;
}

.about-text {
  text-align: left;
}

.about-paragraph {
  color: #4b5563;
  margin-bottom: 1.5rem;
  line-height: 1.6;
}

.about-image-container {
  order: -1;
}

.about-image {
  border-radius: 1rem;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  width: 100%;
}

@media (min-width: 768px) {
  .about-content {
    grid-template-columns: repeat(2, 1fr);
  }
  .about-image-container {
    order: 0;
  }
}

/* Llamada a la Acción */
.cta-section {
  background-color: #0ea5e9;
  color: white;
  padding-top: 5rem;
  padding-bottom: 5rem;
}

.cta-content {
  max-width: 768px;
  margin-left: auto;
  margin-right: auto;
}

.cta-title {
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 1rem;
}

.cta-subtitle {
  font-size: 1.125rem;
  margin-bottom: 2rem;
  max-width: 48rem;
  margin-left: auto;
  margin-right: auto;
  font-weight: 300;
}

.cta-button-contact {
  background-color: white;
  color: #0ea5e9;
  font-weight: 700;
  padding: 1rem 3rem;
  border-radius: 9999px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s ease;
  transform: scale(1);
}

.cta-button-contact:hover {
  transform: scale(1.05);
  background-color: #f3f4f6;
}

@media (min-width: 768px) {
  .cta-title {
    font-size: 3rem;
  }
}

/* Pie de Página */
.main-footer {
  background-color: #111827;
  color: #9ca3af;
  padding: 3rem 1.5rem;
}

.footer-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
  text-align: center;
}

.footer-title {
  color: white;
  font-weight: 700;
  margin-bottom: 1rem;
}

.footer-link {
  color: #9ca3af;
  transition: color 0.3s ease;
}

.footer-link:hover {
  color: white;
}

.social-links {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.copyright {
  margin-top: 2rem;
  text-align: center;
  font-size: 0.875rem;
  color: #4b5563;
  border-top: 1px solid #374151;
  padding-top: 1rem;
}

@media (min-width: 768px) {
  .footer-grid {
    grid-template-columns: repeat(4, 1fr);
    text-align: left;
  }
  .footer-contact {
    grid-column: span 2 / span 2;
  }
  .social-links {
    justify-content: flex-start;
  }
}

/* Animaciones */
@keyframes fade-in-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in-up {
  animation: fade-in-up 1s ease-out forwards;
}

.animation-delay-500 {
  animation-delay: 0.5s;
}

.animation-delay-1000 {
  animation-delay: 1s;
}
</style>