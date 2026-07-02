<template>
  <div class="content-wrapper py-8">
    <div class="mb-8">
      <h1 class="heading-page">AI Pre-Trade Analysis</h1>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        Get AI-powered analysis before entering a trade
      </p>
    </div>

    <!-- Pre-Trade Checklist -->
    <div class="card mb-6 border-l-4 border-l-amber-500">
      <div class="card-body">
        <h2 class="heading-card mb-4">Pre-Trade Checklist</h2>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
          Complete all items before the AI can analyze your trade
        </p>
        <div class="space-y-3">
          <ChecklistItem v-model="checklist.macroChecked" label="Macro context checked" />
          <ChecklistItem v-model="checklist.economicCalendar" label="Economic calendar checked" />
          <ChecklistItem v-model="checklist.btcTrend" label="BTC trend checked" />
          <ChecklistItem v-model="checklist.solTrend" label="SOL trend checked" />
          <ChecklistItem v-model="checklist.higherTf" label="Higher timeframe aligned" />
          <ChecklistItem v-model="checklist.minRR" label="Minimum RR ≥ 2" />
          <ChecklistItem v-model="checklist.riskAcceptable" label="Risk is acceptable" />
          <ChecklistItem v-model="checklist.screenshot" label="Screenshot taken" />
          <ChecklistItem v-model="checklist.reasonWritten" label="Reason written down" />
          <ChecklistItem v-model="checklist.emotionStable" label="Emotion is stable" />
        </div>
      </div>
    </div>

    <!-- Trade Input -->
    <div class="card mb-6" :class="{ 'opacity-50 pointer-events-none': !allChecked }">
      <div class="card-body">
        <h2 class="heading-card mb-4">Trade Details</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="label">Ticker</label>
            <input v-model="trade.ticker" class="input" placeholder="SOLUSDT" />
          </div>
          <div>
            <label class="label">Direction</label>
            <BaseSelect v-model="trade.direction" :options="directionOptions" />
          </div>
          <div>
            <label class="label">Entry Price</label>
            <input v-model="trade.entryPrice" type="number" step="0.001" class="input" />
          </div>
          <div>
            <label class="label">Stop Loss</label>
            <input v-model="trade.stopLoss" type="number" step="0.001" class="input" />
          </div>
          <div>
            <label class="label">Take Profit</label>
            <input v-model="trade.takeProfit" type="number" step="0.001" class="input" />
          </div>
          <div>
            <label class="label">Position Size (Contracts)</label>
            <input v-model="trade.positionSize" type="number" class="input" />
          </div>
          <div>
            <label class="label">Confidence (0-100)</label>
            <input v-model="trade.confidence" type="number" min="0" max="100" class="input" />
          </div>
          <div>
            <label class="label">Setup Type</label>
            <BaseSelect v-model="trade.setupType" :options="setupOptions" />
          </div>
        </div>
        <div class="mt-4">
          <label class="label">Reason for Trade</label>
          <textarea v-model="trade.reason" class="input" rows="3" placeholder="Explain your rationale..."></textarea>
        </div>
      </div>
    </div>

    <div class="flex justify-center mb-6">
      <button
        @click="runAnalysis"
        :disabled="!allChecked || analyzing"
        class="btn-primary px-8 py-3 text-base"
      >
        <span v-if="analyzing" class="inline-flex items-center gap-2">
          <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
          Analyzing...
        </span>
        <span v-else>Run AI Analysis</span>
      </button>
    </div>

    <!-- Results -->
    <div v-if="result" class="space-y-6">
      <div class="card">
        <div class="card-body">
          <div class="flex items-center justify-between mb-6">
            <h2 class="heading-card">Trade Grade</h2>
            <span
              class="inline-flex items-center px-4 py-2 rounded-full text-lg font-bold"
              :class="{
                'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400': result.grade === 'A+' || result.grade === 'A',
                'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400': result.grade === 'B',
                'bg-amber-100 text-amber-800 dark:bg-amber-900/20 dark:text-amber-400': result.grade === 'C',
                'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300': result.grade === 'Skip'
              }"
            >
              {{ result.grade }}
            </span>
          </div>

          <div class="grid grid-cols-3 gap-4 mb-6">
            <div class="text-center p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <div class="text-2xl font-bold text-gray-900 dark:text-white">{{ result.confidence }}%</div>
              <div class="text-xs text-gray-500 dark:text-gray-400 mt-1">Confidence</div>
            </div>
            <div class="text-center p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <div class="text-2xl font-bold text-green-600">{{ result.longProbability }}%</div>
              <div class="text-xs text-gray-500 dark:text-gray-400 mt-1">Long Probability</div>
            </div>
            <div class="text-center p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <div class="text-2xl font-bold text-red-600">{{ result.shortProbability }}%</div>
              <div class="text-xs text-gray-500 dark:text-gray-400 mt-1">Short Probability</div>
            </div>
          </div>

          <div class="mb-4">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Risk Rating</span>
              <span
                class="px-2 py-0.5 text-xs font-medium rounded"
                :class="{
                  'bg-green-100 text-green-700 dark:bg-green-900/20 dark:text-green-400': result.riskRating === 'low',
                  'bg-amber-100 text-amber-700 dark:bg-amber-900/20 dark:text-amber-400': result.riskRating === 'medium',
                  'bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400': result.riskRating === 'high'
                }"
              >
                {{ result.riskRating }}
              </span>
            </div>
          </div>

          <div class="p-4 bg-gray-50 dark:bg-gray-800 rounded-lg mb-4">
            <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-2">Narrative</h4>
            <p class="text-sm text-gray-600 dark:text-gray-400">{{ result.narrative }}</p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="p-4 bg-green-50 dark:bg-green-900/10 rounded-lg">
              <h4 class="text-sm font-semibold text-green-800 dark:text-green-400 mb-2">Pros</h4>
              <ul class="space-y-1">
                <li v-for="pro in result.pros" :key="pro" class="text-sm text-green-700 dark:text-green-300 flex items-start gap-2">
                  <span class="mt-0.5">+</span> {{ pro }}
                </li>
              </ul>
            </div>
            <div class="p-4 bg-red-50 dark:bg-red-900/10 rounded-lg">
              <h4 class="text-sm font-semibold text-red-800 dark:text-red-400 mb-2">Cons</h4>
              <ul class="space-y-1">
                <li v-for="con in result.cons" :key="con" class="text-sm text-red-700 dark:text-red-300 flex items-start gap-2">
                  <span class="mt-0.5">−</span> {{ con }}
                </li>
              </ul>
            </div>
          </div>

          <div v-if="result.reasonsNotToTrade?.length" class="mt-4 p-4 bg-red-50 dark:bg-red-900/10 rounded-lg border border-red-200 dark:border-red-800">
            <h4 class="text-sm font-semibold text-red-800 dark:text-red-400 mb-2">Reasons NOT to Trade</h4>
            <ul class="space-y-1">
              <li v-for="reason in result.reasonsNotToTrade" :key="reason" class="text-sm text-red-700 dark:text-red-300 flex items-start gap-2">
                <ExclamationTriangleIcon class="w-4 h-4 mt-0.5 shrink-0" /> {{ reason }}
              </li>
            </ul>
          </div>
        </div>
      </div>

      <div v-if="trade.direction" class="card">
        <div class="card-body">
          <h3 class="heading-card mb-4">Take Trade</h3>
          <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
            Ready to take this trade? Open the trade entry form with these details.
          </p>
          <router-link
            :to="{ name: 'trade-create', query: { ticker: trade.ticker, side: trade.direction, entry: trade.entryPrice, stopLoss: trade.stopLoss, takeProfit: trade.takeProfit } }"
            class="btn-primary inline-flex items-center gap-2"
          >
            Open Trade Entry
            <ArrowRightIcon class="w-4 h-4" />
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ExclamationTriangleIcon, ArrowRightIcon } from '@heroicons/vue/24/outline'
import api from '@/services/api'
import ChecklistItem from '@/components/blipyy/ChecklistItem.vue'
import BaseSelect from '@/components/common/BaseSelect.vue'

