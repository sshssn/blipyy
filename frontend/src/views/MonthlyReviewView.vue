<template>
  <div class="content-wrapper py-8">
    <div class="mb-8">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="heading-page">Monthly Review</h1>
          <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
            Professional monthly performance report
          </p>
        </div>
        <button
          @click="exportPdf"
          class="btn-primary inline-flex items-center gap-2"
        >
          <ArrowDownTrayIcon class="w-4 h-4" />
          Export PDF
        </button>
      </div>
    </div>

    <div v-if="loading" class="flex justify-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
    </div>

    <template v-else>
      <!-- Equity Curve -->
      <div class="card mb-6">
        <div class="card-body">
          <h3 class="heading-card mb-4">Equity Curve</h3>
          <div class="h-64 bg-gray-50 dark:bg-gray-800 rounded-lg flex items-center justify-center">
            <p class="text-sm text-gray-500 dark:text-gray-400">Equity chart renders here</p>
          </div>
        </div>
      </div>

      <!-- Key Metrics -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <MetricCard label="Total Trades" :value="report.totalTrades" />
        <MetricCard label="Win Rate" :value="report.winRate + '%'" />
        <MetricCard label="Profit Factor" :value="report.profitFactor" />
        <MetricCard label="Net P&L" :value="report.netPnl" :type="report.netPnl >= 0 ? 'positive' : 'negative'" />
        <MetricCard label="Expectancy" :value="report.expectancy" />
        <MetricCard label="Avg R" :value="report.avgR" />
        <MetricCard label="Max Drawdown" :value="report.maxDrawdown + '%'" type="negative" />
        <MetricCard label="Sharpe" :value="report.sharpe" />
      </div>

      <!-- Heatmap -->
      <div class="card mb-6">
        <div class="card-body">
          <h3 class="heading-card mb-4">Performance Calendar</h3>
          <div class="grid grid-cols-7 gap-1">
            <div
              v-for="day in calendar"
              :key="day.date"
              class="aspect-square rounded flex items-center justify-center text-xs font-medium"
              :class="day.pnl > 0 ? 'bg-green-200 dark:bg-green-800 text-green-900 dark:text-green-100' :
                       day.pnl < 0 ? 'bg-red-200 dark:bg-red-800 text-red-900 dark:text-red-100' :
                       'bg-gray-100 dark:bg-gray-700 text-gray-400 dark:text-gray-500'"
              :title="`${day.date}: ${day.pnl}`"
            >
              {{ day.day }}
            </div>
          </div>
        </div>
      </div>

      <!-- Performance Breakdown -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">By Day of Week</h3>
            <div class="space-y-2">
              <div v-for="d in report.byDay" :key="d.day" class="flex items-center justify-between p-2 bg-gray-50 dark:bg-gray-800 rounded">
                <span class="text-sm text-gray-700 dark:text-gray-300">{{ d.day }}</span>
                <span class="text-sm font-medium" :class="d.pnl >= 0 ? 'text-green-600' : 'text-red-600'">
                  {{ d.pnl >= 0 ? '+' : '' }}{{ d.pnl }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">By Session</h3>
            <div class="space-y-2">
              <div v-for="s in report.bySession" :key="s.name" class="flex items-center justify-between p-2 bg-gray-50 dark:bg-gray-800 rounded">
                <span class="text-sm text-gray-700 dark:text-gray-300">{{ s.name }}</span>
                <span class="text-sm font-medium" :class="s.pnl >= 0 ? 'text-green-600' : 'text-red-600'">
                  {{ s.pnl >= 0 ? '+' : '' }}{{ s.pnl }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">By Setup</h3>
            <div class="space-y-2">
              <div v-for="s in report.bySetup" :key="s.name" class="flex items-center justify-between p-2 bg-gray-50 dark:bg-gray-800 rounded">
                <span class="text-sm text-gray-700 dark:text-gray-300">{{ s.name }}</span>
                <span class="text-sm font-medium" :class="s.pnl >= 0 ? 'text-green-600' : 'text-red-600'">
                  {{ s.pnl >= 0 ? '+' : '' }}{{ s.pnl }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-body">
            <h3 class="heading-card mb-4">By Emotion</h3>
            <div class="space-y-2">
              <div v-for="e in report.byEmotion" :key="e.name" class="flex items-center justify-between p-2 bg-gray-50 dark:bg-gray-800 rounded">
                <span class="text-sm text-gray-700 dark:text-gray-300">{{ e.name }}</span>
                <span class="text-sm font-medium" :class="e.pnl >= 0 ? 'text-green-600' : 'text-red-600'">
                  {{ e.pnl >= 0 ? '+' : '' }}{{ e.pnl }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ArrowDownTrayIcon } from '@heroicons/vue/24/outline'
import api from '@/services/api'
import MetricCard from '@/components/blipyy/MetricCard.vue'

const loading = ref(true)
const calendar = ref([])
const report = ref({
  totalTrades: 0,
  winRate: 0,
  profitFactor: 0,
  netPnl: 0,
  expectancy: 0,
  avgR: 0,
  maxDrawdown: 0,
  sharpe: 0,
  byDay: [],
  bySession: [],
  bySetup: [],
  byEmotion: []
})

async function fetchReport() {
  loading.value = true
  try {
    const res = await api.get('/analytics/monthly-review')
    if (res.data) {
      report.value = { ...report.value, ...res.data }
      calendar.value = res.data.calendar || generateCalendar()
    }
  } catch {
    calendar.value = generateCalendar()
  } finally {
    loading.value = false
  }
}

function generateCalendar() {
  const days = []
  const now = new Date()
  const firstDay = new Date(now.getFullYear(), now.getMonth(), 1)
  const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  for (let d = firstDay; d <= lastDay; d.setDate(d.getDate() + 1)) {
    days.push({
      date: d.toISOString().split('T')[0],
      day: d.getDate(),
      pnl: 0
    })
  }
  return days
}

function exportPdf() {
  window.open('/api/analytics/monthly-review/pdf', '_blank')
}

onMounted(fetchReport)
</script>
