<template>
  <div class="content-wrapper py-8">
    <div class="mb-8">
      <h1 class="heading-page">Rule Engine</h1>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        Define custom trading rules. Get warned when you violate them.
      </p>
    </div>

    <!-- Add Rule -->
    <div class="card mb-6">
      <div class="card-body">
        <h2 class="heading-card mb-4">Add Rule</h2>
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div class="md:col-span-2">
            <label class="label">Rule Description</label>
            <input v-model="newRule.description" class="input" placeholder="e.g., Never trade before FOMC" />
          </div>
          <div>
            <label class="label">Type</label>
            <BaseSelect v-model="newRule.type" :options="ruleTypes" />
          </div>
          <div class="flex items-end">
            <button @click="addRule" class="btn-primary w-full">Add Rule</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Active Rules -->
    <div class="space-y-3">
      <div
        v-for="rule in rules"
        :key="rule.id"
        class="card"
        :class="{ 'opacity-60': !rule.active }"
      >
        <div class="card-body">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <ShieldCheckIcon
                class="w-5 h-5"
                :class="rule.active ? 'text-green-500' : 'text-gray-400'"
              />
              <div>
                <p class="text-sm font-medium text-gray-900 dark:text-white">{{ rule.description }}</p>
                <p class="text-xs text-gray-500 dark:text-gray-400">{{ rule.type }} rule</p>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <span
                v-if="rule.violated"
                class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400"
              >
                Violated
              </span>
              <button
                @click="toggleRule(rule)"
                class="text-sm text-primary-600 hover:text-primary-700 dark:text-primary-400"
              >
                {{ rule.active ? 'Pause' : 'Enable' }}
              </button>
              <button
                @click="deleteRule(rule.id)"
                class="text-sm text-red-600 hover:text-red-700 dark:text-red-400"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="!rules.length" class="card">
      <div class="card-body text-center py-8 text-sm text-gray-500 dark:text-gray-400">
        No rules defined yet. Add your first rule above.
      </div>
    </div>

    <!-- Presets -->
    <div class="card mt-6">
      <div class="card-body">
        <h3 class="heading-card mb-4">Preset Rules</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
          <button
            v-for="preset in presets"
            :key="preset.description"
            @click="addPreset(preset)"
            class="text-left p-3 rounded-lg bg-gray-50 dark:bg-gray-800 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          >
            <p class="text-sm font-medium text-gray-900 dark:text-white">{{ preset.description }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">{{ preset.type }}</p>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ShieldCheckIcon } from '@heroicons/vue/24/outline'
import api from '@/services/api'
import BaseSelect from '@/components/common/BaseSelect.vue'

const ruleTypes = [
  { value: 'pre-trade', label: 'Pre-Trade' },
  { value: 'risk', label: 'Risk Management' },
  { value: 'behavioral', label: 'Behavioral' },
  { value: 'custom', label: 'Custom' }
]

const rules = ref([])
const newRule = ref({ description: '', type: 'custom' })

const presets = [
  { description: 'Never trade before FOMC', type: 'pre-trade' },
  { description: 'Maximum two trades per day', type: 'behavioral' },
  { description: 'Stop trading after two consecutive losses', type: 'risk' },
  { description: 'Only trade during NY session', type: 'pre-trade' },
  { description: 'Only trade SOLUSDT', type: 'custom' },
  { description: 'Only trade with BTC trend', type: 'pre-trade' },
  { description: 'Minimum RR ratio of 2:1', type: 'risk' },
  { description: 'No trading within 30 minutes of high-impact news', type: 'pre-trade' }
]

async function fetchRules() {
  try {
    const res = await api.get('/rules')
    rules.value = res.data || []
  } catch {
    rules.value = []
  }
}

async function addRule() {
  if (!newRule.value.description.trim()) return
  try {
    const res = await api.post('/rules', newRule.value)
    rules.value.push(res.data)
  } catch {
    rules.value.push({
      id: Date.now(),
      description: newRule.value.description,
      type: newRule.value.type,
      active: true,
      violated: false
    })
  }
  newRule.value = { description: '', type: 'custom' }
}

function addPreset(preset) {
  newRule.value = { description: preset.description, type: preset.type }
  addRule()
}

async function toggleRule(rule) {
  try {
    await api.patch(`/rules/${rule.id}`, { active: !rule.active })
    rule.active = !rule.active
  } catch {
    rule.active = !rule.active
  }
}

async function deleteRule(id) {
  try {
    await api.delete(`/rules/${id}`)
    rules.value = rules.value.filter(r => r.id !== id)
  } catch {
    rules.value = rules.value.filter(r => r.id !== id)
  }
}

onMounted(fetchRules)
</script>
