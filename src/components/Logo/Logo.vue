<template>
    <router-link to="/">
        <span :class="cvlogo"></span>
    </router-link>
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
