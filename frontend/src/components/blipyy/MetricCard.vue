<template>
  <div class="card">
    <div class="card-body">
      <div class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">{{ label }}</div>
      <div
        class="mt-1 text-lg font-bold"
        :class="{
          'text-green-600 dark:text-green-400': type === 'positive',
          'text-red-600 dark:text-red-400': type === 'negative',
          'text-gray-900 dark:text-white': !type
        }"
      >
        {{ value }}
      </div>
      <div v-if="change !== undefined && change !== null" class="text-xs font-medium mt-0.5"
        :class="change >= 0 ? 'text-green-500' : 'text-red-500'"
      >
        {{ change >= 0 ? '+' : '' }}{{ change }}%
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  label: String,
  value: [String, Number],
  change: [Number, null],
  type: String
})
</script>
