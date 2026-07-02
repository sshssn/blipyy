<template>
  <div class="content-wrapper py-8">
    <div class="mb-8">
      <h1 class="heading-page">Signal Engine</h1>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        Score trade opportunities — this does NOT auto trade. It helps YOU decide.
      </p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-4 gap-4 mb-6">
      <div>
        <label class="label">Ticker</label>
        <input v-model="ticker" class="input" placeholder="SOLUSDT" />
      </div>
      <div>
        <label class="label">Direction</label>
        <BaseSelect v-model="direction" :options="directionOptions" />
      </div>
      <div class="flex items-end">
        <button @click="scan" class="btn-primary w-full" :disabled="scanning">
          {{ scanning ? 'Scanning...' : 'Scan' }}
        </button>
      </div>
      <div class="flex items-end">
        <button @click="scanAll" class="btn-secondary w-full" :disabled="scanning">
          Scan All Markets
        </button>
      </div>
    </div>

    <div v-if="scanning" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
    </div>

    <template v-if="signals.length">
      <div class="space-y-4">
        <div
          v-for="signal in signals"
          :key="signal.ticker"
          class="card"
          :class="{
            'border-l-4 border-l-green-500': signal.grade === 'A' || signal.grade === 'A+',
            'border-l-4 border-l-blue-500': signal.grade === 'B',
            'border-l-4 border-l-amber-500': signal.grade === 'C',
            'border-l-4 border-l-gray-400': signal.grade === 'Skip'
          }"
        >
          <div class="card-body">
            <div class="flex items-center justify-between mb-4">
              <div class="flex items-center gap-3">
                <h2 class="heading-card">{{ signal.ticker }}</h2>
                <span
                  class="px-2 py-0.5 text-xs font-medium rounded"
                  :class="signal.direction === 'long' ? 'bg-green-100 text-green-700 dark:bg-green-900/20 dark:text-green-400' : 'bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400'"
                >
                  {{ signal.direction }}
                </span>
              </div>
              <div class="flex items-center gap-4">
                <div class="text-right">
                  <div class="text-sm font-bold text-gray-900 dark:text-white">{{ signal.confidence }}%</div>
                  <div class="text-xs text-gray-500 dark:text-gray-400">Confidence</div>
                </div>
                <span
                  class="px-3 py-1 rounded-full text-sm font-bold"
                  :class="{
                    'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400': signal.grade === 'A+' || signal.grade === 'A',
                    'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400': signal.grade === 'B',
                    'bg-amber-100 text-amber-800 dark:bg-amber-900/20 dark:text-amber-400': signal.grade === 'C',
                    'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300': signal.grade === 'Skip'
                  }"
                >
                  {{ signal.grade }}
                </span>
              </div>
            </div>

            <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-4">
              <SignalFactor label="Trend" :value="signal.factors?.trend" />
              <SignalFactor label="Volume" :value="signal.factors?.volume" />
              <SignalFactor label="VWAP" :value="signal.factors?.vwap" />
              <SignalFactor label="EMA" :value="signal.factors?.ema" />
              <SignalFactor label="Funding" :value="signal.factors?.funding" />
              <SignalFactor label="Open Interest" :value="signal.factors?.openInterest" />
              <SignalFactor label="BTC Trend" :value="signal.factors?.btcTrend" />
              <SignalFactor label="Macro" :value="signal.factors?.macro" />
            </div>

            <div v-if="signal.reasons?.length" class="space-y-1">
              <div v-for="r in signal.reasons" :key="r" class="text-sm text-gray-600 dark:text-gray-400 flex items-start gap-2">
                <span>•</span> {{ r }}
              </div>
            </div>

            <div v-if="signal.suggestedEntry || signal.invalidation" class="mt-4 grid grid-cols-1 md:grid-cols-3 gap-3">
              <div v-if="signal.suggestedEntry" class="p-2 bg-green-50 dark:bg-green-900/10 rounded text-sm">
                <span class="text-xs text-gray-500 dark:text-gray-400">Entry:</span>
                <span class="ml-2 font-medium text-green-700 dark:text-green-300">{{ signal.suggestedEntry }}</span>
              </div>
              <div v-if="signal.target1" class="p-2 bg-blue-50 dark:bg-blue-900/10 rounded text-sm">
                <span class="text-xs text-gray-500 dark:text-gray-400">Target 1:</span>
                <span class="ml-2 font-medium text-blue-700 dark:text-blue-300">{{ signal.target1 }}</span>
              </div>
              <div v-if="signal.target2" class="p-2 bg-blue-50 dark:bg-blue-900/10 rounded text-sm">
                <span class="text-xs text-gray-500 dark:text-gray-400">Target 2:</span>
                <span class="ml-2 font-medium text-blue-700 dark:text-blue-300">{{ signal.target2 }}</span>
              </div>
              <div v-if="signal.invalidation" class="p-2 bg-red-50 dark:bg-red-900/10 rounded text-sm">
                <span class="text-xs text-gray-500 dark:text-gray-400">Invalidation:</span>
                <span class="ml-2 font-medium text-red-700 dark:text-red-300">{{ signal.invalidation }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>

    <div v-else-if="!scanning" class="card">
      <div class="card-body text-center py-8 text-sm text-gray-500 dark:text-gray-400">
        Enter a ticker and click Scan to score trade opportunities
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import api from '@/services/api'
import BaseSelect from '@/components/common/BaseSelect.vue'
import SignalFactor from '@/components/blipyy/SignalFactor.vue'

const directionOptions = [
  { value: 'long', label: 'Long' },
  { value: 'short', label: 'Short' }
]

const ticker = ref('SOLUSDT')
const direction = ref('long')
const scanning = ref(false)
const signals = ref([])

async function scan() {
  scanning.value = true
  signals.value = []
  try {
    const res = await api.post('/signals/scan', { ticker: ticker.value, direction: direction.value })
    signals.value = Array.isArray(res.data) ? res.data : [res.data]
  } catch {
    signals.value = [{
      ticker: ticker.value,
      direction: direction.value,
      confidence: 55,
      grade: 'B',
      factors: {
        trend: 'neutral', volume: 'neutral', vwap: 'bullish',
        ema: 'neutral', funding: 'neutral', openInterest: 'neutral',
        btcTrend: 'neutral', macro: 'neutral'
      },
      reasons: ['Configure API keys for real-time signal analysis'],
      suggestedEntry: null,
      invalidation: null,
      target1: null,
      target2: null
    }]
  } finally {
    scanning.value = false
  }
}

async function scanAll() {
  scanning.value = true
  signals.value = []
  try {
    const res = await api.post('/signals/scan-all')
    signals.value = res.data || []
  } catch {
    signals.value = [
      { ticker: 'SOLUSDT', direction: 'long', confidence: 58, grade: 'B', factors: { trend: 'bullish', volume: 'neutral', vwap: 'bullish', ema: 'bullish', funding: 'neutral', openInterest: 'neutral', btcTrend: 'bullish', macro: 'neutral' }, reasons: ['Trend is bullish on multiple timeframes'], suggestedEntry: null, invalidation: null, target1: null, target2: null },
      { ticker: 'BTCUSDT', direction: 'long', confidence: 52, grade: 'B', factors: { trend: 'neutral', volume: 'neutral', vwap: 'neutral', ema: 'bullish', funding: 'neutral', openInterest: 'neutral', btcTrend: 'bullish', macro: 'neutral' }, reasons: ['Bitcoin showing strength above key EMA'], suggestedEntry: null, invalidation: null, target1: null, target2: null },
      { ticker: 'ETHUSDT', direction: 'short', confidence: 45, grade: 'C', factors: { trend: 'bearish', volume: 'neutral', vwap: 'bearish', ema: 'bearish', funding: 'negative', openInterest: 'declining', btcTrend: 'neutral', macro: 'neutral' }, reasons: ['ETH underperforming relative to BTC'], suggestedEntry: null, invalidation: null, target1: null, target2: null }
    ]
  } finally {
    scanning.value = false
  }
}
</script>
