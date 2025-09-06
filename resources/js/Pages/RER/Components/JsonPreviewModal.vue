<template>
    <TransitionRoot :show="show" as="template">
        <Dialog as="div" class="relative z-50" @close="$emit('close')">
            <TransitionChild
                as="template"
                enter="ease-out duration-300"
                enter-from="opacity-0"
                enter-to="opacity-100"
                leave="ease-in duration-200"
                leave-from="opacity-100"
                leave-to="opacity-0"
            >
                <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" />
            </TransitionChild>

            <div class="fixed inset-0 z-10 overflow-y-auto">
                <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
                    <TransitionChild
                        as="template"
                        enter="ease-out duration-300"
                        enter-from="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                        enter-to="opacity-100 translate-y-0 sm:scale-100"
                        leave="ease-in duration-200"
                        leave-from="opacity-100 translate-y-0 sm:scale-100"
                        leave-to="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                    >
                        <DialogPanel class="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-4xl">
                            <div class="bg-white">
                                <div class="bg-green-600 px-4 py-3">
                                    <div class="flex items-center justify-between">
                                        <h3 class="text-lg font-medium text-white">
                                            ✓ Filing Submitted Successfully
                                        </h3>
                                        <button
                                            @click="$emit('close')"
                                            type="button"
                                            class="text-white hover:text-gray-200"
                                        >
                                            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                    </div>
                                </div>

                                <div class="px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                                    <div class="mb-4">
                                        <p class="text-sm text-gray-700">
                                            Your Real Estate Report has been successfully validated and submitted. 
                                            Below is the complete JSON representation of your filing data.
                                        </p>
                                        <div v-if="data?.filing_number" class="mt-2 p-3 bg-blue-50 rounded-md">
                                            <p class="text-sm font-medium text-blue-900">
                                                Filing Number: <span class="font-mono">{{ data.filing_number }}</span>
                                            </p>
                                        </div>
                                    </div>

                                    <div class="relative">
                                        <div class="absolute top-2 right-2 z-10">
                                            <button
                                                @click="copyToClipboard"
                                                type="button"
                                                class="inline-flex items-center px-3 py-1 border border-gray-300 shadow-sm text-xs font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                                            >
                                                <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                                                </svg>
                                                {{ copied ? 'Copied!' : 'Copy' }}
                                            </button>
                                        </div>

                                        <div class="bg-gray-900 rounded-lg p-4 overflow-auto max-h-96">
                                            <pre class="text-xs text-gray-300 font-mono"><code>{{ formattedJson }}</code></pre>
                                        </div>
                                    </div>

                                    <div class="mt-4 flex items-center justify-between">
                                        <div class="flex space-x-2">
                                            <button
                                                @click="downloadJson"
                                                type="button"
                                                class="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                                            >
                                                <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                                                </svg>
                                                Download JSON
                                            </button>
                                        </div>

                                        <button
                                            @click="$emit('close')"
                                            type="button"
                                            class="inline-flex justify-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                                        >
                                            Close
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </DialogPanel>
                    </TransitionChild>
                </div>
            </div>
        </Dialog>
    </TransitionRoot>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Dialog, DialogPanel, TransitionChild, TransitionRoot } from '@headlessui/vue'

const props = defineProps({
    show: Boolean,
    data: Object
})

const emit = defineEmits(['close'])

const copied = ref(false)

const formattedJson = computed(() => {
    if (!props.data) return ''
    return JSON.stringify(props.data, null, 2)
})

function copyToClipboard() {
    navigator.clipboard.writeText(formattedJson.value)
    copied.value = true
    setTimeout(() => {
        copied.value = false
    }, 2000)
}

function downloadJson() {
    const blob = new Blob([formattedJson.value], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `RER-Filing-${props.data?.filing_number || 'draft'}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
}
</script>