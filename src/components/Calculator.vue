<template>
  <v-card
    class="calculator"
    max-width="350"
    elevation="0" 
    @keydown="handleKeydown"
    tabindex="0"
    ref="calculatorRef"
  >
    <v-card-text>
      <v-text-field
        v-model="display"
        variant="outlined"
        readonly
        class="display-field"
        aria-label="Display de la calculadora"
      ></v-text-field>

      <v-container fluid class="pa-0">
        <v-row dense>
          <v-col cols="3">
            <v-btn @click="clear" color="red-darken-1" block size="large">C</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('(')" color="grey-darken-1" block size="large">(</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append(')')" color="grey-darken-1" block size="large">)</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('%')" color="orange-darken-1" block size="large">%</v-btn>
          </v-col>
        </v-row>

        <v-row dense>
          <v-col cols="3">
            <v-btn @click="append('7')" block size="large">7</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('8')" block size="large">8</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('9')" block size="large">9</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('/')" color="orange-darken-1" block size="large">/</v-btn>
          </v-col>
        </v-row>

        <v-row dense>
          <v-col cols="3">
            <v-btn @click="append('4')" block size="large">4</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('5')" block size="large">5</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('6')" block size="large">6</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('*')" color="orange-darken-1" block size="large">*</v-btn>
          </v-col>
        </v-row>

        <v-row dense>
          <v-col cols="3">
            <v-btn @click="append('1')" block size="large">1</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('2')" block size="large">2</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('3')" block size="large">3</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('-')" color="orange-darken-1" block size="large">-</v-btn>
          </v-col>
        </v-row>

        <v-row dense>
          <v-col cols="3">
            <v-btn @click="append('0')" block size="large">0</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('.')" block size="large">.</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="calculate" color="blue-darken-1" block size="large">=</v-btn>
          </v-col>
          <v-col cols="3">
            <v-btn @click="append('+')" color="orange-darken-1" block size="large">+</v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const display = ref('0')
const calculatorRef = ref(null)

const append = (char) => {
  const lastChar = display.value.slice(-1)
  const operators = ['+', '-', '*', '/', '%']
  const isOperator = operators.includes(char)
  const isLastOperator = operators.includes(lastChar)
  const isDecimal = char === '.'
  const currentNumber = display.value.split(/[+*/%-]/).pop()
  const hasDecimal = currentNumber.includes('.')

  if (isOperator && isLastOperator) {
    display.value = display.value.slice(0, -1) + char
  } else if (isDecimal && hasDecimal) {
    return
  } else if (display.value === '0' && char !== '.') {
    if (isOperator || isDecimal) {
       display.value += char
    } else {
       display.value = char
    }
  } else if (display.value === 'Error') {
    if (isOperator) return
    display.value = char
  } else {
    display.value += char
  }
}

const clear = () => {
  display.value = '0'
}

const backspace = () => {
  if (display.value === 'Error') {
    clear()
    return
  }
  if (display.value.length > 1) {
    display.value = display.value.slice(0, -1)
  } else {
    display.value = '0'
  }
}

const calculate = () => {
  try {
    let expression = display.value.replace(/%/g, '/100')
    
    if (!expression || /[+*/%-]{2,}$/.test(expression) || /[+*/%-]$/.text(expression)) {
      display.value = 'Error'
      return
    }
    
    const result = new Function('return ' + expression)()
    
    if (!Number.isFinite(result) || isNaN(result)) {
      display.value = 'Error'
    } else {
      display.value = Number(result.toFixed(10)).toString()
    }
  } catch {
    display.value = 'Error'
  }
}

const handleKeydown = (event) => {
  const key = event.key
  if (key === '/' || key === "'") {
    event.preventDefault()
  }
  if (/[0-9]/.test(key)) {
    append(key)
  } else if (key === '+' || key === '-' || key === '*' || key === '/') {
    append(key)
  } else if (key === '.') {
    append('.')
  } else if (key === '%') {
    append('%')
  } else if (key === 'Enter' || key === '=') {
    event.preventDefault()
    calculate()
  } else if (key === 'Escape') {
    clear()
  } else if (key === '(' || key === ')') {
    append(key)
  } else if (key === 'Backspace') {
    backspace()
  }
}

// 1. Creamos una función 'focus' separada
const focus = () => {
  if (calculatorRef.value) {
    calculatorRef.value.$el.focus()
  }
}

// 2. onMounted ahora solo llama a esta función
onMounted(() => {
  focus()
})

// 3. Exponemos la función 'focus'
// Esto permite al componente padre (CalculatorDialog) llamar a this.focus()
defineExpose({
  focus
})

onUnmounted(() => {
})
</script>

<style scoped>
.display-field :deep(input) {
  text-align: right;
  font-size: 28px;
  font-weight: 500;
  height: 65px;
}

.calculator {
  outline: none;
  padding: 8px;
}
</style>