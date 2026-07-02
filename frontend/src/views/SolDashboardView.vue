<template>
  <div class="content-wrapper py-8">
    <div class="mb-8">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="heading-page">SOLUSDT Dashboard</h1>
          <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
            Dedicated Solana futures analysis
          </p>
        </div>
        <div class="text-right">
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            ${{ currentPrice }}
          </div>
          <div
            class="text-sm font-medium"
            :class="priceChange >= 0 ? 'text-green-600' : 'text-red-600'"
          >
            {{ priceChange >= 0 ? '+' : '' }}{{ priceChange }}%
          </div>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      <MetricCard label="Funding Rate" :value="funding" />
      <MetricCard label="Open Interest" :value="openInterest" />
      <MetricCard label="24h Volume" :value="volume" />
      <MetricCard label="BTC Correlation" :value="btcCorrelation" />
    </div>

    <!-- Trend Section -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
      <div class="card">
        <div class="card-body">
          <h3 class="heading-card mb-4">Trend Analysis</h3>
          <div class="space-y-4">
            <TrendRow timeframe="Daily" :trend="trends.daily" />
            <TrendRow timeframe="4H" :trend="trends.h4" />
            <TrendRow timeframe="1H" :trend="trends.h1" />
            <TrendRow timeframe="15m" :trend="trends.m15" />
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-body">
          <h3 class="heading-card mb-4">Liquidity Zones</h3>
          <div class="space-y-3">
            <div class="flex justify-between p-3 bg-green-50 dark:bg-green-900/10 rounded-lg">
              <span class="text-sm font-medium text-green-700 dark:text-green-400">Support</span>
              <span class="text-sm font-bold text-green-800 dark:text-green-300">{{ liquidity.support?.join(', ') || '—' }}</span>
            </div>
            <div class="flex justify-between p-3 bg-red-50 dark:bg-red-900/10 rounded-lg">
              <span class="text-sm font-medium text-red-700 dark:text-red-400">Resistance</span>
              <span class="text-sm font-bold text-red-800 dark:text-red-300">{{ liquidity.resistance?.join(', ') || '—' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Today's Bias -->
    <div class="card border-l-4"
      :class="{
        'border-l-green-500': bias === 'long',
        'border-l-red-500': bias === 'short',
        'border-l-amber-500': bias === 'wait'
      }"
    >
      <div class="card-body">
        <div class="flex items-center justify-between">
          <div>
            <h2 class="heading-card">Today's SOL Bias</h2>
            <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">{{ biasReasoning }}</p>
          </div>
          <span
            class="inline-flex items-center px-4 py-2 rounded-full text-base font-bold"
            :class="{
              'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400': bias === 'long',
              'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400': bias === 'short',
              'bg-amber-100 text-amber-800 dark:bg-amber-900/20 dark:text-amber-400': bias === 'wait'
            }"
          >
            {{ bias.toUpperCase() }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import MetricCard from '@/components/blipyy/MetricCard.vue'
import TrendRow from '@/components/blipyy/TrendRow.vue'

const currentPrice = ref('—')
const priceChange = ref(0)
const funding = ref('—')
const openInterest = ref('—')
const volume = ref('—')
const btcCorrelation = ref('—')
const trends = ref({ daily: 'neutral', h4: 'neutral', h1: 'neutral', m15: 'neutral' })
const liquidity = ref({ support: [], resistance: [] })
const bias = ref('wait')
const biasReasoning = ref('Configure API keys for real-time SOL market data.')

async function fetchSolData() {
  try {
    const res = await api.get('/analytics/sol-dashboard')
    if (res.data) {
      currentPrice.value = res.data.price || '—'
      priceChange.value = res.data.priceChange || 0
      funding.value = res.data.funding || '—'
      openInterest.value = res.data.openInterest || '—'
      volume.value = res.data.volume || '—'
      btcCorrelation.value = res.data.btcCorrelation || '—'
      trends.value = res.data.trends || { daily: 'neutral', h4: 'neutral', h1: 'neutral', m15: 'neutral' }
      liquidity.value = res.data.liquidity || { support: [], resistance: [] }
      bias.value = res.data.bias || 'wait'
      biasReasoning.value = res.data.biasReasoning || 'No SOL-specific analysis available.'
    }
  } catch {
    // Use defaults
  }
}

onMounted(fetchSolData)
</script>
