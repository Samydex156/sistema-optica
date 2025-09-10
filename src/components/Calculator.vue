<template>
  <div class="calculator" tabindex="0" @keydown="handleKeydown">
    <div class="display">{{ display }}</div>
    <div class="buttons">
      <button @click="clear">C</button>
      <button @click="append('(')">(</button>
      <button @click="append(')')">)</button>
      <button @click="append('%')">%</button>
      <button @click="append('7')">7</button>
      <button @click="append('8')">8</button>
      <button @click="append('9')">9</button>
      <button @click="append('/')">/</button>
      <button @click="append('4')">4</button>
      <button @click="append('5')">5</button>
      <button @click="append('6')">6</button>
      <button @click="append('*')">*</button>
      <button @click="append('1')">1</button>
      <button @click="append('2')">2</button>
      <button @click="append('3')">3</button>
      <button @click="append('-')">-</button>
      <button @click="append('0')">0</button>
      <button @click="append('.')">.</button>
      <button @click="calculate">=</button>
      <button @click="append('+')">+</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const display = ref('0')

const append = (char) => {
  // Prevent multiple consecutive operators or decimals
  const lastChar = display.value.slice(-1)
  const operators = ['+', '-', '*', '/', '%']
  const isOperator = operators.includes(char)
  const isLastOperator = operators.includes(lastChar)
  const isDecimal = char === '.'
  const hasDecimal = display.value.split(/[+*/%-]/).pop().includes('.')

  if (isOperator && isLastOperator) {
    // Replace last operator with new one
    display.value = display.value.slice(0, -1) + char
  } else if (isDecimal && hasDecimal) {
    // Prevent multiple decimals in a number
    return
  } else if (display.value === '0' && char !== '.') {
    display.value = char
  } else {
    display.value += char
  }
}

const clear = () => {
  display.value = '0'
}

const backspace = () => {
  if (display.value.length > 1) {
    display.value = display.value.slice(0, -1)
  } else {
    display.value = '0'
  }
}

const calculate = () => {
  try {
    // Replace % with /100 for evaluation
    let expression = display.value.replace(/%/g, '/100')
    // Validate expression
    if (!expression || /[+*/%-]{2,}/.test(expression) || /[+/ %-]$/.test(expression)) {
      display.value = 'Error'
      return
    }
    // Use Function constructor for safe evaluation
    const result = new Function('return ' + expression)()
    if (!Number.isFinite(result) || isNaN(result)) {
      display.value = 'Error'
    } else {
      display.value = Number(result.toFixed(8)).toString() // Round to avoid floating-point issues
    }
  } catch {
    display.value = 'Error'
  }
}

const handleKeydown = (event) => {
  const key = event.key
  // Prevent default browser behavior for specific keys
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
  } else if (key === 'Enter') {
    calculate()
  } else if (key === 'Escape') {
    clear()
  } else if (key === '(' || key === ')') {
    append(key)
  } else if (key === 'Backspace') {
    backspace()
  }
}

onMounted(() => {
  // Focus the calculator div to ensure key events are captured
  const calculator = document.querySelector('.calculator')
  calculator.focus()
})

onUnmounted(() => {
  // No need to remove window event listener since we bind to the component
})
</script>

<style scoped>
.calculator {
  max-width: 300px;
  margin: 50px auto;
  padding: 20px;
  border: 1px solid #ccc;
  border-radius: 5px;
  background-color: #f9f9f9;
}

.display {
  width: 100%;
  height: 40px;
  margin-bottom: 10px;
  padding: 10px;
  font-size: 20px;
  text-align: right;
  border: 1px solid #ccc;
  border-radius: 5px;
  background-color: white;
}

.buttons {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 5px;
}

button {
  padding: 15px;
  font-size: 18px;
  border: 1px solid #ccc;
  border-radius: 5px;
  background-color: #fff;
  cursor: pointer;
}

button:hover {
  background-color: #e0e0e0;
}
</style>