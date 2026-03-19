/**
 * OneMind OS — Application Constants
 *
 * Centralized constants extracted from the Flutter reference implementation.
 * Eliminates magic numbers and improves maintainability.
 *
 * UI-related constants (colors, spacing) are in globals.css.
 */

// ---------------------------------------------------------------------------
// Network & API Configuration
// ---------------------------------------------------------------------------

export const API_TIMEOUTS = {
  /** Standard API request timeout (ms) */
  standard: 30_000,
  /** Long-running requests: file uploads, large queries (ms) */
  long: 120_000,
  /** Quick requests: health checks, pings (ms) */
  quick: 5_000,
  /** SSE/streaming connection timeout (ms) */
  streaming: 1_800_000,
  /** WebSocket connection timeout (ms) */
  websocket: 10_000,
} as const

export const RETRY_CONFIG = {
  maxRetries: 3,
  initialDelayMs: 500,
  backoffMultiplier: 2,
  maxDelayMs: 10_000,
} as const

export const WEBSOCKET_CONFIG = {
  reconnectDelayMs: 3_000,
  maxReconnectAttempts: 5,
  pingIntervalMs: 30_000,
  pongTimeoutMs: 5_000,
} as const

// ---------------------------------------------------------------------------
// Cache Configuration
// ---------------------------------------------------------------------------

export const CACHE_DURATIONS = {
  /** Real-time data (stats, status) */
  veryShort: 60_000,
  /** Frequently updated (sessions, runs) */
  short: 300_000,
  /** Standard API data */
  medium: 1_800_000,
  /** Rarely changing (agents, teams) */
  long: 3_600_000,
  /** Static/reference data (models list) */
  veryLong: 86_400_000,
} as const

/** Resolve cache TTL for an endpoint path */
export function cacheDurationForEndpoint(endpoint: string): number {
  if (/\/(agents|teams)/.test(endpoint)) return CACHE_DURATIONS.long
  if (/\/models/.test(endpoint)) return CACHE_DURATIONS.veryLong
  if (/\/(sessions|runs)/.test(endpoint)) return CACHE_DURATIONS.short
  if (/\/(stats|status)/.test(endpoint)) return CACHE_DURATIONS.veryShort
  return CACHE_DURATIONS.medium
}

export const CACHE_LIMITS = {
  maxEntries: 500,
  maxMemoryMB: 50,
  evictionKeepRatio: 0.7,
} as const

// ---------------------------------------------------------------------------
// Health & Performance Thresholds
// ---------------------------------------------------------------------------

export const HEALTH_THRESHOLDS = {
  biometric: {
    heartRateMin: 50,
    heartRateMax: 120,
    bloodOxygenMin: 95,
    bloodOxygenMax: 100,
  },
  battery: {
    critical: 15,
    low: 30,
    good: 70,
  },
  system: {
    cpuWarning: 70,
    cpuCritical: 90,
    memoryWarning: 75,
    memoryCritical: 90,
  },
  responseTimeMs: {
    fast: 200,
    ok: 1_000,
    slow: 3_000,
    critical: 5_000,
  },
} as const

// ---------------------------------------------------------------------------
// Pagination & Search
// ---------------------------------------------------------------------------

export const LIST_LIMITS = {
  defaultPageSize: 20,
  maxPageSize: 100,
  initialLoadSize: 30,
  loadMoreSize: 20,
  loadMoreThreshold: 5,
} as const

export const SEARCH_CONFIG = {
  minLength: 2,
  debounceMs: 300,
  maxResults: 50,
} as const

// ---------------------------------------------------------------------------
// Animation & UI Timing
// ---------------------------------------------------------------------------

export const ANIMATION_MS = {
  veryFast: 50,
  fast: 100,
  quick: 150,
  normal: 200,
  slow: 300,
  verySlow: 400,
  loadingDelay: 200,
} as const

export const TOAST_DURATION_MS = {
  short: 2_000,
  medium: 4_000,
  long: 6_000,
} as const

export const DEBOUNCE_MS = {
  input: 300,
  search: 500,
  scroll: 150,
  tap: 500,
  apiCall: 1_000,
} as const

// ---------------------------------------------------------------------------
// File Upload Limits
// ---------------------------------------------------------------------------

export const FILE_LIMITS = {
  maxImageSizeMB: 5,
  maxDocumentSizeMB: 10,
  maxUploadSizeMB: 50,
  imageExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'] as const,
  documentExtensions: ['pdf', 'doc', 'docx', 'txt', 'md', 'csv'] as const,
} as const

// ---------------------------------------------------------------------------
// Validation
// ---------------------------------------------------------------------------

export const VALIDATION = {
  name: { min: 1, max: 255 },
  description: { min: 0, max: 1000 },
  emailPattern: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
  urlPattern: /^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_+.~#?&/=]*)$/,
} as const

// ---------------------------------------------------------------------------
// Agent Defaults
// ---------------------------------------------------------------------------

