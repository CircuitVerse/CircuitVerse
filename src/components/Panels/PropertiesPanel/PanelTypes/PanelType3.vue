<template>Panel Type 3</template>

<script lang="ts" setup>
import simulationArea from '#/simulator/src/simulationArea'
import { onUpdated } from '@vue/runtime-core'

const props = defineProps({
    data: { type: Object, default: undefined },
})
const obj = props.data
console.log(obj)
console.log(simulationArea.lastSelected)
</script>
