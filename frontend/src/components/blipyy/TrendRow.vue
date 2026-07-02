<template>
  <div class="flex items-center justify-between py-1.5">
    <span class="text-sm text-gray-600 dark:text-gray-400">{{ timeframe }}</span>
    <div
      class="text-sm font-medium flex items-center gap-1"
      :class="{
        'text-green-600 dark:text-green-400': trend === 'bullish',
        'text-red-600 dark:text-red-400': trend === 'bearish',
        'text-gray-600 dark:text-gray-400': trend === 'neutral' || !trend
      }"
    >
      <ArrowTrendingUpIcon v-if="trend === 'bullish'" class="w-4 h-4" />
      <ArrowTrendingDownIcon v-if="trend === 'bearish'" class="w-4 h-4" />
      <MinusIcon v-if="trend === 'neutral' || !trend" class="w-4 h-4" />
      {{ trend ? trend.charAt(0).toUpperCase() + trend.slice(1) : '—' }}
    </div>
  </div>
</template>

<script setup>
import { ArrowTrendingUpIcon, ArrowTrendingDownIcon, MinusIcon } from '@heroicons/vue/24/outline'

defineProps({
  timeframe: String,
  trend: String
})
</script>
