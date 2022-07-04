<template>
    <p>
        <span>{{ propertyInputName }}</span>
        <select
            :id="propertySelectId"
            class="objectPropertyAttribute"
            :name="propertyName"
            :value="propertyValue"
        >
            <option
                v-for="(arrayItem, index) in dropdownArray"
                :key="index"
                :value="arrayItem"
            >
                {{ arrayItem }}
            </option>
        </select>
    </p>
</template>

<script lang="ts" setup>
const props = defineProps({
    dropdownArray: { type: Array, default: undefined },
    propertyName: { type: String, default: 'Property Name' },
    propertyValue: { type: String, default: '' },
    propertyInputName: { type: String, default: 'Property_Input_Name' },
    propertySelectId: { type: String, default: 'Property_Input_Id' },
})
</script>
