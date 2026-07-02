<template>
  <div class="flex items-center justify-between">
    <span class="text-sm text-gray-600 dark:text-gray-400">{{ label }}</span>
    <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ value }}</span>
  </div>
</template>

<script setup>
defineProps({
  label: String,
  value: [String, Number]
})
</script>
