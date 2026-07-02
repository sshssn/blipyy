<template>
  <label class="flex items-center gap-3 p-3 rounded-lg cursor-pointer transition-colors"
    :class="modelValue
      ? 'bg-green-50 dark:bg-green-900/10 border border-green-200 dark:border-green-800'
      : 'bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 hover:bg-gray-100 dark:hover:bg-gray-700'"
  >
    <input
      type="checkbox"
      :checked="modelValue"
      @change="$emit('update:modelValue', $event.target.checked)"
      class="h-5 w-5 rounded border-gray-300 text-primary-600 focus:ring-primary-500 dark:border-gray-600 dark:bg-gray-700"
    />
    <span
      class="text-sm font-medium"
      :class="modelValue ? 'text-green-800 dark:text-green-300 line-through' : 'text-gray-700 dark:text-gray-300'"
    >
      {{ label }}
    </span>
  </label>
</template>

<script setup>
defineProps({
  modelValue: Boolean,
  label: String
})

defineEmits(['update:modelValue'])
</script>
