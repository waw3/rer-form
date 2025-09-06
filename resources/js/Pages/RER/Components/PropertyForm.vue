<template>
    <div class="space-y-4">
        <div>
            <label class="flex items-center">
                <input
                    v-model="property.no_street_address"
                    type="checkbox"
                    class="rounded border-gray-300 text-indigo-600 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                />
                <span class="ml-2 text-sm text-gray-700">No street address</span>
            </label>
        </div>

        <div v-if="!property.no_street_address">
            <label class="block text-sm font-medium text-gray-700">
                Street Address *
            </label>
            <input
                v-model="property.street_address"
                type="text"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                :required="!property.no_street_address"
            />
        </div>

        <div class="grid grid-cols-3 gap-4">
            <div>
                <label class="block text-sm font-medium text-gray-700">
                    City *
                </label>
                <input
                    v-model="property.city"
                    type="text"
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                    required
                />
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">
                    State *
                </label>
                <select
                    v-model="property.state"
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                    required
                >
                    <option value="">Select...</option>
                    <option v-for="state in states" :key="state.value" :value="state.value">
                        {{ state.label }}
                    </option>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700">
                    ZIP Code *
                </label>
                <input
                    v-model="property.zip"
                    type="text"
                    pattern="\d{5}(-\d{4})?"
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                    required
                />
            </div>
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700">
                Legal Description Type *
            </label>
            <select
                v-model="property.legal_description_type"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                required
            >
                <option value="">Select...</option>
                <option v-for="type in legalTypes" :key="type.value" :value="type.value">
                    {{ type.label }}
                </option>
            </select>
        </div>

        <div v-if="property.legal_description_type === 'other'">
            <label class="block text-sm font-medium text-gray-700">
                Other Description *
            </label>
            <input
                v-model="property.legal_description_other"
                type="text"
                maxlength="100"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                required
            />
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700">
                Legal Description (from deed) *
            </label>
            <textarea
                v-model="property.legal_description"
                rows="4"
                maxlength="4000"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                placeholder="Enter the complete legal description exactly as it appears on the deed"
                required
            ></textarea>
            <p class="mt-1 text-xs text-gray-500">
                {{ property.legal_description?.length || 0 }} / 4000 characters
            </p>
        </div>
    </div>
</template>

<script setup>
defineProps({
    property: Object,
    states: Array,
    legalTypes: Array
})
</script>