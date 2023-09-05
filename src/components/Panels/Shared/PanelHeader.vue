<template>
    <div class="panel-header">
        {{ headerTitle }}
        <span class="fas fa-minus-square minimize"></span>
        <span class="fas fa-external-link-square-alt maximize"></span>
    </div>
</template>

<script lang="ts" setup>
const props = defineProps({
    headerTitle: { type: String, default: 'Panel Header' },
})
</script>

<style scoped>
.fa-external-link-square-alt {
    cursor: pointer;
}
.fa-minus-square {
    cursor: pointer;
}
</style>
