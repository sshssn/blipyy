<template>
  <div class="p-2 rounded-lg bg-gray-50 dark:bg-gray-800">
    <div class="text-xs text-gray-500 dark:text-gray-400">{{ label }}</div>
    <div
      class="text-sm font-semibold mt-0.5"
      :class="{
        'text-green-600 dark:text-green-400': value === 'bullish',
        'text-red-600 dark:text-red-400': value === 'bearish',
        'text-gray-600 dark:text-gray-400': value === 'neutral' || !value
      }"
    >
      {{ value || '—' }}
    </div>
  </div>
</template>

<script setup>
defineProps({
  label: String,
  value: String
})
</script>
