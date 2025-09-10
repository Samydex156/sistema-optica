<!-- AutoComplete.vue -->
<template>
  <div class="autocomplete-container">
    <input
      ref="inputRef"
      v-model="searchText"
      @input="onInput"
      @focus="showSuggestions = true"
      @blur="onBlur"
      @keydown="onKeyDown"
      :placeholder="placeholder"
      class="autocomplete-input"
      autocomplete="off"
    />
    
    <!-- Lista de sugerencias -->
    <div 
      v-if="showSuggestions && filteredOptions.length > 0" 
      class="suggestions-dropdown"
    >
      <div
        v-for="(option, index) in filteredOptions"
        :key="option.value"
        @mousedown="selectOption(option)"
        :class="['suggestion-item', { 'highlighted': index === highlightedIndex }]"
      >
        {{ option.label }}
      </div>
    </div>
    
    <!-- Mensaje cuando no hay resultados -->
    <div 
      v-if="showSuggestions && searchText && filteredOptions.length === 0"
      class="no-results"
    >
      No se encontraron resultados
    </div>
  </div>
</template>

<script>
export default {
  name: 'AutoComplete',
  props: {
    modelValue: {
      type: [String, Number],
      default: ''
    },
    options: {
      type: Array,
      required: true,
      // Cada opción debe tener: { value: any, label: string }
    },
    placeholder: {
      type: String,
      default: 'Escriba para buscar...'
    },
    allowCustomValue: {
      type: Boolean,
      default: false
    }
  },
  emits: ['update:modelValue', 'change'],
  data() {
    return {
      searchText: '',
      showSuggestions: false,
      highlightedIndex: -1
    }
  },
  computed: {
    filteredOptions() {
      if (!this.searchText) {
        return this.options.slice(0, 10); // Mostrar solo las primeras 10 opciones
      }
      
      return this.options.filter(option =>
        option.label.toLowerCase().includes(this.searchText.toLowerCase())
      ).slice(0, 10); // Limitar a 10 resultados
    }
  },
  watch: {
    modelValue: {
      handler(newValue) {
        // Encontrar la opción correspondiente al valor seleccionado
        const selectedOption = this.options.find(option => option.value == newValue);
        this.searchText = selectedOption ? selectedOption.label : '';
      },
      immediate: true
    }
  },
  methods: {
    onInput() {
      this.highlightedIndex = -1;
      this.showSuggestions = true;
      
      // Si se permite valor personalizado, emitir el texto actual
      if (this.allowCustomValue) {
        this.$emit('update:modelValue', this.searchText);
        this.$emit('change', this.searchText);
      }
    },
    
    onBlur() {
      // Delay para permitir clicks en las sugerencias
      setTimeout(() => {
        this.showSuggestions = false;
        
        // Si no se permite valor personalizado y no hay coincidencia exacta, limpiar
        if (!this.allowCustomValue) {
          const exactMatch = this.options.find(option => 
            option.label.toLowerCase() === this.searchText.toLowerCase()
          );
          
          if (!exactMatch && this.searchText) {
            this.searchText = '';
            this.$emit('update:modelValue', '');
            this.$emit('change', '');
          }
        }
      }, 200);
    },
    
    onKeyDown(event) {
      if (!this.showSuggestions || this.filteredOptions.length === 0) return;
      
      switch (event.key) {
        case 'ArrowDown':
          event.preventDefault();
          this.highlightedIndex = Math.min(
            this.highlightedIndex + 1,
            this.filteredOptions.length - 1
          );
          break;
          
        case 'ArrowUp':
          event.preventDefault();
          this.highlightedIndex = Math.max(this.highlightedIndex - 1, -1);
          break;
          
        case 'Enter':
          event.preventDefault();
          if (this.highlightedIndex >= 0) {
            this.selectOption(this.filteredOptions[this.highlightedIndex]);
          }
          break;
          
        case 'Escape':
          this.showSuggestions = false;
          this.$refs.inputRef.blur();
          break;
      }
    },
    
    selectOption(option) {
      this.searchText = option.label;
      this.showSuggestions = false;
      this.highlightedIndex = -1;
      
      this.$emit('update:modelValue', option.value);
      this.$emit('change', option.value);
    },
    
    focus() {
      this.$refs.inputRef.focus();
    }
  }
}
</script>

<style scoped>
.autocomplete-container {
  position: relative;
  width: 100%;
}

.autocomplete-input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  box-sizing: border-box;
}

.autocomplete-input:focus {
  border-color: #17a2b8;
  box-shadow: 0 0 0 3px rgba(23, 162, 184, 0.1);
  outline: none;
}

.suggestions-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border: 1px solid #ddd;
  border-top: none;
  border-radius: 0 0 4px 4px;
  max-height: 200px;
  overflow-y: auto;
  z-index: 1000;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.suggestion-item {
  padding: 0.5rem;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
}

.suggestion-item:hover,
.suggestion-item.highlighted {
  background-color: #f8f9fa;
}

.suggestion-item:last-child {
  border-bottom: none;
}

.no-results {
  padding: 0.5rem;
  color: #6c757d;
  font-style: italic;
  text-align: center;
  background: white;
  border: 1px solid #ddd;
  border-top: none;
  border-radius: 0 0 4px 4px;
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  z-index: 1000;
}
</style>