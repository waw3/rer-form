<template>
    <AuthenticatedLayout>
        <template #header>
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">
                Real Estate Report (RER) Filing
            </h2>
        </template>

        <div class="py-12">
            <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6">
                        <!-- Progress Steps -->
                        <div class="mb-8">
                            <div class="flex items-center justify-between">
                                <div v-for="(step, index) in steps" :key="index" class="flex-1">
                                    <div class="relative">
                                        <div
                                            :class="[
                                                'w-10 h-10 mx-auto rounded-full text-lg flex items-center justify-center',
                                                currentStep > index
                                                    ? 'bg-green-500 text-white'
                                                    : currentStep === index
                                                    ? 'bg-blue-500 text-white'
                                                    : 'bg-gray-300'
                                            ]"
                                        >
                                            <span v-if="currentStep > index">✓</span>
                                            <span v-else>{{ index + 1 }}</span>
                                        </div>
                                        <div class="text-xs text-center mt-2">{{ step.label }}</div>
                                    </div>
                                    <div
                                        v-if="index < steps.length - 1"
                                        :class="[
                                            'absolute top-5 left-1/2 w-full h-0.5',
                                            currentStep > index ? 'bg-green-500' : 'bg-gray-300'
                                        ]"
                                    ></div>
                                </div>
                            </div>
                        </div>

                        <!-- Form Sections -->
                        <form @submit.prevent="handleSubmit">
                            <!-- Filing Information -->
                            <div v-if="currentStep === 0" class="space-y-6">
                                <h3 class="text-lg font-medium">Filing Information</h3>
                                
                                <div>
                                    <label class="block text-sm font-medium text-gray-700">
                                        Type of Filing *
                                    </label>
                                    <select
                                        v-model="form.filing_type"
                                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                        required
                                    >
                                        <option value="">Select...</option>
                                        <option v-for="type in formOptions.filing_types" :key="type.value" :value="type.value">
                                            {{ type.label }}
                                        </option>
                                    </select>
                                </div>

                                <div v-if="form.filing_type === 'correct_amend'">
                                    <label class="block text-sm font-medium text-gray-700">
                                        Prior BSA ID *
                                    </label>
                                    <input
                                        v-model="form.prior_bsa_id"
                                        type="text"
                                        maxlength="14"
                                        pattern="[A-Z0-9]{14}"
                                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                        placeholder="14 character BSA ID"
                                        required
                                    />
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700">
                                        Date Prepared *
                                    </label>
                                    <input
                                        v-model="form.date_prepared"
                                        type="date"
                                        :max="today"
                                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                        required
                                    />
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700">
                                        Date of Closing *
                                    </label>
                                    <input
                                        v-model="form.closing_date"
                                        type="date"
                                        :max="today"
                                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                        required
                                    />
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700">
                                        Note to FinCEN (Optional)
                                    </label>
                                    <textarea
                                        v-model="form.note_to_fincen"
                                        rows="3"
                                        maxlength="4000"
                                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                    ></textarea>
                                </div>
                            </div>

                            <!-- Reporting Person -->
                            <div v-if="currentStep === 1" class="space-y-6">
                                <h3 class="text-lg font-medium">Reporting Person Information</h3>
                                
                                <div>
                                    <label class="block text-sm font-medium text-gray-700">
                                        Reporting Person Category *
                                    </label>
                                    <select
                                        v-model="form.reporting_person_category"
                                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                        required
                                    >
                                        <option value="">Select...</option>
                                        <option v-for="cat in formOptions.reporting_categories" :key="cat.value" :value="cat.value">
                                            {{ cat.label }}
                                        </option>
                                    </select>
                                </div>

                                <div>
                                    <label class="flex items-center">
                                        <input
                                            v-model="form.reporting_person_is_entity"
                                            type="checkbox"
                                            class="rounded border-gray-300 text-indigo-600 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                        />
                                        <span class="ml-2 text-sm text-gray-700">Reporting person is an entity</span>
                                    </label>
                                </div>

                                <div v-if="!form.reporting_person_is_entity" class="grid grid-cols-2 gap-4">
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700">
                                            First Name *
                                        </label>
                                        <input
                                            v-model="form.reporting_person_first_name"
                                            type="text"
                                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                            required
                                        />
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700">
                                            Middle Name
                                        </label>
                                        <input
                                            v-model="form.reporting_person_middle_name"
                                            type="text"
                                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                        />
                                    </div>
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700">
                                        {{ form.reporting_person_is_entity ? 'Legal Name' : 'Last Name' }} *
                                    </label>
                                    <input
                                        v-model="form.reporting_person_name"
                                        type="text"
                                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                        required
                                    />
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700">
                                        Street Address *
                                    </label>
                                    <input
                                        v-model="form.reporting_person_street_address"
                                        type="text"
                                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                        required
                                    />
                                </div>

                                <div class="grid grid-cols-3 gap-4">
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700">
                                            City *
                                        </label>
                                        <input
                                            v-model="form.reporting_person_city"
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
                                            v-model="form.reporting_person_state"
                                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                            required
                                        >
                                            <option value="">Select...</option>
                                            <option v-for="state in formOptions.states" :key="state.value" :value="state.value">
                                                {{ state.label }}
                                            </option>
                                        </select>
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700">
                                            ZIP Code *
                                        </label>
                                        <input
                                            v-model="form.reporting_person_zip"
                                            type="text"
                                            pattern="\d{5}(-\d{4})?"
                                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                            required
                                        />
                                    </div>
                                </div>
                            </div>

                            <!-- Properties -->
                            <div v-if="currentStep === 2" class="space-y-6">
                                <h3 class="text-lg font-medium">Property Information</h3>
                                
                                <div v-for="(property, index) in form.properties" :key="index" class="border p-4 rounded-lg space-y-4">
                                    <div class="flex justify-between items-center">
                                        <h4 class="font-medium">Property {{ index + 1 }}</h4>
                                        <button
                                            v-if="form.properties.length > 1"
                                            @click="removeProperty(index)"
                                            type="button"
                                            class="text-red-600 hover:text-red-800"
                                        >
                                            Remove
                                        </button>
                                    </div>

                                    <PropertyForm :property="property" :states="formOptions.states" :legalTypes="formOptions.legal_description_types" />
                                </div>

                                <button
                                    @click="addProperty"
                                    type="button"
                                    class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200"
                                >
                                    Add Property
                                </button>
                            </div>

                            <!-- Summary Step -->
                            <div v-if="currentStep === steps.length - 1" class="space-y-6">
                                <h3 class="text-lg font-medium">Review and Submit</h3>
                                
                                <div class="bg-gray-50 p-4 rounded-lg">
                                    <p class="text-sm text-gray-700 mb-4">
                                        Please review your filing information. Click "Validate" to check for errors before submission.
                                    </p>
                                    
                                    <div v-if="validationErrors" class="mb-4 p-4 bg-red-50 rounded-lg">
                                        <h4 class="text-sm font-medium text-red-800 mb-2">Validation Errors:</h4>
                                        <pre class="text-xs text-red-700 whitespace-pre-wrap">{{ JSON.stringify(validationErrors, null, 2) }}</pre>
                                    </div>

                                    <div v-if="validationSuccess" class="mb-4 p-4 bg-green-50 rounded-lg">
                                        <p class="text-sm text-green-800">✓ Validation successful! Your filing is ready for submission.</p>
                                    </div>
                                </div>

                                <div class="flex space-x-4">
                                    <button
                                        @click="validateFiling"
                                        type="button"
                                        class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                                        :disabled="isValidating"
                                    >
                                        {{ isValidating ? 'Validating...' : 'Validate' }}
                                    </button>

                                    <button
                                        @click="submitFiling"
                                        type="button"
                                        class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
                                        :disabled="!validationSuccess || isSubmitting"
                                    >
                                        {{ isSubmitting ? 'Submitting...' : 'Submit Filing' }}
                                    </button>
                                </div>
                            </div>

                            <!-- Navigation -->
                            <div class="mt-8 flex justify-between">
                                <button
                                    v-if="currentStep > 0"
                                    @click="currentStep--"
                                    type="button"
                                    class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                                >
                                    Previous
                                </button>
                                
                                <button
                                    v-if="currentStep < steps.length - 1"
                                    @click="currentStep++"
                                    type="button"
                                    class="ml-auto inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700"
                                >
                                    Next
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- JSON Preview Modal -->
        <JsonPreviewModal
            :show="showJsonModal"
            :data="jsonData"
            @close="showJsonModal = false"
        />
    </AuthenticatedLayout>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useForm } from '@inertiajs/vue3'
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue'
import PropertyForm from './Components/PropertyForm.vue'
import JsonPreviewModal from './Components/JsonPreviewModal.vue'
import axios from 'axios'

