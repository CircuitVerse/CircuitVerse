<template>
    Panel Type 3
    <p>
        <span>BitWidth in Panel 3:</span>
        <input
            class="objectPropertyAttribute"
            type="number"
            name="newBitWidth"
            min="1"
            max="32"
            value="${obj.bitWidth}"
            @change="checkPropertiesUpdate"
        />
    </p>
</template>

<script lang="ts" setup>
import simulationArea from '#/simulator/src/simulationArea'
import { checkPropertiesUpdate } from '#/simulator/src/ux'

const props = defineProps({
    data: { type: Object, default: undefined },
})
const obj = props.data
// console.log(obj)
// console.log(simulationArea.lastSelected)
</script>
