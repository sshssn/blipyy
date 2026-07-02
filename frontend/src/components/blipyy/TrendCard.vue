<template>
  <div class="card">
    <div class="card-body">
      <div class="flex items-center justify-between mb-2">
        <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ symbol }}</span>
        <span class="text-sm text-gray-600 dark:text-gray-400">{{ price }}</span>
      </div>
      <div
        class="text-xs font-medium px-2 py-1 rounded inline-flex items-center gap-1"
        :class="{
          'bg-green-100 text-green-700 dark:bg-green-900/20 dark:text-green-400': trend === 'bullish',
          'bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400': trend === 'bearish',
          'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400': trend === 'neutral' || !trend
        }"
      >
        <ArrowTrendingUpIcon v-if="trend === 'bullish'" class="w-3.5 h-3.5" />
        <ArrowTrendingDownIcon v-if="trend === 'bearish'" class="w-3.5 h-3.5" />
        <MinusIcon v-if="trend === 'neutral' || !trend" class="w-3.5 h-3.5" />
        {{ trend ? trend.charAt(0).toUpperCase() + trend.slice(1) : '—' }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ArrowTrendingUpIcon, ArrowTrendingDownIcon, MinusIcon } from '@heroicons/vue/24/outline'

defineProps({
  symbol: String,
  trend: String,
  price: String
})
</script>
