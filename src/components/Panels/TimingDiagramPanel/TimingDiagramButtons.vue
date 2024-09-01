<template>
    <button :style="buttonStyle" :class="'custom-btn--' + type + ' panel-button'" :title="title">
        <span :class="'fas ' + icon + ' ' + btnClass"></span>
    </button>
</template>

<script lang="ts" setup>
import { useSimulatorMobileStore } from '#/store/simulatorMobileStore';
import { computed, ref, onMounted, onUnmounted } from 'vue';

const simulatorMobileStore = useSimulatorMobileStore()
const screenWidth = ref(window.innerWidth)

const updateScreenWidth = () => {
    screenWidth.value = window.innerWidth
}

onMounted(() => {
    window.addEventListener('resize', updateScreenWidth)
})

onUnmounted(() => {
    window.removeEventListener('resize', updateScreenWidth)
})

const buttonStyle = computed(() => {
    const isMobileView = simulatorMobileStore.showMobileView
    const padding = screenWidth.value < 738 ? '0.65rem' : '1rem'
    const paddingTop = '0.5rem'
    const paddingBottom = '0.5rem'

    return isMobileView ? { padding, paddingTop, paddingBottom } : {}
})
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
