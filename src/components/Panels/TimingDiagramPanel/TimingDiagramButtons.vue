<template>
    <button :class="'custom-btn--' + type + ' panel-button'" :title="title">
        <span :class="'fas ' + icon + ' ' + btnClass"></span>
    </button>
</template>

<script lang="ts" setup>
defineProps({
    title: {
        type: String,
        required: true,
    },
    icon: {
        type: String,
        required: true,
    },
    btnClass: {
        type: String,
        required: true,
    },
    type: {
        type: String,
        required: true,
    },
})
</script>
