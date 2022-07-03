<template>
    <InputGroups
        property-name="BitWidth: "
        :property-value="obj.bitWidth"
        property-value-type="number"
        value-min="1"
        value-max="32"
        property-input-name="newBitWidth"
        property-input-id="number"
    />
</template>

<script lang="ts" setup>
import InputGroups from '../../Shared/InputGroups.vue'
const props = defineProps({
    data: { type: Object, default: undefined },
})
const obj = props.data
</script>
