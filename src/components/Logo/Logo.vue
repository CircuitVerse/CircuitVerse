<template>
    <a href="/">
        <span :class="cvlogo"></span>
    </a>
</template>

<script>
export default {
    name: 'Logo',
    props: {
        cvlogo: {
            type: String,
            default: 'logo',
        },
    },
    data() {
        return {}
    },
}
</script>

<style scoped>
/* @import url('./Logo.css'); */
</style>
