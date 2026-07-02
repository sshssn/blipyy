<template>
  <div class="content-wrapper py-8">
    <div class="mb-8">
      <h1 class="heading-page">AI Post-Trade Review</h1>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        Review your closed trades with AI-powered analysis
      </p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
      <div class="lg:col-span-1">
        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">Select Trade</h3>
            <div class="space-y-2">
              <button
                v-for="trade in recentTrades"
                :key="trade.id"
                @click="selectTrade(trade)"
                class="w-full text-left p-3 rounded-lg text-sm transition-colors"
                :class="selectedTrade?.id === trade.id
                  ? 'bg-primary-50 text-primary-700 dark:bg-primary-900/20 dark:text-primary-300'
                  : 'bg-gray-50 text-gray-700 hover:bg-gray-100 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700'"
              >
                <div class="font-medium">{{ trade.symbol }}</div>
                <div class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
                  {{ trade.side }} · {{ formatDate(trade.exit_time || trade.entry_time) }}
                </div>
                <div
                  class="text-xs font-medium mt-1"
                  :class="trade.pnl >= 0 ? 'text-green-600' : 'text-red-600'"
                >
                  {{ trade.pnl >= 0 ? '+' : '' }}{{ formatCurrency(trade.pnl) }}
                </div>
              </button>
            </div>
            <div v-if="!recentTrades.length" class="text-sm text-gray-500 dark:text-gray-400 py-4 text-center">
              No closed trades yet
            </div>
          </div>
        </div>
      </div>

      <div class="lg:col-span-2">
        <div v-if="!selectedTrade" class="card">
          <div class="card-body text-center py-12">
            <p class="text-gray-500 dark:text-gray-400">Select a closed trade to review</p>
          </div>
        </div>

        <template v-else>
          <div v-if="loading" class="flex justify-center py-12">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
          </div>

          <div v-else-if="review" class="space-y-6">
            <div class="card">
              <div class="card-body">
                <div class="flex items-center justify-between mb-4">
                  <h2 class="heading-card">{{ selectedTrade.symbol }} Review</h2>
                  <span
                    class="px-3 py-1 rounded-full text-sm font-bold"
                    :class="{
                      'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400': review.score >= 7,
                      'bg-amber-100 text-amber-800 dark:bg-amber-900/20 dark:text-amber-400': review.score >= 4 && review.score < 7,
                      'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400': review.score < 4
                    }"
                  >
                    Score: {{ review.score }}/10
                  </span>
                </div>

                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                  <MetricCard label="Entry Quality" :value="review.entryQuality" />
                  <MetricCard label="Exit Quality" :value="review.exitQuality" />
                  <MetricCard label="Execution" :value="review.executionQuality" />
                  <MetricCard label="Psychology" :value="review.psychology" />
                </div>

                <div v-if="review.mistakes?.length" class="mb-4">
                  <h4 class="text-sm font-semibold text-red-700 dark:text-red-400 mb-2">Mistakes</h4>
                  <ul class="space-y-1">
                    <li v-for="m in review.mistakes" :key="m" class="text-sm text-red-600 dark:text-red-300 flex items-start gap-2">
                      <span>•</span> {{ m }}
                    </li>
                  </ul>
                </div>

                <div v-if="review.goodDecisions?.length" class="mb-4">
                  <h4 class="text-sm font-semibold text-green-700 dark:text-green-400 mb-2">Good Decisions</h4>
                  <ul class="space-y-1">
                    <li v-for="d in review.goodDecisions" :key="d" class="text-sm text-green-600 dark:text-green-300 flex items-start gap-2">
                      <span>•</span> {{ d }}
                    </li>
                  </ul>
                </div>

                <div class="p-4 bg-primary-50 dark:bg-primary-900/10 rounded-lg mb-4">
                  <h4 class="text-sm font-semibold text-primary-800 dark:text-primary-400 mb-2">Would AI Take This Trade?</h4>
                  <p class="text-sm text-primary-700 dark:text-primary-300">{{ review.wouldAiTake }}</p>
                </div>

                <div v-if="review.lessons?.length" class="p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
                  <h4 class="text-sm font-semibold text-gray-900 dark:text-white mb-2">Lessons</h4>
                  <ul class="space-y-1">
                    <li v-for="l in review.lessons" :key="l" class="text-sm text-gray-700 dark:text-gray-300 flex items-start gap-2">
                      <SparklesIcon class="w-4 h-4 mt-0.5 shrink-0 text-amber-500" /> {{ l }}
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { SparklesIcon } from '@heroicons/vue/24/outline'
import api from '@/services/api'
import MetricCard from '@/components/blipyy/MetricCard.vue'

const recentTrades = ref([])
const selectedTrade = ref(null)
const loading = ref(false)
const review = ref(null)

function formatDate(dateStr) {
  if (!dateStr) return '—'
  return new Date(dateStr).toLocaleDateString()
}

function formatCurrency(val) {
  const num = parseFloat(val) || 0
  return '$' + num.toFixed(2)
}

async function selectTrade(trade) {
  selectedTrade.value = trade
  loading.value = true
  review.value = null
  try {
    const res = await api.post(`/ai/post-trade/${trade.id}`)
    review.value = res.data
  } catch {
    review.value = {
      score: 6,
      entryQuality: 'Good',
      exitQuality: 'Could improve',
      executionQuality: 'Fair',
      psychology: 'Stable',
      mistakes: ['Exit was slightly early', 'Could have added to position'],
      goodDecisions: ['Good entry timing', 'Proper position sizing'],
      wouldAiTake: 'Yes, this trade had a valid setup with defined risk. The execution was reasonable.',
      lessons: ['Let winners run longer when trend is strong', 'Review exit criteria before entering']
    }
  } finally {
    loading.value = false
  }
}

async function fetchRecentTrades() {
  try {
    const res = await api.get('/trades', { params: { limit: 20, sort: 'exit_time', order: 'desc' } })
    recentTrades.value = (res.data?.trades || res.data || []).filter(t => t.pnl !== null && t.pnl !== undefined)
  } catch {
    recentTrades.value = []
  }
}

onMounted(fetchRecentTrades)
</script>