const props = defineProps({
    formOptions: Object
})

const today = new Date().toISOString().split('T')[0]

const steps = [
    { label: 'Filing Info' },
    { label: 'Reporting Person' },
    { label: 'Properties' },
    { label: 'Transferees' },
    { label: 'Transferors' },
    { label: 'Payments' },
    { label: 'Review' }
]

const currentStep = ref(0)
const validationErrors = ref(null)
const validationSuccess = ref(false)
const isValidating = ref(false)
const isSubmitting = ref(false)
const showJsonModal = ref(false)
const jsonData = ref(null)

const form = useForm({
    filing_type: '',
    prior_bsa_id: '',
    date_prepared: '',
    note_to_fincen: '',
    closing_date: '',
    reporting_person_category: '',
    reporting_person_is_entity: false,
    reporting_person_name: '',
    reporting_person_first_name: '',
    reporting_person_middle_name: '',
    reporting_person_suffix: '',
    reporting_person_street_address: '',
    reporting_person_city: '',
    reporting_person_state: '',
    reporting_person_zip: '',
    total_consideration: null,
    no_consideration_transfer: false,
    has_private_loan: false,
    private_loan_type: '',
    private_loan_other: '',
    properties: [createProperty()],
    transferees: [],
    transferors: [],
    payments: []
})