export const AGENT_DEFAULTS = {
  defaultModel: 'gpt-4o',
  defaultName: 'Assistant',
  maxMessageLength: 10_000,
  maxConversationLength: 100,
  markdown: true,
  addHistoryToContext: true,
  numHistoryRuns: 5,
  addDatetimeToContext: true,
  enableSessionSummaries: false,
  enableAgenticState: false,
  updateMemoryOnRun: false,
  enableAgenticMemory: false,
} as const

export const TEAM_DEFAULTS = {
  respondDirectly: false,
  determineInputForMembers: true,
  delegateToAllMembers: false,
  addHistoryToContext: true,
  markdown: true,
} as const

// ---------------------------------------------------------------------------
// Gamification
// ---------------------------------------------------------------------------

export const XP_CONFIG = {
  /** XP needed for next level = level × 1000 */
  xpPerLevel: 1_000,
  dailyOpReward: 50,
  missionReward: 200,
  startingGold: 1_000,
} as const

export const RANKS = [
  { minLevel: 1, name: 'Operative' },
  { minLevel: 10, name: 'Commander' },
  { minLevel: 20, name: 'Overseer' },
] as const

export function getRank(level: number): string {
  for (let i = RANKS.length - 1; i >= 0; i--) {
    if (level >= RANKS[i].minLevel) return RANKS[i].name
  }
  return RANKS[0].name
}

export const DEFAULT_ACHIEVEMENTS = [
  { id: 'a1', title: 'First Login', description: 'Access the system for the first time.', icon: '🔑', category: 'system', xpReward: 50 },
  { id: 'a2', title: 'Task Master', description: 'Complete 10 daily operations.', icon: '✅', category: 'productivity', xpReward: 200 },
  { id: 'a3', title: 'Deep Diver', description: 'Visit all system screens.', icon: '🗺️', category: 'exploration', xpReward: 150 },
  { id: 'a4', title: 'Commander', description: 'Reach Level 10.', icon: '⭐', category: 'mastery', xpReward: 1000 },
  { id: 'a5', title: 'Agent Operator', description: 'Deploy your first agent.', icon: '🤖', category: 'agents', xpReward: 100 },
] as const

export const DEFAULT_SKILL_TREE = [
  { id: 's1', name: 'Voice Command', description: 'Unlock voice-based interactions', icon: '🗣️', branch: 'command', levelRequired: 1 },
  { id: 's2', name: 'Entity Search', description: 'Advanced search filters for assets', icon: '🔍', branch: 'intel', levelRequired: 2 },
  { id: 's3', name: 'NATS Bridge', description: 'Direct NATS message bus access', icon: '🌉', branch: 'engineering', levelRequired: 5 },
  { id: 's4', name: 'Quick Tasks', description: 'Create tasks from chat interface', icon: '⚡', branch: 'combat', levelRequired: 3 },
  { id: 's5', name: 'Asset Tracking', description: 'Real-time GPS tracking on world map', icon: '📍', branch: 'exploration', levelRequired: 1 },
] as const

// ---------------------------------------------------------------------------
// Agent Category Colors (for UI badges)
// ---------------------------------------------------------------------------

export const AGENT_CATEGORY_COLORS = {
  code: '#3B82F6',
  research: '#8B5CF6',
  creative: '#EC4899',
  productivity: '#10B981',
  iot: '#06B6D4',
} as const

// ---------------------------------------------------------------------------
// Game Visualization — Node Types & Colors
// ---------------------------------------------------------------------------

export const GAME_NODE_COLORS = {
  core: '#4ADE80',
  infrastructure: '#06B6D4',
  agent: '#4ADE80',
  tool: '#F97316',
  integration: '#8B5CF6',
  sensor: '#3B82F6',
} as const

export const GAME_STATUS_COLORS = {
  active: '#22C55E',
  offline: '#6B7280',
  alert: '#EF4444',
} as const

export const GAME_LAYOUT = {
  innerOrbitPx: 200,
  outerOrbitPx: 350,
} as const

// ---------------------------------------------------------------------------
// Audio Events
// ---------------------------------------------------------------------------

export const AUDIO_EVENTS = {
  alert: 'critical alerts',
  warning: 'non-critical alerts',
  success: 'positive events (health recovery)',
  click: 'UI interactions',
  connect: 'asset added/online',
  disconnect: 'asset removed/offline',
} as const

export const AUDIO_HEALTH_RULES = {
  /** Play alert when health drops >20% and below 30% */
  alertThreshold: 0.3,
  /** Play warning when health drops >20% and above 30% */
  warningDrop: 0.2,
  /** Play success when health rises >20% and above 80% */
  successThreshold: 0.8,
  successRise: 0.2,
} as const

// ---------------------------------------------------------------------------
// Particle System
// ---------------------------------------------------------------------------

export const PARTICLE_CONFIG = {
  spawnIntervalMs: 300,
  maxParticles: 50,
  burstOnEvent: { min: 10, max: 20 },
  burstOnCritical: { min: 15, max: 20 },
} as const

export const PARTICLE_PALETTES = {
  tactical: ['#00D9FF', '#4ECDC4', '#00A8CC', '#33E0FF'],
  solarpunk: ['#FFB703', '#FFC933', '#FFC300', '#FFAA00', '#FFD166'],
} as const