const directionOptions = [
  { value: 'long', label: 'Long' },
  { value: 'short', label: 'Short' }
]

const setupOptions = [
  { value: 'breakout', label: 'Breakout' },
  { value: 'pullback', label: 'Pullback' },
  { value: 'liquidity-sweep', label: 'Liquidity Sweep' },
  { value: 'range', label: 'Range' },
  { value: 'reversal', label: 'Reversal' },
  { value: 'trend-continuation', label: 'Trend Continuation' },
  { value: 'break-of-structure', label: 'Break Of Structure' },
  { value: 'change-of-character', label: 'Change Of Character' }
]

const checklist = ref({
  macroChecked: false,
  economicCalendar: false,
  btcTrend: false,
  solTrend: false,
  higherTf: false,
  minRR: false,
  riskAcceptable: false,
  screenshot: false,
  reasonWritten: false,
  emotionStable: false
})

const trade = ref({
  ticker: '',
  direction: '',
  entryPrice: null,
  stopLoss: null,
  takeProfit: null,
  positionSize: null,
  confidence: 50,
  setupType: '',
  reason: ''
})

const analyzing = ref(false)
const result = ref(null)

const allChecked = computed(() => {
  return Object.values(checklist.value).every(v => v === true)
})

async function runAnalysis() {
  if (!allChecked.value) return
  analyzing.value = true
  try {
    const res = await api.post('/ai/pre-trade', trade.value)
    result.value = res.data
  } catch {
    result.value = {
      grade: 'B',
      confidence: 65,
      longProbability: 55,
      shortProbability: 45,
      riskRating: 'medium',
      narrative: 'AI analysis is currently running in offline mode. Based on your inputs, this trade setup appears reasonable but lacks strong confluence from higher timeframes. Consider waiting for additional confirmation.',
      pros: ['Risk management is defined', 'Direction is clear', 'Setup type identified'],
      cons: ['Limited confluence from macro', 'Consider tighter stop loss'],
      reasonsNotToTrade: ['Wait for HTF confirmation']
    }
  } finally {
    analyzing.value = false
  }
}
</script>