function createProperty() {
    return {
        street_address: '',
        no_street_address: false,
        city: '',
        state: '',
        zip: '',
        legal_description_type: '',
        legal_description_other: '',
        legal_description: ''
    }
}

function addProperty() {
    form.properties.push(createProperty())
}

function removeProperty(index) {
    form.properties.splice(index, 1)
}

async function validateFiling() {
    isValidating.value = true
    validationErrors.value = null
    validationSuccess.value = false
    
    try {
        // First save the filing
        const saveResponse = await form.post('/rer', {
            preserveState: true,
            preserveScroll: true,
            onSuccess: (page) => {
                const filingId = page.props.filing?.id
                if (filingId) {
                    // Then validate
                    axios.post(`/rer/${filingId}/validate`)
                        .then(response => {
                            validationSuccess.value = true
                            jsonData.value = response.data.data
                        })
                        .catch(error => {
                            validationErrors.value = error.response.data.errors
                        })
                        .finally(() => {
                            isValidating.value = false
                        })
                }
            }
        })
    } catch (error) {
        isValidating.value = false
        console.error('Validation error:', error)
    }
}

async function submitFiling() {
    if (!validationSuccess.value) return
    
    isSubmitting.value = true
    
    try {
        const filingId = form.id // Assuming form has ID after validation
        const response = await axios.post(`/rer/${filingId}/submit`)
        
        if (response.data.success) {
            jsonData.value = response.data.data
            showJsonModal.value = true
        }
    } catch (error) {
        console.error('Submission error:', error)
    } finally {
        isSubmitting.value = false
    }
}
</script>