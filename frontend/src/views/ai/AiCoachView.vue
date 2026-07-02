<template>
  <div class="content-wrapper py-8">
    <div class="mb-8">
      <h1 class="heading-page">AI Coach</h1>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        Your personal trading mentor that learns from YOUR history
      </p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-6">
        <!-- Coach Insights -->
        <div class="card">
          <div class="card-body">
            <div class="flex items-center justify-between mb-4">
              <h2 class="heading-card">Insights</h2>
              <button
                @click="refreshInsights"
                class="text-sm text-primary-600 hover:text-primary-700 dark:text-primary-400"
              >
                Refresh
              </button>
            </div>

            <div v-if="coachLoading" class="flex justify-center py-8">
              <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600"></div>
            </div>

            <div v-else class="space-y-4">
              <div
                v-for="insight in insights"
                :key="insight.title"
                class="p-4 rounded-lg"
                :class="{
                  'bg-red-50 dark:bg-red-900/10 border border-red-200 dark:border-red-800': insight.type === 'warning',
                  'bg-green-50 dark:bg-green-900/10 border border-green-200 dark:border-green-800': insight.type === 'positive',
                  'bg-blue-50 dark:bg-blue-900/10 border border-blue-200 dark:border-blue-800': insight.type === 'insight',
                  'bg-amber-50 dark:bg-amber-900/10 border border-amber-200 dark:border-amber-800': insight.type === 'pattern'
                }"
              >
                <div class="flex items-start gap-3">
                  <ExclamationTriangleIcon v-if="insight.type === 'warning'" class="w-5 h-5 mt-0.5 text-red-500 shrink-0" />
                  <ChartBarIcon v-if="insight.type === 'positive'" class="w-5 h-5 mt-0.5 text-green-500 shrink-0" />
                  <LightBulbIcon v-if="insight.type === 'insight'" class="w-5 h-5 mt-0.5 text-blue-500 shrink-0" />
                  <SparklesIcon v-if="insight.type === 'pattern'" class="w-5 h-5 mt-0.5 text-amber-500 shrink-0" />
                  <div>
                    <h4 class="text-sm font-semibold mb-1" :class="{
                      'text-red-800 dark:text-red-300': insight.type === 'warning',
                      'text-green-800 dark:text-green-300': insight.type === 'positive',
                      'text-blue-800 dark:text-blue-300': insight.type === 'insight',
                      'text-amber-800 dark:text-amber-300': insight.type === 'pattern'
                    }">{{ insight.title }}</h4>
                    <p class="text-sm" :class="{
                      'text-red-700 dark:text-red-400': insight.type === 'warning',
                      'text-green-700 dark:text-green-400': insight.type === 'positive',
                      'text-blue-700 dark:text-blue-400': insight.type === 'insight',
                      'text-amber-700 dark:text-amber-400': insight.type === 'pattern'
                    }">{{ insight.description }}</p>
                  </div>
                </div>
              </div>
            </div>

            <div v-if="!insights.length && !coachLoading" class="text-center py-8 text-sm text-gray-500 dark:text-gray-400">
              Trade more to unlock personalized AI coaching insights.
            </div>
          </div>
        </div>

        <!-- Chat with Coach -->
        <div class="card">
          <div class="card-body">
            <h2 class="heading-card mb-4">Ask Your Coach</h2>
            <div class="space-y-4 mb-4 max-h-96 overflow-y-auto">
              <div v-for="msg in chatMessages" :key="msg.id" class="flex" :class="msg.role === 'user' ? 'justify-end' : 'justify-start'">
                <div
                  class="max-w-[80%] rounded-lg px-4 py-2 text-sm"
                  :class="msg.role === 'user'
                    ? 'bg-primary-600 text-white'
                    : 'bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-white'"
                >
                  {{ msg.content }}
                </div>
              </div>
            </div>
            <div class="flex gap-2">
              <input
                v-model="chatInput"
                @keydown.enter="sendChat"
                class="input flex-1"
                placeholder="Ask your coach anything..."
              />
              <button @click="sendChat" class="btn-primary" :disabled="!chatInput.trim() || chatLoading">
                Send
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Stats Sidebar -->
      <div class="space-y-6">
        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">Your Profile</h3>
            <div class="space-y-3">
              <ProfileStat label="Total Trades" :value="stats.totalTrades" />
              <ProfileStat label="Win Rate" :value="stats.winRate + '%'" />
              <ProfileStat label="Avg R Multiple" :value="stats.avgR" />
              <ProfileStat label="Best Session" :value="stats.bestSession" />
              <ProfileStat label="Worst Day" :value="stats.worstDay" />
              <ProfileStat label="Common Mistake" :value="stats.commonMistake" />
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">Patterns Detected</h3>
            <div v-if="patterns.length" class="space-y-2">
              <div v-for="p in patterns" :key="p" class="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
                <SparklesIcon class="w-4 h-4 text-amber-500 shrink-0" />
                {{ p }}
              </div>
            </div>
            <p v-else class="text-sm text-gray-500 dark:text-gray-400">More data needed for pattern detection</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ExclamationTriangleIcon, SparklesIcon, ChartBarIcon } from '@heroicons/vue/24/outline'
import { LightBulbIcon } from '@heroicons/vue/24/solid'
import api from '@/services/api'
import ProfileStat from '@/components/blipyy/ProfileStat.vue'

const chatInput = ref('')
const chatMessages = ref([])
const chatLoading = ref(false)
const coachLoading = ref(true)
const insights = ref([])
const patterns = ref([])
const stats = ref({
  totalTrades: 0,
  winRate: 0,
  avgR: 0,
  bestSession: '—',
  worstDay: '—',
  commonMistake: '—'
})

async function fetchCoachData() {
  coachLoading.value = true
  try {
    const res = await api.get('/ai/coach')
    if (res.data) {
      insights.value = res.data.insights || []
      patterns.value = res.data.patterns || []
      stats.value = { ...stats.value, ...res.data.stats }
    }
  } catch {
    insights.value = [
      { type: 'insight', title: 'Welcome to AI Coach', description: 'As you log more trades, your coach will learn your patterns and provide personalized insights to improve your trading.' }
    ]
  } finally {
    coachLoading.value = false
  }
}

async function sendChat() {
  if (!chatInput.value.trim() || chatLoading.value) return
  const msg = chatInput.value.trim()
  chatInput.value = ''
  chatMessages.value.push({ id: Date.now(), role: 'user', content: msg })
  chatLoading.value = true
  try {
    const res = await api.post('/ai/coach/chat', { message: msg })
    chatMessages.value.push({ id: Date.now() + 1, role: 'assistant', content: res.data.response })
  } catch {
    chatMessages.value.push({ id: Date.now() + 1, role: 'assistant', content: 'I need more data to answer that. Keep trading and logging your trades — I learn from every one of them.' })
  } finally {
    chatLoading.value = false
  }
}

function refreshInsights() {
  fetchCoachData()
}

onMounted(fetchCoachData)
</script>
