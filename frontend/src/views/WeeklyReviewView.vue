<template>
  <div class="content-wrapper py-8">
    <div class="mb-8">
      <h1 class="heading-page">Weekly Review</h1>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        Auto-generated weekly performance summary
      </p>
    </div>

    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
    </div>

    <template v-else>
      <!-- Summary -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <MetricCard label="Total Trades" :value="review.totalTrades" />
        <MetricCard label="Win Rate" :value="review.winRate + '%'" />
        <MetricCard label="Profit Factor" :value="review.profitFactor" />
        <MetricCard label="Avg R" :value="review.avgR" />
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">Best & Worst</h3>
            <div class="space-y-3">
              <div class="flex justify-between p-3 bg-green-50 dark:bg-green-900/10 rounded-lg">
                <span class="text-sm text-green-700 dark:text-green-400">Best Setup</span>
                <span class="text-sm font-bold text-green-800 dark:text-green-300">{{ review.bestSetup }}</span>
              </div>
              <div class="flex justify-between p-3 bg-red-50 dark:bg-red-900/10 rounded-lg">
                <span class="text-sm text-red-700 dark:text-red-400">Worst Setup</span>
                <span class="text-sm font-bold text-red-800 dark:text-red-300">{{ review.worstSetup }}</span>
              </div>
              <div class="flex justify-between p-3 bg-green-50 dark:bg-green-900/10 rounded-lg">
                <span class="text-sm text-green-700 dark:text-green-400">Best Day</span>
                <span class="text-sm font-bold text-green-800 dark:text-green-300">{{ review.bestDay }}</span>
              </div>
              <div class="flex justify-between p-3 bg-red-50 dark:bg-red-900/10 rounded-lg">
                <span class="text-sm text-red-700 dark:text-red-400">Worst Day</span>
                <span class="text-sm font-bold text-red-800 dark:text-red-300">{{ review.worstDay }}</span>
              </div>
              <div class="flex justify-between p-3 bg-blue-50 dark:bg-blue-900/10 rounded-lg">
                <span class="text-sm text-blue-700 dark:text-blue-400">Best Session</span>
                <span class="text-sm font-bold text-blue-800 dark:text-blue-300">{{ review.bestSession }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">Psychology & Mistakes</h3>
            <div class="space-y-3">
              <div class="p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
                <span class="text-xs text-gray-500 dark:text-gray-400">Most Common Emotion</span>
                <p class="text-sm font-medium text-gray-900 dark:text-white mt-1">{{ review.commonEmotion }}</p>
              </div>
              <div class="p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
                <span class="text-xs text-gray-500 dark:text-gray-400">Most Common Mistake</span>
                <p class="text-sm font-medium text-gray-900 dark:text-white mt-1">{{ review.commonMistake }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Mistakes List -->
      <div v-if="review.mistakes?.length" class="card mb-6">
        <div class="card-body">
          <h3 class="heading-card mb-4">Mistakes This Week</h3>
          <ul class="space-y-2">
            <li v-for="m in review.mistakes" :key="m" class="flex items-start gap-2 text-sm text-red-700 dark:text-red-400">
              <span>•</span> {{ m }}
            </li>
          </ul>
        </div>
      </div>

      <!-- Action Plan -->
      <div class="card border-l-4 border-l-primary-500">
        <div class="card-body">
          <h3 class="heading-card mb-4">Action Plan</h3>
          <p class="text-sm text-gray-700 dark:text-gray-300">{{ review.actionPlan || 'Focus on consistency and following your trading plan.' }}</p>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import MetricCard from '@/components/blipyy/MetricCard.vue'

const loading = ref(true)
const review = ref({
  totalTrades: 0,
  winRate: 0,
  profitFactor: 0,
  avgR: 0,
  bestSetup: '—',
  worstSetup: '—',
  bestDay: '—',
  worstDay: '—',
  bestSession: '—',
  commonEmotion: '—',
  commonMistake: '—',
  mistakes: [],
  actionPlan: ''
})

async function fetchReview() {
  loading.value = true
  try {
    const res = await api.get('/analytics/weekly-review')
    if (res.data) review.value = { ...review.value, ...res.data }
  } catch {
    // Use defaults
  } finally {
    loading.value = false
  }
}

onMounted(fetchReview)
</script>
