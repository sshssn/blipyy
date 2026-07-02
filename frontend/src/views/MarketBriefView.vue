<template>
  <div class="content-wrapper py-8">
    <div class="mb-8">
      <h1 class="heading-page">Daily Market Brief</h1>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        Macro context, trends, and today's trading bias
      </p>
      <div class="mt-2 flex items-center gap-4 text-xs text-gray-500 dark:text-gray-400">
        <span>{{ currentDate }}</span>
        <button
          @click="refreshBrief"
          class="inline-flex items-center gap-1 text-primary-600 hover:text-primary-700 dark:text-primary-400"
        >
          <ArrowPathIcon class="w-3.5 h-3.5" />
          Refresh
        </button>
      </div>
    </div>

    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
    </div>

    <template v-else>
      <!-- Macro Bias -->
      <div class="card mb-6">
        <div class="card-body">
          <div class="flex items-center justify-between">
            <h2 class="heading-card">Macro Bias</h2>
            <span
              class="inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold"
              :class="{
                'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400': brief?.macroBias === 'bullish',
                'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300': brief?.macroBias === 'neutral',
                'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400': brief?.macroBias === 'bearish'
              }"
            >
              {{ brief?.macroBias || 'Neutral' }}
            </span>
          </div>
        </div>
      </div>

      <!-- Trend Grid -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <TrendCard symbol="BTC" :trend="brief?.btcTrend" :price="brief?.btcPrice" />
        <TrendCard symbol="ETH" :trend="brief?.ethTrend" :price="brief?.ethPrice" />
        <TrendCard symbol="SOL" :trend="brief?.solTrend" :price="brief?.solPrice" />
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <MetricCard label="DXY" :value="brief?.dxy" />
        <MetricCard label="Nasdaq" :value="brief?.nasdaq" :change="brief?.nasdaqChange" />
        <MetricCard label="VIX" :value="brief?.vix" />
      </div>

      <!-- Market Data -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <MetricCard label="Funding Rate" :value="brief?.funding" />
        <MetricCard label="Open Interest" :value="brief?.openInterest" />
        <MetricCard label="24h Liquidations" :value="brief?.liquidations" />
        <MetricCard label="Treasury Yields" :value="brief?.treasuryYields" />
      </div>

      <!-- News & Events -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">Important News</h3>
            <div v-if="brief?.news?.length" class="space-y-3">
              <div
                v-for="item in brief.news"
                :key="item.title"
                class="flex items-start gap-3 p-3 rounded-lg bg-gray-50 dark:bg-gray-800"
              >
                <div
                  class="w-2 h-2 mt-2 rounded-full shrink-0"
                  :class="{
                    'bg-green-500': item.sentiment === 'positive',
                    'bg-red-500': item.sentiment === 'negative',
                    'bg-gray-400': item.sentiment === 'neutral'
                  }"
                />
                <div>
                  <p class="text-sm font-medium text-gray-900 dark:text-white">{{ item.title }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">{{ item.source }} · {{ item.time }}</p>
                </div>
              </div>
            </div>
            <p v-else class="text-sm text-gray-500 dark:text-gray-400">No recent news</p>
          </div>
        </div>

        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">High Impact Events</h3>
            <div v-if="brief?.events?.length" class="space-y-3">
              <div
                v-for="event in brief.events"
                :key="event.title"
                class="flex items-center justify-between p-3 rounded-lg bg-gray-50 dark:bg-gray-800"
              >
                <div>
                  <p class="text-sm font-medium text-gray-900 dark:text-white">{{ event.title }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">{{ event.time }}</p>
                </div>
                <span
                  class="px-2 py-0.5 text-xs font-medium rounded"
                  :class="{
                    'bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400': event.impact === 'high',
                    'bg-amber-100 text-amber-700 dark:bg-amber-900/20 dark:text-amber-400': event.impact === 'medium'
                  }"
                >
                  {{ event.impact }}
                </span>
              </div>
            </div>
            <p v-else class="text-sm text-gray-500 dark:text-gray-400">No events today</p>
          </div>
        </div>
      </div>

      <!-- Today's Bias -->
      <div class="card mt-6 border-l-4"
        :class="{
          'border-l-green-500': brief?.todaysBias === 'long',
          'border-l-red-500': brief?.todaysBias === 'short',
          'border-l-amber-500': brief?.todaysBias === 'wait'
        }"
      >
        <div class="card-body">
          <div class="flex items-center justify-between">
            <div>
              <h2 class="heading-card">Today's Bias</h2>
              <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">{{ brief?.biasReasoning }}</p>
            </div>
            <span
              class="inline-flex items-center px-4 py-2 rounded-full text-base font-bold"
              :class="{
                'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400': brief?.todaysBias === 'long',
                'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400': brief?.todaysBias === 'short',
                'bg-amber-100 text-amber-800 dark:bg-amber-900/20 dark:text-amber-400': brief?.todaysBias === 'wait'
              }"
            >
              {{ brief?.todaysBias?.toUpperCase() || 'WAIT' }}
            </span>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ArrowPathIcon } from '@heroicons/vue/24/outline'
import api from '@/services/api'
import MetricCard from '@/components/blipyy/MetricCard.vue'
import TrendCard from '@/components/blipyy/TrendCard.vue'

const loading = ref(true)
const brief = ref(null)

const currentDate = computed(() => {
  return new Date().toLocaleDateString('en-US', {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
  })
})

async function fetchBrief() {
  loading.value = true
  try {
    const res = await api.get('/analytics/market-brief')
    brief.value = res.data
  } catch {
    brief.value = getDefaultBrief()
  } finally {
    loading.value = false
  }
}

function refreshBrief() {
  fetchBrief()
}

function getDefaultBrief() {
  return {
    macroBias: 'neutral',
    btcTrend: 'neutral', btcPrice: '—',
    ethTrend: 'neutral', ethPrice: '—',
    solTrend: 'neutral', solPrice: '—',
    dxy: '—',
    nasdaq: '—', nasdaqChange: null,
    vix: '—',
    funding: '—',
    openInterest: '—',
    liquidations: '—',
    treasuryYields: '—',
    news: [],
    events: [],
    todaysBias: 'wait',
    biasReasoning: 'Configure API keys for real-time market data.'
  }
}

onMounted(fetchBrief)
</script>
