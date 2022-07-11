<template>
    <div>
        {{ obj }}
    </div>
</template>

<script lang="ts" setup>
import { toRefs } from '@vue/reactivity'

const props = defineProps({
    data: { type: Object, default: undefined },
})
console.log('Hello from panel 1')
const { obj } = toRefs(props)
</script>
