<template>
    <div class="contenedor">
        <div class="card">
            <h2>PRECIO X CANTIDAD</h2>
            <input type="number" v-model="precio" placeholder="Precio">
            <input type="number" v-model="cantidad" placeholder="Cantidad">
            <p>El importe total es de: Bs. {{ total }}</p>
        </div>
        <div class="card">
            <h2>PRECIO CON DESCUENTO</h2>
            <input type="number" v-model="precio" placeholder="Precio">
            <input type="number" v-model="porcentajeDescuento" placeholder="Descuento %">
            <p>El precio con el {{ porcentajeDescuento }}% de descuento es: Bs. {{ precioDescuento }}</p>
        </div>
        <div class="card">
            <h2>MONTO DEL IVA</h2>
            <input type="number" v-model="total" placeholder="Sub total" :disabled="habilitar">
            <p>El IVA(13%) es de : Bs.{{ impuestoIVA }}</p>
        </div>
        <div class="card">
            <h2>LIMITE DE CARACTERES</h2>
            <input type="text" v-model="comentario" placeholder="Comentario" :maxlength='limite'>
            <p> {{ restantes }} carácteres restantes</p>
        </div>
        <div class="card">
            <h2>TEXTO A MAYUSCULAS</h2>
            <input type="text" v-model="texto1" placeholder="Texto">
            <p> El Texto escrito es: {{ textoMayusculas }}.</p>
        </div>
        </div>
</template>

<script setup>
import { computed, ref } from 'vue';
// SE HA ELIMINADO LA IMPORTACIÓN DE CALCULATOR

//PRECIO X CANTIDAD
const cantidad = ref(1);
const precio = ref('');
const total = computed(() => precio.value * cantidad.value);

//PRECIO CON DESCUENTO
const porcentajeDescuento = ref(10);
const precioDescuento = computed(() => precio.value - precio.value * (porcentajeDescuento.value / 100));

// MONTO DEL IVA
const impuestoIVA = computed(() => total.value * 0.13);
const habilitar = ref(true);

// LIMITE DE CARACTERES
const comentario = ref('');
const limite = ref(15);
const restantes = computed(() => {
    if (limite.value - comentario.value.length <= 0) {
        return "No te quedan más espacio";
    }
    return limite.value - comentario.value.length;
});

//TEXTO A MAYUSCULAS
const texto1 = ref('');
const textoMayusculas = computed(() => texto1.value.toUpperCase());

</script>

<style scoped>
.contenedor {
    display: flex;
    flex-wrap: wrap;
}

h2 {
    color: #70718d;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif, Cochin, Georgia, Times, 'Times New Roman', serif
}

p {
    color: #4e4f6b;
    font-family: 'Courier New', Courier, monospace;
}

input {
    padding: 0.5rem;
    color: #4e4f6b;
    font-family: 'Courier New', Courier, monospace;
    font-size: 1.5rem;
    border-radius: 1rem;
    box-shadow: 3px 3px 4px #ccc;
    border: solid 1px #acacae;
}

.card {
    display: flex;
    flex-direction: column;
    max-width: 300px;
    width: 250px;
    border: solid 0px #ccc;
    padding: 15px;
    margin: 15px;
    box-shadow: 3px 3px 6px 3px #ddd;
    border-radius: 2rem;
    gap: 1rem;
}
</style>