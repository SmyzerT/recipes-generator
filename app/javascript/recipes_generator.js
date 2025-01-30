import { createApp, ref, watch, computed } from 'https://unpkg.com/vue@3/dist/vue.esm-browser.js'

async function generateRecipes(ingredients) {
    const response = await fetch('/api/v1/recipes/generate.json', {
        headers: {
            "Content-Type": "application/json",
        },
        method: 'POST',
        body: JSON.stringify({ ingredients: ingredients.value })
    })
    if (response.ok) {
        const jsonResponse = await response.json()
        return jsonResponse.data
    }

    const responseText = await response.text()
    throw new Error(responseText)
}

createApp({
    setup() {
        const recipes = ref([])
        const loadingError = ref(null)
        const isLoading = ref(false)
        const ingredients = ref('')
        const lastReqIngredients = ref(null)

        const isFormValid = computed(() => {
            return ingredients.value.trim().length > 0
        })

        const fetchRecipes = async () => {
            isLoading.value = true
            loadingError.value = null

            try {
                recipes.value = await generateRecipes(ingredients)
                lastReqIngredients.value = ingredients.value
                ingredients.value = ''
            } catch (e) {
                console.error(e)
                loadingError.value = "Something went wrong, please try again later or change ingredients"
            } finally {
                isLoading.value = false
            }
        }

        const showRecipes = () => {
            return recipes && recipes.value.length > 0;
        }

        return {
            recipes,
            loadingError,
            isLoading,
            ingredients,
            lastReqIngredients,
            isFormValid,
            fetchRecipes,
            showRecipes
        }
    }
}).mount('#recipes-generator')
